from datetime import datetime, date, timedelta, timezone
from decimal import Decimal
from typing import List, Dict, Any, Optional, Tuple
from sqlalchemy.orm import Session
from app.models.transaction import Transaction
from app.core.currencies import format_currency_amount
from app.services.intelligence_service import financial_intelligence_service
from app.schemas.insights import (
    InsightsResponse,
    CategoryBreakdownItem,
    DailySpendingPoint,
    PeriodComparison,
)

CATEGORY_EMOJIS: Dict[str, Tuple[str, str]] = {
    "Food": ("🍔", "fastfood"),
    "Transport": ("🚕", "directions_car"),
    "Housing": ("🏠", "home"),
    "Bills": ("⚡", "receipt_long"),
    "Shopping": ("🛍️", "shopping_bag"),
    "Entertainment": ("🎬", "movie"),
    "Health": ("💊", "medical_services"),
    "Education": ("📚", "school"),
    "Travel": ("✈️", "flight_takeoff"),
    "Income": ("💰", "account_balance_wallet"),
    "Other": ("🛒", "shopping_bag"),
}

class AnalyticsService:
    @staticmethod
    def get_insights(
        db: Session,
        period: str = "month",
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
        currency: str = "INR",
        user_id: Optional[str] = None,
    ) -> InsightsResponse:
        """
        Calculates deterministic financial metrics, trends, category breakdowns,
        and executes FinancialIntelligenceService for data-driven personalized insights.
        """
        curr_start, curr_end = AnalyticsService._resolve_date_range(period, start_date, end_date)
        user_id_int = int(user_id) if user_id and user_id.isdigit() else None

        # 1. Fetch current period transactions
        query = db.query(Transaction).filter(
            Transaction.transaction_date >= datetime.combine(curr_start, datetime.min.time(), tzinfo=timezone.utc),
            Transaction.transaction_date <= datetime.combine(curr_end, datetime.max.time(), tzinfo=timezone.utc),
        )
        if user_id_int:
            query = query.filter(Transaction.user_id == user_id_int)

        transactions = query.all()

        # Execute Financial Intelligence Engine
        intel_res = financial_intelligence_service.analyze_user_intelligence(
            db=db,
            user_id=user_id_int,
            primary_currency=currency,
        )

        if not transactions:
            return InsightsResponse(
                period=period,
                currency=currency,
                total_income=0.0,
                total_spent=0.0,
                net_remaining=0.0,
                has_income=False,
                transaction_count=0,
                expense_count=0,
                average_daily_spending=0.0,
                average_transaction_amount=0.0,
                is_mixed_currency=False,
                currency_totals={},
                multi_currency_notice=None,
                top_category=None,
                category_breakdown=[],
                daily_spending_trend=[],
                previous_period_comparison=PeriodComparison(
                    has_comparison=False,
                    message="Keep tracking to see your trends."
                ),
                generated_insights=[s.description for s in intel_res.insights],
                structured_insights=intel_res.insights,
            )

        # 2. Check for Mixed Currencies
        unique_currencies = {tx.currency for tx in transactions if tx.currency}
        is_mixed = len(unique_currencies) > 1

        currency_sums: Dict[str, float] = {}
        for tx in transactions:
            c_code = tx.currency or currency
            amt = float(tx.amount)
            currency_sums[c_code] = currency_sums.get(c_code, 0.0) + amt

        multi_notice = None
        if is_mixed:
            multi_notice = "Some transactions use different currencies. Currency conversion is required to combine these totals."

        # Filter expenses
        expenses = [tx for tx in transactions if tx.type.lower() == "expense"]
        incomes = [tx for tx in transactions if tx.type.lower() == "income"]

        total_spent_dec = sum((Decimal(str(tx.amount)) for tx in expenses), Decimal("0.00"))
        total_income_dec = sum((Decimal(str(tx.amount)) for tx in incomes), Decimal("0.00"))
        net_remaining_dec = total_income_dec - total_spent_dec

        total_spent = float(total_spent_dec)
        total_income = float(total_income_dec)
        net_remaining = float(net_remaining_dec)
        has_income = total_income > 0

        days_count = max(1, (curr_end - curr_start).days + 1)
        average_daily_spending = total_spent / days_count if total_spent > 0 else 0.0
        average_transaction_amount = total_spent / len(expenses) if len(expenses) > 0 else 0.0

        # 3. Category Breakdown & Ranking
        category_totals: Dict[str, Decimal] = {}
        category_counts: Dict[str, int] = {}
        for tx in expenses:
            cat = tx.category or "Other"
            amt = Decimal(str(tx.amount))
            category_totals[cat] = category_totals.get(cat, Decimal("0.00")) + amt
            category_counts[cat] = category_counts.get(cat, 0) + 1

        sorted_categories = sorted(category_totals.items(), key=lambda x: x[1], reverse=True)

        breakdown_items: List[CategoryBreakdownItem] = []
        for rank, (cat_name, cat_amt_dec) in enumerate(sorted_categories, start=1):
            cat_amt = float(cat_amt_dec)
            pct = (cat_amt / total_spent * 100.0) if total_spent > 0 else 0.0
            emoji, icon = CATEGORY_EMOJIS.get(cat_name, ("🛒", "shopping_bag"))
            breakdown_items.append(
                CategoryBreakdownItem(
                    category=cat_name,
                    total_amount=cat_amt,
                    percentage=round(pct, 1),
                    count=category_counts.get(cat_name, 0),
                    rank=rank,
                    emoji=emoji,
                    icon_name=icon,
                )
            )

        top_category = breakdown_items[0] if breakdown_items else None

        # 4. Daily Spending Trend
        daily_trend = AnalyticsService._calculate_daily_trend(expenses, curr_start, curr_end)

        # 5. Previous Period Comparison
        period_duration = (curr_end - curr_start).days + 1
        prev_end = curr_start - timedelta(days=1)
        prev_start = prev_end - timedelta(days=period_duration - 1)

        prev_query = db.query(Transaction).filter(
            Transaction.type == "expense",
            Transaction.transaction_date >= datetime.combine(prev_start, datetime.min.time(), tzinfo=timezone.utc),
            Transaction.transaction_date <= datetime.combine(prev_end, datetime.max.time(), tzinfo=timezone.utc),
        )
        if user_id_int:
            prev_query = prev_query.filter(Transaction.user_id == user_id_int)

        prev_expenses = prev_query.all()
        prev_total_dec = sum((Decimal(str(tx.amount)) for tx in prev_expenses), Decimal("0.00"))
        prev_total = float(prev_total_dec)

        if prev_total > 0:
            amt_change = total_spent - prev_total
            pct_change = ((total_spent - prev_total) / prev_total) * 100.0
            is_inc = total_spent > prev_total
            comp = PeriodComparison(
                has_comparison=True,
                current_total=total_spent,
                previous_total=prev_total,
                amount_change=round(amt_change, 2),
                percentage_change=round(abs(pct_change), 1),
                is_increase=is_inc,
                message=f"{'↑' if is_inc else '↓'} {abs(pct_change):.1f}% vs previous period",
            )
        else:
            comp = PeriodComparison(
                has_comparison=False,
                current_total=total_spent,
                previous_total=0.0,
                amount_change=0.0,
                percentage_change=0.0,
                is_increase=False,
                message="Keep tracking to see your trends."
            )

        plain_text_insights = [s.description for s in intel_res.insights]
        if not plain_text_insights and top_category:
            plain_text_insights.append(
                f"Top spending category is {top_category.category} ({top_category.percentage:.1f}% of total spending)."
            )

        return InsightsResponse(
            period=period,
            currency=currency,
            total_income=total_income,
            total_spent=total_spent,
            net_remaining=net_remaining,
            has_income=has_income,
            transaction_count=len(transactions),
            expense_count=len(expenses),
            average_daily_spending=round(average_daily_spending, 2),
            average_transaction_amount=round(average_transaction_amount, 2),
            is_mixed_currency=is_mixed,
            currency_totals=currency_sums,
            multi_currency_notice=multi_notice,
            top_category=top_category,
            category_breakdown=breakdown_items,
            daily_spending_trend=daily_trend,
            previous_period_comparison=comp,
            generated_insights=plain_text_insights,
            structured_insights=intel_res.insights,
        )

    @staticmethod
    def _resolve_date_range(period: str, start_date: Optional[date], end_date: Optional[date]) -> Tuple[date, date]:
        today = date.today()
        if period == "week":
            return today - timedelta(days=6), today
        elif period == "year":
            return date(today.year, 1, 1), today
        elif period == "3months":
            return today - timedelta(days=89), today
        elif period == "custom" and start_date and end_date:
            return start_date, end_date
        else:
            first_of_month = date(today.year, today.month, 1)
            return first_of_month, today

    @staticmethod
    def _calculate_daily_trend(expenses: List[Transaction], start_d: date, end_d: date) -> List[DailySpendingPoint]:
        daily_sums: Dict[str, Decimal] = {}
        daily_counts: Dict[str, int] = {}
        curr = start_d
        while curr <= end_d:
            d_str = curr.strftime("%Y-%m-%d")
            daily_sums[d_str] = Decimal("0.00")
            daily_counts[d_str] = 0
            curr += timedelta(days=1)

        for tx in expenses:
            if tx.transaction_date:
                tx_date_str = tx.transaction_date.strftime("%Y-%m-%d")
                if tx_date_str in daily_sums:
                    daily_sums[tx_date_str] += Decimal(str(tx.amount))
                    daily_counts[tx_date_str] += 1

        return [
            DailySpendingPoint(date=d_str, amount=float(amt), count=daily_counts.get(d_str, 0))
            for d_str, amt in daily_sums.items()
        ]

analytics_service = AnalyticsService()
