from fastapi import APIRouter
from app.api.v1.endpoints import auth, transactions, parse, insights, notifications

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(transactions.router, prefix="/transactions", tags=["transactions"])
api_router.include_router(parse.router, prefix="/transactions", tags=["transactions-parse"])
api_router.include_router(insights.router, prefix="/insights", tags=["insights"])
api_router.include_router(notifications.router, tags=["notifications"])
