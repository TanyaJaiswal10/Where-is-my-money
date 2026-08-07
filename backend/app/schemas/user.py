from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, field_validator
from app.core.currencies import is_valid_currency

class UserRegister(BaseModel):
    name: str = Field(..., min_length=2, max_length=100, description="Full Name")
    email: EmailStr = Field(..., description="Valid Email Address")
    password: str = Field(..., min_length=6, description="Password must be at least 6 characters")
    currency: Optional[str] = Field(default="INR", max_length=10)

    @field_validator("email")
    @classmethod
    def validate_email_clean(cls, value: str) -> str:
        return value.lower().strip()

    @field_validator("currency")
    @classmethod
    def validate_currency_code(cls, value: Optional[str]) -> str:
        if value:
            clean = value.upper().strip()
            if not is_valid_currency(clean):
                raise ValueError(f"Invalid currency ISO code '{value}'.")
            return clean
        return "INR"

class UserLogin(BaseModel):
    email: EmailStr = Field(..., description="User Email")
    password: str = Field(..., min_length=1, description="User Password")

    @field_validator("email")
    @classmethod
    def validate_email_clean(cls, value: str) -> str:
        return value.lower().strip()

class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    currency: Optional[str] = Field(None, max_length=10)

    @field_validator("currency")
    @classmethod
    def validate_currency_code(cls, value: Optional[str]) -> Optional[str]:
        if value:
            clean = value.upper().strip()
            if not is_valid_currency(clean):
                raise ValueError(f"Invalid currency ISO code '{value}'.")
            return clean
        return value

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    currency: str = "INR"
    created_at: datetime

    class Config:
        from_attributes = True

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
