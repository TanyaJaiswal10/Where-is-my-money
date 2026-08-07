from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.schemas.user import UserRegister, UserLogin, UserUpdate, UserResponse, TokenResponse
from app.core.security import hash_password, verify_password, create_access_token
from app.api.deps import get_current_user

router = APIRouter()

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(payload: UserRegister, db: Session = Depends(get_db)):
    """Registers a new user account with secure bcrypt password hashing."""
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An account with this email already exists."
        )

    user_obj = User(
        name=payload.name.strip(),
        email=payload.email.lower().strip(),
        password_hash=hash_password(payload.password),
        currency=payload.currency or "INR",
    )

    db.add(user_obj)
    db.commit()
    db.refresh(user_obj)

    token = create_access_token(subject=user_obj.id)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=UserResponse.model_validate(user_obj),
    )

@router.post("/login", response_model=TokenResponse, status_code=status.HTTP_200_OK)
def login(payload: UserLogin, db: Session = Depends(get_db)):
    """Authenticates user credentials and returns JWT token."""
    user = db.query(User).filter(User.email == payload.email.lower().strip()).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password."
        )

    token = create_access_token(subject=user.id)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )

@router.get("/me", response_model=UserResponse, status_code=status.HTTP_200_OK)
def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Returns profile of current authenticated user."""
    return UserResponse.model_validate(current_user)

@router.put("/me", response_model=UserResponse, status_code=status.HTTP_200_OK)
def update_current_user_profile(
    payload: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Updates user profile (e.g. default preferred currency, name). Does not alter historical transactions."""
    if payload.name:
        current_user.name = payload.name.strip()
    if payload.currency:
        current_user.currency = payload.currency.upper().strip()

    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return UserResponse.model_validate(current_user)

@router.post("/logout", status_code=status.HTTP_200_OK)
def logout():
    """Client token clearance endpoint."""
    return {"status": "success", "message": "Successfully logged out."}
