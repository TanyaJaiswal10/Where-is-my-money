def test_undo_transaction(client):
    # 1. Create transaction
    create_res = client.post("/transactions", json={
        "amount": 250.00,
        "type": "expense",
        "description": "snacks",
        "category": "Food"
    })
    assert create_res.status_code == 201
    tx_id = create_res.json()["id"]

    # 2. Undo / Delete
    del_res = client.delete(f"/transactions/{tx_id}")
    assert del_res.status_code == 200

    # 3. Verify it no longer exists
    get_res = client.get(f"/transactions/{tx_id}")
    assert get_res.status_code == 404

def test_conversational_undo_command(client):
    client.post("/transactions", json={
        "amount": 500.00,
        "type": "expense",
        "description": "uber",
        "category": "Transport"
    })

    # Call parse with "undo"
    undo_res = client.post("/transactions/parse", json={"text": "undo"})
    assert undo_res.status_code == 200
    assert undo_res.json()["status"] == "undo_success"
    assert "Transaction removed" in undo_res.json()["message"]

def test_edit_transaction(client):
    create_res = client.post("/transactions", json={
        "amount": 250.00,
        "type": "expense",
        "description": "snacks",
        "category": "Food"
    })
    tx_id = create_res.json()["id"]

    # Edit amount, description, category
    update_res = client.put(f"/transactions/{tx_id}", json={
        "amount": 300.00,
        "description": "healthy snacks",
        "category": "Food"
    })
    assert update_res.status_code == 200
    data = update_res.json()
    assert data["amount"] == "300.00"
    assert data["description"] == "healthy snacks"

def test_category_correction(client):
    create_res = client.post("/transactions", json={
        "amount": 500.00,
        "type": "expense",
        "description": "snacks",
        "category": "Food"
    })
    tx_id = create_res.json()["id"]

    # One-tap change category to Shopping
    change_res = client.put(f"/transactions/{tx_id}", json={"category": "Shopping"})
    assert change_res.status_code == 200
    assert change_res.json()["category"] == "Shopping"

def test_smart_validation_normal_vs_unusual(client):
    # Normal transaction: ₹250 Food -> success
    normal_res = client.post("/transactions/parse", json={"text": "250 snacks"})
    assert normal_res.status_code == 200
    assert normal_res.json()["status"] == "success"

    # Unusual transaction: ₹25,000 Food -> unusual_warning
    unusual_res = client.post("/transactions/parse", json={"text": "25000 snacks"})
    assert unusual_res.status_code == 200
    warn_data = unusual_res.json()
    assert warn_data["status"] == "unusual_warning"
    assert warn_data["suggested_amount"] == 250.0
    assert warn_data["original_amount"] == 25000.0
    assert "unusually high for Food" in warn_data["message"]
    assert "Did you mean" in warn_data["question"] and "250" in warn_data["question"]

def test_smart_validation_override(client):
    # User overrides warning by choosing original amount ₹25,000
    override_res = client.post("/transactions/parse", json={
        "text": "25000 snacks",
        "confirm_unusual": True,
        "override_amount": 25000.0
    })
    assert override_res.status_code == 200
    data = override_res.json()
    assert data["status"] == "success"
    assert data["transaction"]["amount"] == "25000.00"
