from datetime import datetime
from typing import Optional, Dict, Any, List
from pydantic import BaseModel, Field

class StructuredInsight(BaseModel):
    type: str  # ANOMALY, TREND, COMPARISON, RECURRING_EXPENSE, SUBSCRIPTION, BUDGET_RISK, GOAL_PROGRESS, SPENDING_PATTERN
    title: str
    description: str
    importance_score: float = Field(..., ge=0.0, le=1.0)
    confidence: float = Field(..., ge=0.0, le=1.0)
    currency: str = "INR"
    created_at: datetime = Field(default_factory=datetime.utcnow)
    supporting_data: Dict[str, Any] = Field(default_factory=dict)

class CategoryBaseline(BaseModel):
    category: str
    currency: str = "INR"
    sample_count: int = 0
    average_amount: float = 0.0
    median_amount: float = 0.0
    min_amount: float = 0.0
    max_amount: float = 0.0
    typical_range_low: float = 0.0
    typical_range_high: float = 0.0
    monthly_average: float = 0.0
    weekly_average: float = 0.0
    trend_direction: str = "stable"  # increasing, decreasing, stable
    sufficient_data: bool = False

class RecurringExpenseItem(BaseModel):
    description: str
    average_amount: float
    currency: str = "INR"
    frequency_days: int = 30
    occurrences: int = 2
    is_subscription: bool = False
    confidence: float = 0.8
    last_date: str

class FinancialIntelligenceResponse(BaseModel):
    insights: List[StructuredInsight] = Field(default_factory=list)
    baselines: List[CategoryBaseline] = Field(default_factory=list)
    recurring_expenses: List[RecurringExpenseItem] = Field(default_factory=list)
    data_quality_status: str = "sufficient"  # no_data, insufficient, sufficient
