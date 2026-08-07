from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.core.security import decode_access_token

security = HTTPBearer(auto_error=False)

def get_current_user(
    auth_credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    """
    Dependency that enforces JWT authentication.
    Derives current user strictly from the token signature and payload.
    """
    if not auth_credentials or not auth_credentials.credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required. Please log in.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = auth_credentials.credentials
    user_id_str = decode_access_token(token)

    if not user_id_str:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token. Please log in again.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user_id = int(user_id_str)
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User account not found.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user

def get_optional_current_user(
    auth_credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: Session = Depends(get_db),
) -> Optional[User]:
    """Optional dependency that returns User if authenticated, else None."""
    if not auth_credentials or not auth_credentials.credentials:
        return None
    token = auth_credentials.credentials
    user_id_str = decode_access_token(token)
    if not user_id_str:
        return None
    try:
        user_id = int(user_id_str)
        return db.query(User).filter(User.id == user_id).first()
    except Exception:
        return None
