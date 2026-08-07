from typing import List, Optional
from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.api.deps import get_optional_current_user as get_current_user
from app.models.user import User
from app.schemas.parse import ParseRequest, ParseResponse
from app.schemas.transaction import TransactionCreate
from app.services.parser_service import parser_service
from app.services.transaction_service import transaction_service
from app.services.validation_service import validation_service

router = APIRouter()

@router.post("/parse", response_model=ParseResponse)
def parse_and_create_transaction(
    payload: ParseRequest,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user),
):
    """
    Parses a natural language transaction prompt.
    Supports single or multiple transactions in one input.
    If valid, automatically creates transaction records in the database.
    """
    clean_text = payload.text.strip()
    if not clean_text:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Transaction text cannot be empty."
        )

    # 1. Conversational Undo Interruption Check
    lower = clean_text.lower()
    if lower in ("undo", "cancel", "delete last", "remove last", "undo transaction"):
        user_id = current_user.id if current_user else None
        last_tx = transaction_service.get_last_transaction(db=db, user_id=user_id)
        if last_tx:
            desc = last_tx.description or "Transaction"
            amt_str = f"{last_tx.currency} {last_tx.amount:,.2f}"
            transaction_service.delete(db=db, transaction_id=last_tx.id, user_id=user_id)
            return ParseResponse(
                status="undo_success",
                message=f"Transaction removed. Undid '{desc}' ({amt_str}).",
            )
        return ParseResponse(
            status="undo_success",
            message="No recent transaction found to undo.",
        )

    user_currency = current_user.currency if (current_user and hasattr(current_user, 'currency') and current_user.currency) else payload.currency
    user_id = current_user.id if current_user else None

    # 2. Parse natural language prompt
    parsed = parser_service.parse(
        text=clean_text,
        default_currency=user_currency,
        pending_context=payload.pending_context,
    )

    if parsed["status"] == "needs_clarification":
        return ParseResponse(
            status="needs_clarification",
            missing_field=parsed.get("missing_field"),
            message=parsed.get("message"),
            pending_context=parsed.get("pending_context"),
        )

    # 3. Handle Multi-Item Transactions
    if parsed.get("is_multiple") and parsed.get("items"):
        created_txs = []
        for item in parsed["items"]:
            item_amt = Decimal(str(item["amount"]))
            tx_create = TransactionCreate(
                amount=item_amt,
                type=item["type"],
                description=item["description"],
                category=item["category"],
                currency=item["currency"],
                user_id=str(user_id) if user_id else None,
            )
            db_tx = transaction_service.create(db=db, obj_in=tx_create, user_id=user_id)
            created_txs.append(db_tx)

        return ParseResponse(
            status="success",
            confidence=0.98,
            transaction=created_txs[0] if created_txs else None,
            transactions=created_txs,
        )

    # 4. Handle Single Transaction
    amount = Decimal(str(payload.override_amount)) if payload.override_amount else parsed["amount"]
    category = parsed["category"]
    tx_type = parsed["type"]
    description = parsed["description"]
    currency = parsed["currency"]

    if not payload.confirm_unusual and not payload.override_amount:
        validation_res = validation_service.validate_amount(
            db=db,
            amount=amount,
            category=category,
            user_id=str(user_id) if user_id else None,
        )

        if validation_res.get("is_unusual"):
            return ParseResponse(
                status="unusual_warning",
                confidence=parsed["confidence"],
                original_amount=validation_res["original_amount"],
                suggested_amount=validation_res["suggested_amount"],
                category=category,
                description=description,
                currency=currency,
                message=validation_res["message"],
                question=validation_res["question"],
            )

    tx_create = TransactionCreate(
        amount=amount,
        type=tx_type,
        description=description,
        category=category,
        currency=currency,
        user_id=str(user_id) if user_id else None,
    )

    db_tx = transaction_service.create(db=db, obj_in=tx_create, user_id=user_id)

    return ParseResponse(
        status="success",
        confidence=parsed["confidence"],
        transaction=db_tx,
        transactions=[db_tx],
    )
