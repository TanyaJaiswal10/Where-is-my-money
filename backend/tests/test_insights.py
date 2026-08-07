from datetime import date, timedelta

def test_insights_empty_state(client):
    res = client.get("/insights?period=month")
    assert res.status_code == 200
    data = res.json()
    assert data["total_spent"] == 0.0
    assert data["total_income"] == 0.0
    assert data["net_remaining"] == 0.0
    assert data["transaction_count"] == 0
    assert data["category_breakdown"] == []
    assert data["previous_period_comparison"]["has_comparison"] is False

def test_insights_with_data(client):
    # 1. Create Income
    client.post("/transactions", json={
        "amount": 58000.0,
        "type": "income",
        "description": "Salary",
        "category": "Income"
    })

    # 2. Create Expenses
    client.post("/transactions", json={
        "amount": 8200.0,
        "type": "expense",
        "description": "Groceries and snacks",
        "category": "Food"
    })
    client.post("/transactions", json={
        "amount": 10000.0,
        "type": "expense",
        "description": "Rent",
        "category": "Housing"
    })

    res = client.get("/insights?period=month")
    assert res.status_code == 200
    data = res.json()

    assert data["total_income"] == 58000.0
    assert data["total_spent"] == 18200.0
    assert data["net_remaining"] == 39800.0
    assert data["has_income"] is True
    assert data["transaction_count"] == 3

    # Verify Category Breakdown & Ranking
    cats = data["category_breakdown"]
    assert len(cats) == 2
    assert cats[0]["category"] == "Housing"
    assert cats[0]["total_amount"] == 10000.0
    assert cats[0]["rank"] == 1
    assert cats[1]["category"] == "Food"
    assert cats[1]["total_amount"] == 8200.0
    assert cats[1]["rank"] == 2

    # Top Category
    assert data["top_category"]["category"] == "Housing"

    # Generated Insights
    assert len(data["generated_insights"]) > 0

def test_insights_period_filters(client):
    # Test week, month, 3months, custom filters
    for p in ["week", "month", "3months"]:
        res = client.get(f"/insights?period={p}")
        assert res.status_code == 200

    today_str = date.today().strftime("%Y-%m-%d")
    custom_res = client.get(f"/insights?period=custom&start_date={today_str}&end_date={today_str}")
    assert custom_res.status_code == 200
