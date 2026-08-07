from sqlalchemy.orm import declarative_base

Base = declarative_base()

# Import all models for SQLAlchemy table metadata generation
from app.models.user import User                        # noqa: F401
from app.models.transaction import Transaction          # noqa: F401
from app.models.notification import NotificationPreference, NotificationLog  # noqa: F401
