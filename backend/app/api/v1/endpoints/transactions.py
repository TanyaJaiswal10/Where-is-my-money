from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.user import User
from app.api.deps import get_optional_current_user
from app.schemas.transaction import TransactionCreate, TransactionUpdate, TransactionResponse
from app.services.transaction_service import transaction_service

router = APIRouter()

@router.post("", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
def create_transaction(
    transaction_in: TransactionCreate,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
):
    """Create a new expense or income transaction scoped to current user."""
    user_id = current_user.id if current_user else None
    return transaction_service.create(db=db, obj_in=transaction_in, user_id=user_id)

@router.post("/undo-latest", status_code=status.HTTP_200_OK)
def undo_latest_transaction(
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
):
    """Reverses/deletes the most recent active transaction for the authenticated user."""
    user_id = current_user.id if current_user else None
    recent_txs = transaction_service.get_all(db=db, limit=1, user_id=user_id)
    if not recent_txs:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No recent transactions found to undo",
        )
    latest_tx = recent_txs[0]
    transaction_service.delete(db=db, transaction_id=latest_tx.id, user_id=user_id)
    return {
        "status": "success",
        "message": f"Transaction removed ({latest_tx.currency} {latest_tx.amount:g}).",
        "deleted_id": latest_tx.id,
    }

@router.get("", response_model=List[TransactionResponse])
def read_transactions(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
):
    """Retrieve transactions scoped to current user."""
    user_id = current_user.id if current_user else None
    return transaction_service.get_all(db=db, skip=skip, limit=limit, user_id=user_id)

@router.get("/{id}", response_model=TransactionResponse)
def read_transaction(
    id: int,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
):
    """Retrieve a single transaction by ID scoped to current user."""
    user_id = current_user.id if current_user else None
    db_obj = transaction_service.get_by_id(db=db, transaction_id=id, user_id=user_id)
    if not db_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transaction with ID {id} not found",
        )
    return db_obj

@router.put("/{id}", response_model=TransactionResponse)
def update_transaction(
    id: int,
    transaction_in: TransactionUpdate,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
):
    """Update an existing transaction owned by current user."""
    user_id = current_user.id if current_user else None
    db_obj = transaction_service.get_by_id(db=db, transaction_id=id, user_id=user_id)
    if not db_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transaction with ID {id} not found",
        )
    return transaction_service.update(db=db, db_obj=db_obj, obj_in=transaction_in)

@router.delete("/{id}", status_code=status.HTTP_200_OK)
def delete_transaction(
    id: int,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_current_user),
):
    """Delete a transaction by ID owned by current user."""
    user_id = current_user.id if current_user else None
    success = transaction_service.delete(db=db, transaction_id=id, user_id=user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Transaction with ID {id} not found",
        )
    return {"status": "success", "message": f"Transaction {id} deleted successfully"}
