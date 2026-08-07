from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Numeric, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base import Base

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    amount = Column(Numeric(12, 2), nullable=False)
    type = Column(String(20), nullable=False)         # 'expense' or 'income'
    description = Column(String(255), nullable=False)
    category = Column(String(50), nullable=False)
    currency = Column(String(10), nullable=False, default="INR")
    transaction_date = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))
    created_at = Column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc))

    user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)

    user = relationship("User", back_populates="transactions")
