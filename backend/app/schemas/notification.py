from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict

class NotificationPreferenceBase(BaseModel):
    recurring_reminders: bool = Field(default=True)
    budget_warnings: bool = Field(default=True)
    goal_reminders: bool = Field(default=True)
    weekly_summary: bool = Field(default=True)
    preferred_reminder_time: str = Field(default="09:00", pattern=r"^\d{2}:\d{2}$")
    user_timezone: str = Field(default="UTC", max_length=50)

class NotificationPreferenceUpdate(BaseModel):
    recurring_reminders: Optional[bool] = None
    budget_warnings: Optional[bool] = None
    goal_reminders: Optional[bool] = None
    weekly_summary: Optional[bool] = None
    preferred_reminder_time: Optional[str] = Field(None, pattern=r"^\d{2}:\d{2}$")
    user_timezone: Optional[str] = None

class NotificationPreferenceResponse(NotificationPreferenceBase):
    id: int
    user_id: int

    model_config = ConfigDict(from_attributes=True)

class NotificationLogResponse(BaseModel):
    id: int
    user_id: int
    event_key: str
    type: str
    title: str
    message: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
