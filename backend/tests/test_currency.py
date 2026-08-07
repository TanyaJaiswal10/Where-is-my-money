import pytest
from app.core.currencies import format_currency_amount, get_currency_metadata, is_valid_currency
from app.services.parser_service import parser_service

def test_currency_metadata_and_formatting():
    assert is_valid_currency("INR") is True
    assert is_valid_currency("USD") is True
    assert is_valid_currency("JPY") is True
    assert is_valid_currency("INVALID") is False

    assert format_currency_amount(1250.50, "INR") == "₹1,250.50"
    assert format_currency_amount(1250.50, "USD") == "$1,250.50"
    assert format_currency_amount(1250.50, "GBP") == "£1,250.50"
    assert format_currency_amount(1250, "JPY") == "¥1,250"

def test_parser_explicit_currency_recognition():
    # Explicit INR
    res_inr = parser_service.parse("₹250 snacks", default_currency="USD")
    assert res_inr["currency"] == "INR"
    assert res_inr["amount"] == 250

    # Explicit USD
    res_usd = parser_service.parse("$20 coffee", default_currency="INR")
    assert res_usd["currency"] == "USD"
    assert res_usd["amount"] == 20

    # Explicit GBP
    res_gbp = parser_service.parse("£15 lunch", default_currency="INR")
    assert res_gbp["currency"] == "GBP"
    assert res_gbp["amount"] == 15

    # Fallback to User Default Currency
    res_def = parser_service.parse("500 lunch", default_currency="USD")
    assert res_def["currency"] == "USD"
    assert res_def["amount"] == 500

def test_user_currency_change(client):
    # 1. Register user with INR
    reg_res = client.post("/auth/register", json={
        "name": "Currency Tester",
        "email": "curr@example.com",
        "password": "password123",
        "currency": "INR"
    })
    token = reg_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Add an INR transaction
    tx1 = client.post("/transactions", json={
        "amount": 250,
        "type": "expense",
        "description": "Snacks",
        "category": "Food",
        "currency": "INR"
    }, headers=headers)
    assert tx1.json()["currency"] == "INR"

    # 3. Change user default currency to USD
    up_res = client.put("/auth/me", json={"currency": "USD"}, headers=headers)
    assert up_res.status_code == 200
    assert up_res.json()["currency"] == "USD"

    # 4. Old transaction preserves INR
    old_tx = client.get(f"/transactions/{tx1.json()['id']}", headers=headers)
    assert old_tx.json()["currency"] == "INR"

    # 5. Parse new transaction without explicit symbol -> defaults to USD
    parse_res = client.post("/transactions/parse", json={"text": "500 lunch"}, headers=headers)
    assert parse_res.status_code == 200
    assert parse_res.json()["transaction"]["currency"] == "USD"

def test_mixed_currency_insights_safety(client):
    reg_res = client.post("/auth/register", json={
        "name": "Mixed Currency User",
        "email": "mixed@example.com",
        "password": "password123",
        "currency": "INR"
    })
    token = reg_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # Add 1 INR transaction and 1 USD transaction
    client.post("/transactions", json={
        "amount": 1000,
        "type": "expense",
        "description": "INR Expense",
        "category": "Food",
        "currency": "INR"
    }, headers=headers)

    client.post("/transactions", json={
        "amount": 50,
        "type": "expense",
        "description": "USD Expense",
        "category": "Shopping",
        "currency": "USD"
    }, headers=headers)

    insights_res = client.get("/insights", headers=headers)
    assert insights_res.status_code == 200
    data = insights_res.json()
    assert data["is_mixed_currency"] is True
    assert "currency_totals" in data
    assert data["currency_totals"]["INR"] == 1000.0
    assert data["currency_totals"]["USD"] == 50.0
    assert "different currencies" in data["multi_currency_notice"]
