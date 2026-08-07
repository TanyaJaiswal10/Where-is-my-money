from typing import Optional, Dict, Any, List
from pydantic import BaseModel, Field
from app.schemas.transaction import TransactionResponse

class PendingContext(BaseModel):
    amount: Optional[float] = None
    type: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    currency: Optional[str] = None
    missing_field: Optional[str] = None

class ParseRequest(BaseModel):
    text: str = Field(..., min_length=1, description="Natural language transaction prompt e.g. '250 snacks'")
    currency: Optional[str] = Field(default="INR", max_length=10)
    confirm_unusual: Optional[bool] = Field(default=False, description="Set True to override unusual amount warning")
    override_amount: Optional[float] = Field(default=None, description="Explicit amount selected by user")
    pending_context: Optional[Dict[str, Any]] = Field(default=None, description="Pending transaction context for conversational follow-ups")

class ParseResponse(BaseModel):
    status: str = Field(..., description="'success', 'needs_clarification', or 'unusual_warning'")
    missing_field: Optional[str] = None
    message: Optional[str] = None
    question: Optional[str] = None
    confidence: Optional[float] = None
    original_amount: Optional[float] = None
    suggested_amount: Optional[float] = None
    category: Optional[str] = None
    description: Optional[str] = None
    currency: Optional[str] = None
    transaction: Optional[TransactionResponse] = None
    transactions: Optional[List[TransactionResponse]] = None
    pending_context: Optional[Dict[str, Any]] = None
