from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.db.base import Base

class NotificationPreference(Base):
    __tablename__ = "notification_preferences"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True, index=True)
    recurring_reminders = Column(Boolean, nullable=False, default=True)
    budget_warnings = Column(Boolean, nullable=False, default=True)
    goal_reminders = Column(Boolean, nullable=False, default=True)
    weekly_summary = Column(Boolean, nullable=False, default=True)
    preferred_reminder_time = Column(String(10), nullable=False, default="09:00")
    user_timezone = Column(String(50), nullable=False, default="UTC")

    user = relationship("User", backref="notification_preference")

class NotificationLog(Base):
    __tablename__ = "notification_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    event_key = Column(String(255), nullable=False, index=True)  # e.g. "weekly_summary_2026_w32"
    type = Column(String(50), nullable=False)  # RECURRING, WEEKLY_SUMMARY
    title = Column(String(255), nullable=False)
    message = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship("User", backref="notification_logs")
