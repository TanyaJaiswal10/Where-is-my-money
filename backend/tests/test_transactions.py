def test_create_transaction(client):
    payload = {
        "amount": 250.00,
        "type": "expense",
        "description": "snacks",
        "category": "Food",
        "currency": "INR"
    }
    response = client.post("/transactions", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["amount"] == "250.00"
    assert data["type"] == "expense"
    assert data["description"] == "snacks"
    assert data["category"] == "Food"
    assert "id" in data

def test_get_transactions(client):
    # Create sample transaction first
    payload = {
        "amount": 500.00,
        "type": "expense",
        "description": "uber",
        "category": "Transport",
        "currency": "INR"
    }
    client.post("/transactions", json=payload)

    response = client.get("/transactions")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_get_single_transaction(client):
    payload = {
        "amount": 1200.00,
        "type": "expense",
        "description": "rent",
        "category": "Housing",
        "currency": "INR"
    }
    create_res = client.post("/transactions", json=payload)
    item_id = create_res.json()["id"]

    response = client.get(f"/transactions/{item_id}")
    assert response.status_code == 200
    assert response.json()["id"] == item_id

def test_update_transaction(client):
    payload = {
        "amount": 300.00,
        "type": "expense",
        "description": "lunch",
        "category": "Food",
        "currency": "INR"
    }
    create_res = client.post("/transactions", json=payload)
    item_id = create_res.json()["id"]

    update_payload = {"amount": 350.00, "category": "Dining"}
    response = client.put(f"/transactions/{item_id}", json=update_payload)
    assert response.status_code == 200
    assert response.json()["amount"] == "350.00"
    assert response.json()["category"] == "Dining"

def test_delete_transaction(client):
    payload = {
        "amount": 100.00,
        "type": "expense",
        "description": "coffee",
        "category": "Food",
        "currency": "INR"
    }
    create_res = client.post("/transactions", json=payload)
    item_id = create_res.json()["id"]

    del_res = client.delete(f"/transactions/{item_id}")
    assert del_res.status_code == 200

    get_res = client.get(f"/transactions/{item_id}")
    assert get_res.status_code == 404

def test_invalid_transaction_input(client):
    # Test invalid amount (<= 0)
    res_bad_amount = client.post("/transactions", json={
        "amount": -50,
        "type": "expense",
        "description": "test",
        "category": "Food"
    })
    assert res_bad_amount.status_code == 422

    # Test invalid type
    res_bad_type = client.post("/transactions", json={
        "amount": 100,
        "type": "invalid_type",
        "description": "test",
        "category": "Food"
    })
    assert res_bad_type.status_code == 422

    # Test empty description
    res_bad_desc = client.post("/transactions", json={
        "amount": 100,
        "type": "expense",
        "description": "   ",
        "category": "Food"
    })
    assert res_bad_desc.status_code == 422
