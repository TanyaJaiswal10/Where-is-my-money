from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.api.deps import get_current_user
from app.models.user import User
from app.schemas.notification import (
    NotificationPreferenceUpdate,
    NotificationPreferenceResponse,
    NotificationLogResponse,
)
from app.services.notification_service import notification_service

router = APIRouter()

@router.get("/notification-preferences", response_model=NotificationPreferenceResponse)
def get_notification_preferences(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Retrieve notification preferences for authenticated user."""
    return notification_service.get_user_preferences(db=db, user_id=current_user.id)

@router.put("/notification-preferences", response_model=NotificationPreferenceResponse)
def update_notification_preferences(
    pref_in: NotificationPreferenceUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update notification preferences for authenticated user."""
    return notification_service.update_user_preferences(db=db, user_id=current_user.id, obj_in=pref_in)

@router.get("/notifications", response_model=List[NotificationLogResponse])
def get_notifications(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Generates deduplicated pending notifications and retrieves recent notification log history."""
    notification_service.check_and_generate_all_notifications(db=db, user_id=current_user.id)
    return notification_service.get_user_notifications(db=db, user_id=current_user.id)
