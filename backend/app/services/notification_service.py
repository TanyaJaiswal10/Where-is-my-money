from datetime import datetime, date, timedelta, timezone
from typing import List, Optional
from sqlalchemy.orm import Session

from app.models.notification import NotificationPreference, NotificationLog
from app.models.transaction import Transaction
from app.core.currencies import format_currency_amount
from app.schemas.notification import (
    NotificationPreferenceUpdate,
    NotificationLogResponse,
)

class NotificationService:
    @staticmethod
    def get_user_preferences(db: Session, user_id: int) -> NotificationPreference:
        pref = db.query(NotificationPreference).filter(
            NotificationPreference.user_id == user_id
        ).first()

        if not pref:
            pref = NotificationPreference(
                user_id=user_id,
                recurring_reminders=False,
                budget_warnings=False,
                goal_reminders=False,
                weekly_summary=True,
                preferred_reminder_time="09:00",
                user_timezone="UTC",
            )
            db.add(pref)
            db.commit()
            db.refresh(pref)

        return pref

    @staticmethod
    def update_user_preferences(
        db: Session, user_id: int, obj_in: NotificationPreferenceUpdate
    ) -> NotificationPreference:
        pref = NotificationService.get_user_preferences(db, user_id)
        update_data = obj_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(pref, field, value)
        db.add(pref)
        db.commit()
        db.refresh(pref)
        return pref

    @staticmethod
    def is_event_logged(db: Session, user_id: int, event_key: str) -> bool:
        """Checks if a notification event key has already been logged for deduplication."""
        existing = db.query(NotificationLog).filter(
            NotificationLog.user_id == user_id,
            NotificationLog.event_key == event_key,
        ).first()
        return existing is not None

    @staticmethod
    def log_notification(
        db: Session,
        user_id: int,
        event_key: str,
        type_: str,
        title: str,
        message: str,
    ) -> Optional[NotificationLog]:
        """Logs a notification event if it hasn't been sent already (deduplicated)."""
        if NotificationService.is_event_logged(db, user_id, event_key):
            return None

        log = NotificationLog(
            user_id=user_id,
            event_key=event_key,
            type=type_,
            title=title,
            message=message,
        )
        db.add(log)
        db.commit()
        db.refresh(log)
        return log

    @staticmethod
    def get_user_notifications(db: Session, user_id: int, limit: int = 50) -> List[NotificationLog]:
        """Retrieves history of user notifications."""
        return db.query(NotificationLog).filter(
            NotificationLog.user_id == user_id
        ).order_by(NotificationLog.created_at.desc()).limit(limit).all()

    @staticmethod
    def check_and_generate_all_notifications(db: Session, user_id: int) -> List[NotificationLog]:
        """
        Runs deduplicated notification generators based on user preferences:
        1. Weekly summary
        """
        pref = NotificationService.get_user_preferences(db, user_id)
        generated: List[NotificationLog] = []

        today = date.today()

        # Weekly Summary
        if pref.weekly_summary and today.weekday() == 6:  # Sunday
            iso_year, iso_week, _ = today.isocalendar()
            event_key = f"weekly_summary_{iso_year}_w{iso_week}"

            if not NotificationService.is_event_logged(db, user_id, event_key):
                week_start = today - timedelta(days=6)
                week_txs = db.query(Transaction).filter(
                    Transaction.user_id == user_id,
                    Transaction.type == "expense",
                    Transaction.transaction_date >= datetime.combine(week_start, datetime.min.time(), tzinfo=timezone.utc),
                ).all()

                if len(week_txs) >= 2:
                    total_spent = sum(float(tx.amount) for tx in week_txs)
                    currency = week_txs[0].currency or "INR"
                    spent_str = format_currency_amount(total_spent, currency)
                    log = NotificationService.log_notification(
                        db=db,
                        user_id=user_id,
                        event_key=event_key,
                        type_="WEEKLY_SUMMARY",
                        title="Your week with money",
                        message=f"You spent {spent_str} across {len(week_txs)} transactions this week.",
                    )
                    if log:
                        generated.append(log)

        return generated

notification_service = NotificationService()
