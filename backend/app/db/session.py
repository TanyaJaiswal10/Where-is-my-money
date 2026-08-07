import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

logger = logging.getLogger(__name__)

db_url = settings.get_database_url()

# Fallback mechanism if PostgreSQL is unavailable locally during development
try:
    if db_url.startswith("postgresql"):
        engine = create_engine(db_url, pool_pre_ping=True)
        # Test connection
        with engine.connect() as conn:
            pass
    else:
        engine = create_engine(db_url, connect_args={"check_same_thread": False})
except Exception as e:
    logger.warning(f"Failed to connect to PostgreSQL ({e}). Falling back to local SQLite database.")
    db_url = "sqlite:///./where_is_my_money.db"
    engine = create_engine(db_url, connect_args={"check_same_thread": False})

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
