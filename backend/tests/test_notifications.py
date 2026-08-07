import pytest

def test_notification_preferences_and_deduplication(client):
    reg_res = client.post("/auth/register", json={
        "name": "Notification User",
        "email": "notif@example.com",
        "password": "password123",
        "currency": "INR"
    })
    token = reg_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Fetch default preferences
    pref_res = client.get("/notification-preferences", headers=headers)
    assert pref_res.status_code == 200
    pref = pref_res.json()
    assert pref["weekly_summary"] is True

    # 2. Update preferences
    upd_pref = client.put("/notification-preferences", json={
        "preferred_reminder_time": "10:30",
        "user_timezone": "Asia/Kolkata"
    }, headers=headers)
    assert upd_pref.status_code == 200
    assert upd_pref.json()["preferred_reminder_time"] == "10:30"
    assert upd_pref.json()["user_timezone"] == "Asia/Kolkata"

    # 3. Fetch notifications
    notif_res = client.get("/notifications", headers=headers)
    assert notif_res.status_code == 200
    logs = notif_res.json()
    assert isinstance(logs, list)

    # 4. Fetch notifications again -> Deduplication check
    notif_res2 = client.get("/notifications", headers=headers)
    assert len(notif_res2.json()) == len(logs)
