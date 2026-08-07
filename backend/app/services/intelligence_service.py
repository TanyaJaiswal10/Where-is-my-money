import statistics
from datetime import datetime, date, timedelta, timezone
from decimal import Decimal
from typing import List, Dict, Any, Optional, Tuple
from sqlalchemy.orm import Session

from app.models.transaction import Transaction
from app.core.currencies import format_currency_amount
from app.schemas.intelligence import (
    StructuredInsight,
    CategoryBaseline,
    RecurringExpenseItem,
    FinancialIntelligenceResponse,
)

SUBSCRIPTION_KEYWORDS = {
    "netflix", "spotify", "apple", "icloud", "prime", "youtube", "hbo", "hotstar",
    "gym", "fitness", "membership", "sub", "patreon", "medium", "chatgpt", "openai"
}

class FinancialIntelligenceService:
    @staticmethod
    def analyze_user_intelligence(
        db: Session,
        user_id: Optional[int] = None,
        primary_currency: str = "INR",
    ) -> FinancialIntelligenceResponse:
        if db is None:
            return FinancialIntelligenceResponse(
                insights=[],
                baselines=[],
                recurring_expenses=[],
                data_quality_status="no_data",
            )

        query = db.query(Transaction)
        if user_id is not None:
            query = query.filter(Transaction.user_id == user_id)

        all_txs = query.order_by(Transaction.transaction_date.asc()).all()

        if not all_txs:
            return FinancialIntelligenceResponse(
                insights=[],
                baselines=[],
                recurring_expenses=[],
                data_quality_status="no_data",
            )

        expenses = [t for t in all_txs if t.type.lower() == "expense"]

        if len(expenses) < 2:
            return FinancialIntelligenceResponse(
                insights=[
                    StructuredInsight(
                        type="SPENDING_PATTERN",
                        title="Insufficient Data",
                        description="Keep tracking to discover your spending patterns.",
                        importance_score=0.1,
                        confidence=1.0,
                        currency=primary_currency,
                        supporting_data={"transaction_count": len(expenses)},
                    )
                ],
                baselines=[],
                recurring_expenses=[],
                data_quality_status="insufficient",
            )

        # 1. Baselines
        baselines = FinancialIntelligenceService.calculate_baselines(expenses, primary_currency)

        # 2. Recurring Expenses & Subscriptions
        recurring = FinancialIntelligenceService.detect_recurring_expenses(expenses, primary_currency)

        # 3. Candidate Insights Generation
        candidate_insights: List[StructuredInsight] = []

        # A. MoM & Trend Insights
        trend_insights = FinancialIntelligenceService.generate_trend_insights(expenses, baselines, primary_currency)
        candidate_insights.extend(trend_insights)

        # B. Recurring / Subscription Insights
        for rec in recurring:
            amt_str = format_currency_amount(rec.average_amount, rec.currency)
            kind = "subscription" if rec.is_subscription else "recurring expense"
            candidate_insights.append(
                StructuredInsight(
                    type="SUBSCRIPTION" if rec.is_subscription else "RECURRING_EXPENSE",
                    title=f"Possible {kind.capitalize()}: {rec.description.capitalize()}",
                    description=f"{rec.description.capitalize()} ({amt_str}) appears approximately every {rec.frequency_days} days.",
                    importance_score=0.75 if rec.is_subscription else 0.60,
                    confidence=rec.confidence,
                    currency=rec.currency,
                    supporting_data={
                        "description": rec.description,
                        "average_amount": rec.average_amount,
                        "frequency_days": rec.frequency_days,
                    },
                )
            )

        # C. Weekend / Spending Pace Insights
        pace_insights = FinancialIntelligenceService.analyze_spending_pace(expenses, primary_currency)
        candidate_insights.extend(pace_insights)

        # 4. Rank and Filter Top Insights (Max 5)
        ranked = FinancialIntelligenceService.rank_insights(candidate_insights, max_items=5)

        return FinancialIntelligenceResponse(
            insights=ranked,
            baselines=baselines,
            recurring_expenses=recurring,
            data_quality_status="sufficient",
        )

    @staticmethod
    def calculate_baselines(expenses: List[Transaction], default_currency: str) -> List[CategoryBaseline]:
        """Calculates statistical baselines (median, average, MAD typical range) per category."""
        by_category: Dict[str, List[float]] = {}
        for tx in expenses:
            cat = tx.category or "Other"
            by_category.setdefault(cat, []).append(float(tx.amount))

        baselines: List[CategoryBaseline] = []
        for cat, amounts in by_category.items():
            count = len(amounts)
            if count == 0:
                continue

            avg_amt = sum(amounts) / count
            med_amt = statistics.median(amounts)
            min_amt = min(amounts)
            max_amt = max(amounts)

            if count >= 3:
                mad = statistics.median([abs(x - med_amt) for x in amounts])
                typical_low = max(0.0, med_amt - 1.5 * mad if mad > 0 else med_amt * 0.5)
                typical_high = med_amt + 2.5 * mad if mad > 0 else med_amt * 2.0
                sufficient = True
            else:
                typical_low = min_amt
                typical_high = max_amt
                sufficient = False

            baselines.append(
                CategoryBaseline(
                    category=cat,
                    currency=default_currency,
                    sample_count=count,
                    average_amount=round(avg_amt, 2),
                    median_amount=round(med_amt, 2),
                    min_amount=round(min_amt, 2),
                    max_amount=round(max_amt, 2),
                    typical_range_low=round(typical_low, 2),
                    typical_range_high=round(typical_high, 2),
                    monthly_average=round(avg_amt * 4, 2),
                    weekly_average=round(avg_amt, 2),
                    trend_direction="stable",
                    sufficient_data=sufficient,
                )
            )

        return baselines

    @staticmethod
    def check_anomaly(
        baseline: Optional[CategoryBaseline],
        amount: float,
        category: str,
        currency: str,
    ) -> Optional[StructuredInsight]:
        """Checks if a new transaction amount is statistically anomalous against user's history."""
        if not baseline or not baseline.sufficient_data:
            return None

        threshold = baseline.typical_range_high * 1.5
        if amount > threshold and amount > 1000.0:
            formatted_amt = format_currency_amount(amount, currency)
            formatted_avg = format_currency_amount(baseline.average_amount, currency)
            return StructuredInsight(
                type="ANOMALY",
                title=f"Unusual {category} Expense",
                description=f"{formatted_amt} is much higher than your usual {category} spending (avg {formatted_avg}).",
                importance_score=0.90,
                confidence=0.92,
                currency=currency,
                supporting_data={
                    "amount": amount,
                    "average_amount": baseline.average_amount,
                    "typical_high": baseline.typical_range_high,
                },
            )
        return None

    @staticmethod
    def detect_recurring_expenses(expenses: List[Transaction], default_currency: str) -> List[RecurringExpenseItem]:
        """Detects recurring transaction patterns and subscriptions using interval analysis."""
        by_desc: Dict[str, List[Tuple[date, float, str]]] = {}
        for tx in expenses:
            d_lower = tx.description.lower().strip()
            if isinstance(tx.transaction_date, (datetime, date)):
                tx_date = tx.transaction_date.date() if isinstance(tx.transaction_date, datetime) else tx.transaction_date
            elif isinstance(tx.transaction_date, str):
                try:
                    tx_date = datetime.fromisoformat(tx.transaction_date.replace("Z", "+00:00")).date()
                except Exception:
                    tx_date = date.today()
            else:
                tx_date = date.today()

            by_desc.setdefault(d_lower, []).append((tx_date, float(tx.amount), tx.currency or default_currency))

        recurring: List[RecurringExpenseItem] = []
        for desc, records in by_desc.items():
            if len(records) < 2:
                continue

            records.sort(key=lambda x: x[0])
            dates = [r[0] for r in records]
            amounts = [r[1] for r in records]
            currencies = [r[2] for r in records]

            intervals = [(dates[i] - dates[i-1]).days for i in range(1, len(dates))]
            avg_interval = sum(intervals) / len(intervals)

            if 25 <= avg_interval <= 35 or 12 <= avg_interval <= 16:
                avg_amt = sum(amounts) / len(amounts)
                is_sub = any(kw in desc for kw in SUBSCRIPTION_KEYWORDS)
                conf = 0.90 if is_sub else 0.75

                recurring.append(
                    RecurringExpenseItem(
                        description=desc,
                        average_amount=round(avg_amt, 2),
                        currency=currencies[-1],
                        frequency_days=int(round(avg_interval)),
                        occurrences=len(records),
                        is_subscription=is_sub,
                        confidence=conf,
                        last_date=dates[-1].strftime("%Y-%m-%d"),
                    )
                )

        return recurring

    @staticmethod
    def generate_trend_insights(
        expenses: List[Transaction],
        baselines: List[CategoryBaseline],
        currency: str,
    ) -> List[StructuredInsight]:
        """Detects category trends and month-over-month (MoM) spending changes."""
        today = date.today()
        curr_month_start = date(today.year, today.month, 1)
        prev_month_end = curr_month_start - timedelta(days=1)
        prev_month_start = date(prev_month_end.year, prev_month_end.month, 1)

        curr_by_cat: Dict[str, float] = {}
        prev_by_cat: Dict[str, float] = {}

        for tx in expenses:
            if not tx.transaction_date:
                continue
            tx_d = tx.transaction_date.date()
            amt = float(tx.amount)
            cat = tx.category or "Other"

            if curr_month_start <= tx_d <= today:
                curr_by_cat[cat] = curr_by_cat.get(cat, 0.0) + amt
            elif prev_month_start <= tx_d <= prev_month_end:
                prev_by_cat[cat] = prev_by_cat.get(cat, 0.0) + amt

        insights: List[StructuredInsight] = []
        for cat, prev_amt in prev_by_cat.items():
            if prev_amt < 300.0:
                continue
            curr_amt = curr_by_cat.get(cat, 0.0)
            diff = curr_amt - prev_amt
            pct = ((curr_amt - prev_amt) / prev_amt) * 100.0

            if abs(pct) >= 15.0 and abs(diff) >= 500.0:
                is_inc = diff > 0
                dir_str = "increased" if is_inc else "decreased"
                formatted_curr = format_currency_amount(curr_amt, currency)
                formatted_prev = format_currency_amount(prev_amt, currency)

                insights.append(
                    StructuredInsight(
                        type="TREND",
                        title=f"{cat} Spending {dir_str.capitalize()}",
                        description=f"You spent {abs(pct):.1f}% {'more' if is_inc else 'less'} on {cat} than last month ({formatted_curr} vs {formatted_prev}).",
                        importance_score=0.80 if is_inc else 0.65,
                        confidence=0.88,
                        currency=currency,
                        supporting_data={
                            "category": cat,
                            "current_amount": curr_amt,
                            "previous_amount": prev_amt,
                            "percentage_change": round(pct, 1),
                        },
                    )
                )

        return insights

    @staticmethod
    def analyze_spending_pace(expenses: List[Transaction], currency: str) -> List[StructuredInsight]:
        """Detects weekend spending patterns and overall spending velocity."""
        if len(expenses) < 5:
            return []

        weekend_exp = sum(float(tx.amount) for tx in expenses if tx.transaction_date and tx.transaction_date.weekday() >= 5)
        total_exp = sum(float(tx.amount) for tx in expenses)

        insights: List[StructuredInsight] = []
        if total_exp > 0 and (weekend_exp / total_exp) >= 0.35:
            pct = (weekend_exp / total_exp) * 100.0
            insights.append(
                StructuredInsight(
                    type="SPENDING_PATTERN",
                    title="Weekend Spending Pattern",
                    description=f"You tend to spend {pct:.0f}% of your money on weekends.",
                    importance_score=0.60,
                    confidence=0.85,
                    currency=currency,
                    supporting_data={"weekend_percentage": round(pct, 1)},
                )
            )

        return insights

    @staticmethod
    def rank_insights(insights: List[StructuredInsight], max_items: int = 5) -> List[StructuredInsight]:
        """Ranks insights based on importance_score * confidence and takes top N."""
        sorted_insights = sorted(
            insights,
            key=lambda x: x.importance_score * x.confidence,
            reverse=True,
        )
        return sorted_insights[:max_items]

financial_intelligence_service = FinancialIntelligenceService()
