import pytest

def test_user_registration_success(client):
    res = client.post("/auth/register", json={
        "name": "Alice Johnson",
        "email": "alice@example.com",
        "password": "securepassword123",
        "currency": "INR"
    })
    assert res.status_code == 201
    data = res.json()
    assert "access_token" in data
    assert data["user"]["email"] == "alice@example.com"
    assert data["user"]["name"] == "Alice Johnson"
    assert "password_hash" not in data["user"]

def test_user_registration_duplicate_email(client):
    client.post("/auth/register", json={
        "name": "Bob Smith",
        "email": "bob@example.com",
        "password": "password123"
    })

    # Duplicate registration attempt
    res = client.post("/auth/register", json={
        "name": "Bob Duplicate",
        "email": "bob@example.com",
        "password": "password123"
    })
    assert res.status_code == 400
    assert "already exists" in res.json()["detail"]

def test_login_success_and_failure(client):
    client.post("/auth/register", json={
        "name": "Charlie Brown",
        "email": "charlie@example.com",
        "password": "correctpassword123"
    })

    # Valid Login
    login_res = client.post("/auth/login", json={
        "email": "charlie@example.com",
        "password": "correctpassword123"
    })
    assert login_res.status_code == 200
    assert "access_token" in login_res.json()

    # Invalid Password
    bad_pass_res = client.post("/auth/login", json={
        "email": "charlie@example.com",
        "password": "wrongpassword"
    })
    assert bad_pass_res.status_code == 401

    # Unknown Email
    bad_email_res = client.post("/auth/login", json={
        "email": "unknown@example.com",
        "password": "password123"
    })
    assert bad_email_res.status_code == 401

def test_user_data_isolation(client):
    # 1. Register User 1
    u1_res = client.post("/auth/register", json={
        "name": "User One",
        "email": "user1@example.com",
        "password": "password123"
    })
    token1 = u1_res.json()["access_token"]
    headers1 = {"Authorization": f"Bearer {token1}"}

    # User 1 creates a transaction
    tx1_res = client.post("/transactions", json={
        "amount": 250.0,
        "type": "expense",
        "description": "User 1 Coffee",
        "category": "Food"
    }, headers=headers1)
    assert tx1_res.status_code == 201
    u1_tx_id = tx1_res.json()["id"]

    # 2. Register User 2
    u2_res = client.post("/auth/register", json={
        "name": "User Two",
        "email": "user2@example.com",
        "password": "password123"
    })
    token2 = u2_res.json()["access_token"]
    headers2 = {"Authorization": f"Bearer {token2}"}

    # 3. User 2 requests transactions -> should see 0 items (User 1's data isolated)
    u2_txs = client.get("/transactions", headers=headers2)
    assert u2_txs.status_code == 200
    assert len(u2_txs.json()) == 0

    # 4. User 2 attempts to fetch User 1's transaction by ID -> 404 Not Found
    u2_direct = client.get(f"/transactions/{u1_tx_id}", headers=headers2)
    assert u2_direct.status_code == 404
