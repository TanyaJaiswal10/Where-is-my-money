from datetime import datetime, timezone
from decimal import Decimal
from typing import Optional
from pydantic import BaseModel, Field, field_validator, field_serializer, ConfigDict

class TransactionBase(BaseModel):
    amount: Decimal = Field(..., gt=0, description="Amount must be greater than 0")
    type: str = Field(..., description="Transaction type: 'expense' or 'income'")
    description: str = Field(..., min_length=1, max_length=255, description="Non-empty description")
    category: str = Field(..., min_length=1, max_length=50, description="Category name")
    currency: str = Field(default="INR", max_length=10)
    transaction_date: Optional[datetime] = None
    user_id: Optional[int] = None

    @field_validator("type")
    @classmethod
    def validate_type(cls, value: str) -> str:
        clean_value = value.lower().strip()
        if clean_value not in ("expense", "income"):
            raise ValueError("Type must be either 'expense' or 'income'")
        return clean_value

    @field_validator("description")
    @classmethod
    def validate_description(cls, value: str) -> str:
        clean_value = value.strip()
        if not clean_value:
            raise ValueError("Description cannot be empty or whitespace only")
        return clean_value

    @field_serializer("transaction_date", mode="plain", check_fields=False)
    def serialize_transaction_date(self, dt: Optional[datetime]) -> Optional[str]:
        if dt is None:
            return None
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.isoformat()

class TransactionCreate(TransactionBase):
    pass

class TransactionUpdate(BaseModel):
    amount: Optional[Decimal] = Field(None, gt=0)
    type: Optional[str] = None
    description: Optional[str] = Field(None, min_length=1, max_length=255)
    category: Optional[str] = None
    currency: Optional[str] = None
    transaction_date: Optional[datetime] = None

    @field_validator("type")
    @classmethod
    def validate_type(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return value
        clean_value = value.lower().strip()
        if clean_value not in ("expense", "income"):
            raise ValueError("Type must be either 'expense' or 'income'")
        return clean_value

    @field_serializer("transaction_date", mode="plain", check_fields=False)
    def serialize_transaction_date(self, dt: Optional[datetime]) -> Optional[str]:
        if dt is None:
            return None
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.isoformat()

class TransactionResponse(TransactionBase):
    id: int
    created_at: datetime

    @field_serializer("created_at", mode="plain", check_fields=False)
    def serialize_created_at(self, dt: Optional[datetime]) -> Optional[str]:
        if dt is None:
            return None
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.isoformat()

    model_config = ConfigDict(from_attributes=True)
