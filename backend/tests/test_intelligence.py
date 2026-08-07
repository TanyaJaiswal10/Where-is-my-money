import pytest
from datetime import datetime, date, timedelta, timezone
from app.services.intelligence_service import financial_intelligence_service
from app.schemas.intelligence import CategoryBaseline

def test_intelligence_insufficient_data():
    res = financial_intelligence_service.analyze_user_intelligence(db=None, user_id=999)
    assert res.data_quality_status == "no_data"
    assert len(res.insights) == 0

def test_anomaly_detection_logic():
    baseline = CategoryBaseline(
        category="Food",
        currency="INR",
        sample_count=10,
        average_amount=250.0,
        median_amount=240.0,
        min_amount=100.0,
        max_amount=500.0,
        typical_range_low=100.0,
        typical_range_high=600.0,
        monthly_average=7800.0,
        weekly_average=1800.0,
        trend_direction="stable",
        sufficient_data=True,
    )

    # Normal Transaction -> No Anomaly
    no_anomaly = financial_intelligence_service.check_anomaly(baseline, 350.0, "Food", "INR")
    assert no_anomaly is None

    # Unusual Transaction (₹8,500) -> Anomaly Detected!
    anomaly = financial_intelligence_service.check_anomaly(baseline, 8500.0, "Food", "INR")
    assert anomaly is not None
    assert anomaly.type == "ANOMALY"
    assert "8,500" in anomaly.description or "8500" in anomaly.description
    assert "Food" in anomaly.title

def test_recurring_expense_and_subscription_detection(client):
    reg_res = client.post("/auth/register", json={
        "name": "Recurring User",
        "email": "recurring@example.com",
        "password": "password123",
        "currency": "INR"
    })
    token = reg_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    now_utc = datetime.now(timezone.utc)
    d1 = now_utc - timedelta(days=60)
    d2 = now_utc - timedelta(days=30)

    # Create Netflix transactions 30 days apart
    client.post("/transactions", json={
        "amount": 649,
        "type": "expense",
        "description": "Netflix",
        "category": "Entertainment",
        "currency": "INR",
        "transaction_date": d1.isoformat()
    }, headers=headers)

    client.post("/transactions", json={
        "amount": 649,
        "type": "expense",
        "description": "Netflix",
        "category": "Entertainment",
        "currency": "INR",
        "transaction_date": d2.isoformat()
    }, headers=headers)

    # Fetch Insights
    insights_res = client.get("/insights", headers=headers)
    assert insights_res.status_code == 200
    data = insights_res.json()

    struct_insights = data.get("structured_insights", [])
    sub_insight = next((i for i in struct_insights if "Netflix" in i["title"]), None)
    assert sub_insight is not None
    assert sub_insight["type"] in ("SUBSCRIPTION", "RECURRING_EXPENSE")
    assert "649" in sub_insight["description"]

def test_insight_ranking():
    from app.schemas.intelligence import StructuredInsight

    i1 = StructuredInsight(type="SPENDING_PATTERN", title="Pattern", description="Low impact", importance_score=0.3, confidence=0.8)
    i2 = StructuredInsight(type="ANOMALY", title="Anomaly", description="High impact", importance_score=0.9, confidence=0.9)
    i3 = StructuredInsight(type="TREND", title="Trend", description="Medium impact", importance_score=0.7, confidence=0.8)

    ranked = financial_intelligence_service.rank_insights([i1, i2, i3], max_items=2)
    assert len(ranked) == 2
    assert ranked[0].title == "Anomaly"
    assert ranked[1].title == "Trend"
