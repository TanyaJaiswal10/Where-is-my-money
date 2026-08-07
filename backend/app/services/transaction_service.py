from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.transaction import Transaction
from app.schemas.transaction import TransactionCreate, TransactionUpdate

class TransactionService:
    @staticmethod
    def get_by_id(db: Session, transaction_id: int, user_id: Optional[int] = None) -> Optional[Transaction]:
        query = db.query(Transaction).filter(Transaction.id == transaction_id)
        if user_id is not None:
            query = query.filter(Transaction.user_id == user_id)
        return query.first()

    @staticmethod
    def get_last_transaction(db: Session, user_id: Optional[int] = None) -> Optional[Transaction]:
        query = db.query(Transaction)
        if user_id is not None:
            query = query.filter(Transaction.user_id == user_id)
        return query.order_by(Transaction.id.desc()).first()

    @staticmethod
    def get_all(db: Session, skip: int = 0, limit: int = 100, user_id: Optional[int] = None, order: str = "asc") -> List[Transaction]:
        query = db.query(Transaction)
        if user_id is not None:
            query = query.filter(Transaction.user_id == user_id)
        if order.lower() == "desc":
            query = query.order_by(Transaction.created_at.desc())
        else:
            query = query.order_by(Transaction.created_at.asc())
        return query.offset(skip).limit(limit).all()

    @staticmethod
    def create(db: Session, obj_in: TransactionCreate, user_id: Optional[int] = None) -> Transaction:
        effective_user_id = user_id if user_id is not None else obj_in.user_id
        kwargs = {
            "amount": obj_in.amount,
            "type": obj_in.type,
            "description": obj_in.description,
            "category": obj_in.category,
            "currency": obj_in.currency,
            "user_id": effective_user_id,
        }
        if obj_in.transaction_date is not None:
            kwargs["transaction_date"] = obj_in.transaction_date

        db_obj = Transaction(**kwargs)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    @staticmethod
    def update(db: Session, db_obj: Transaction, obj_in: TransactionUpdate) -> Transaction:
        update_data = obj_in.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    @staticmethod
    def delete(db: Session, transaction_id: int, user_id: Optional[int] = None) -> bool:
        query = db.query(Transaction).filter(Transaction.id == transaction_id)
        if user_id is not None:
            query = query.filter(Transaction.user_id == user_id)
        db_obj = query.first()
        if not db_obj:
            return False
        db.delete(db_obj)
        db.commit()
        return True

transaction_service = TransactionService()
