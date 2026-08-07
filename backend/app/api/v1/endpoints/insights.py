from datetime import date
from typing import Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.api.deps import get_optional_current_user
from app.schemas.insights import InsightsResponse
from app.services.analytics_service import analytics_service

router = APIRouter()

@router.get("", response_model=InsightsResponse, status_code=status.HTTP_200_OK)
def get_financial_insights(
    period: str = Query(default="month", description="Period: 'week', 'month', '3months', or 'custom'"),
    start_date: Optional[date] = Query(default=None, description="Custom start date (YYYY-MM-DD)"),
    end_date: Optional[date] = Query(default=None, description="Custom end date (YYYY-MM-DD)"),
    currency: Optional[str] = Query(default=None, description="Currency symbol/code"),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
):
    """
    Retrieves aggregated financial metrics, spending summary, category breakdown,
    daily spending trend, period comparisons, and generated deterministic insights scoped to user.
    """
    user_id = current_user.id if current_user else None
    effective_currency = currency or (current_user.currency if current_user else "INR")

    return analytics_service.get_insights(
        db=db,
        period=period,
        start_date=start_date,
        end_date=end_date,
        currency=effective_currency,
        user_id=str(user_id) if user_id else None,
    )
