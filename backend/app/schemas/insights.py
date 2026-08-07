from typing import List, Optional, Dict
from pydantic import BaseModel, Field
from app.schemas.intelligence import StructuredInsight

class CategoryBreakdownItem(BaseModel):
    category: str
    total_amount: float
    percentage: float
    count: int
    rank: int
    emoji: str = "🛒"
    icon_name: str = "shopping_bag"

class DailySpendingPoint(BaseModel):
    date: str  # YYYY-MM-DD
    amount: float
    count: int = 0

class PeriodComparison(BaseModel):
    has_comparison: bool = False
    current_total: float = 0.0
    previous_total: float = 0.0
    amount_change: float = 0.0
    percentage_change: float = 0.0
    is_increase: bool = False
    message: str = "Keep tracking to see your trends."

class InsightsResponse(BaseModel):
    period: str
    currency: str = "INR"
    total_income: float = 0.0
    total_spent: float = 0.0
    net_remaining: float = 0.0
    has_income: bool = False
    transaction_count: int = 0
    expense_count: int = 0
    average_daily_spending: float = 0.0
    average_transaction_amount: float = 0.0
    is_mixed_currency: bool = False
    currency_totals: Dict[str, float] = Field(default_factory=dict)
    multi_currency_notice: Optional[str] = None
    top_category: Optional[CategoryBreakdownItem] = None
    category_breakdown: List[CategoryBreakdownItem] = Field(default_factory=list)
    daily_spending_trend: List[DailySpendingPoint] = Field(default_factory=list)
    previous_period_comparison: PeriodComparison = Field(default_factory=PeriodComparison)
    generated_insights: List[str] = Field(default_factory=list)
    structured_insights: List[StructuredInsight] = Field(default_factory=list)
