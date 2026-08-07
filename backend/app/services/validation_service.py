from decimal import Decimal
from typing import Optional, Dict, Any
from sqlalchemy.orm import Session
from app.models.transaction import Transaction
from app.services.intelligence_service import financial_intelligence_service
from app.core.currencies import format_currency_amount

DEFAULT_THRESHOLDS: Dict[str, Decimal] = {
    "Food": Decimal("3000"),
    "Transport": Decimal("5000"),
    "Housing": Decimal("50000"),
    "Bills": Decimal("10000"),
    "Shopping": Decimal("15000"),
    "Entertainment": Decimal("5000"),
    "Health": Decimal("10000"),
    "Education": Decimal("25000"),
    "Travel": Decimal("30000"),
    "Other": Decimal("10000"),
}

class ValidationService:
    @staticmethod
    def validate_amount(
        db: Session,
        amount: Decimal,
        category: str,
        user_id: Optional[str] = None,
        currency: str = "INR",
    ) -> Dict[str, Any]:
        """
        Validates transaction amount against category baselines and user historical spending patterns.
        Flags unusually high amounts using data-driven intelligence without blocking transactions.
        """
        if amount <= 0:
            return {"is_valid": False, "is_unusual": False, "message": "Amount must be greater than zero."}

        threshold = DEFAULT_THRESHOLDS.get(category, Decimal("10000"))

        user_id_int = int(user_id) if user_id and user_id.isdigit() else None
        query = db.query(Transaction).filter(Transaction.category == category)
        if user_id_int:
            query = query.filter(Transaction.user_id == user_id_int)

        history = query.all()
        if len(history) >= 3:
            baselines = financial_intelligence_service.calculate_baselines(history, currency)
            if baselines:
                b = baselines[0]
                if b.sufficient_data and b.typical_range_high > 0:
                    threshold = Decimal(str(max(float(threshold), b.typical_range_high * 1.5)))

        if amount > threshold:
            suggested_amount = ValidationService._calculate_suggested_correction(amount, threshold)
            formatted_amt = format_currency_amount(amount, currency)
            formatted_sug = format_currency_amount(suggested_amount, currency)

            return {
                "is_valid": True,
                "is_unusual": True,
                "threshold": float(threshold),
                "original_amount": float(amount),
                "suggested_amount": float(suggested_amount),
                "message": f"{formatted_amt} seems unusually high for {category}.",
                "question": f"Did you mean {formatted_sug}?"
            }

        return {"is_valid": True, "is_unusual": False}

    @staticmethod
    def _calculate_suggested_correction(amount: Decimal, threshold: Decimal) -> Decimal:
        """Heuristic to suggest likely typo correction (e.g. extra zeros like 25000 -> 250)."""
        div_100 = amount / Decimal("100")
        if 0 < div_100 <= threshold:
            return div_100

        div_10 = amount / Decimal("10")
        if 0 < div_10 <= threshold:
            return div_10

        return div_100

validation_service = ValidationService()
