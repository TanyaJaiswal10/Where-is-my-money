"""Initial database schema for Where's My Money

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-08-06

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

revision: str = '001_initial_schema'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    # Users table
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('email', sa.String(length=255), nullable=False),
        sa.Column('hashed_password', sa.String(length=255), nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('currency', sa.String(length=10), nullable=False, server_default='INR'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index('ix_users_email', 'users', ['email'], unique=True)
    op.create_index('ix_users_id', 'users', ['id'], unique=False)

    # Plans table
    op.create_table(
        'plans',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('target_budget', sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column('currency', sa.String(length=10), nullable=False, server_default='INR'),
        sa.Column('start_date', sa.Date(), nullable=True),
        sa.Column('end_date', sa.Date(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=True),
    )

    # Transactions table
    op.create_table(
        'transactions',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('amount', sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column('type', sa.String(length=20), nullable=False),
        sa.Column('description', sa.String(length=255), nullable=False),
        sa.Column('category', sa.String(length=50), nullable=False),
        sa.Column('currency', sa.String(length=10), nullable=False, server_default='INR'),
        sa.Column('transaction_date', sa.DateTime(timezone=True), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=True),
        sa.Column('plan_id', sa.Integer(), sa.ForeignKey('plans.id', ondelete='SET NULL'), nullable=True),
    )
    op.create_index('ix_transactions_user_id', 'transactions', ['user_id'], unique=False)

    # Budgets table
    op.create_table(
        'budgets',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('category', sa.String(length=50), nullable=False),
        sa.Column('amount', sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column('currency', sa.String(length=10), nullable=False, server_default='INR'),
        sa.Column('period', sa.String(length=20), nullable=False, server_default='monthly'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=True),
    )

    # Goals table
    op.create_table(
        'goals',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('target_amount', sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column('current_amount', sa.Numeric(precision=12, scale=2), nullable=False, server_default='0.00'),
        sa.Column('currency', sa.String(length=10), nullable=False, server_default='INR'),
        sa.Column('deadline', sa.Date(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=True),
    )

    # Recurring Expenses table
    op.create_table(
        'recurring_expenses',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('description', sa.String(length=255), nullable=False),
        sa.Column('category', sa.String(length=50), nullable=False, server_default='Bills'),
        sa.Column('amount', sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column('currency', sa.String(length=10), nullable=False, server_default='INR'),
        sa.Column('frequency', sa.String(length=20), nullable=False, server_default='monthly'),
        sa.Column('next_occurrence', sa.DateTime(timezone=True), nullable=False),
        sa.Column('last_occurrence', sa.DateTime(timezone=True), nullable=True),
        sa.Column('active', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    )

    # Notification Preferences table
    op.create_table(
        'notification_preferences',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('recurring_reminders', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('budget_warnings', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('goal_reminders', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('weekly_summary', sa.Boolean(), nullable=False, server_default='true'),
        sa.Column('preferred_reminder_time', sa.String(length=10), nullable=False, server_default='09:00'),
        sa.Column('user_timezone', sa.String(length=50), nullable=False, server_default='UTC'),
    )

    # Notification Logs table
    op.create_table(
        'notification_logs',
        sa.Column('id', sa.Integer(), nullable=False, primary_key=True),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('event_key', sa.String(length=255), nullable=False),
        sa.Column('type', sa.String(length=50), nullable=False),
        sa.Column('title', sa.String(length=255), nullable=False),
        sa.Column('message', sa.Text(), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    )

def downgrade() -> None:
    op.drop_table('notification_logs')
    op.drop_table('notification_preferences')
    op.drop_table('recurring_expenses')
    op.drop_table('goals')
    op.drop_table('budgets')
    op.drop_table('transactions')
    op.drop_table('plans')
    op.drop_table('users')
