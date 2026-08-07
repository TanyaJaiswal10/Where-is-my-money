from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.db.session import get_db

router = APIRouter()

@router.get("/health")
def health_check(db: Session = Depends(get_db)):
    """Health check verifying FastAPI server and database connectivity."""
    db_healthy = False
    try:
        db.execute(text("SELECT 1"))
        db_healthy = True
    except Exception:
        db_healthy = False

    return {
        "status": "ok" if db_healthy else "degraded",
        "database": "connected" if db_healthy else "disconnected",
        "version": "1.0.0",
    }
