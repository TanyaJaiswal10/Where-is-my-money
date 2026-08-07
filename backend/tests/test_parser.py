import pytest
from app.services.parser_service import parser_service

def test_parse_250_snacks():
    res = parser_service.parse("250 snacks")
    assert res["status"] == "success"
    assert res["amount"] == 250
    assert res["type"] == "expense"
    assert res["category"] == "Food"

def test_parse_rupee_500_uber():
    res = parser_service.parse("₹500 uber")
    assert res["status"] == "success"
    assert res["amount"] == 500
    assert res["type"] == "expense"
    assert res["category"] == "Transport"
    assert res["currency"] == "INR"

def test_parse_1200_rent():
    res = parser_service.parse("1200 rent")
    assert res["status"] == "success"
    assert res["amount"] == 1200
    assert res["type"] == "expense"
    assert res["category"] == "Housing"

def test_parse_paid_300_for_lunch():
    res = parser_service.parse("paid 300 for lunch")
    assert res["status"] == "success"
    assert res["amount"] == 300
    assert res["type"] == "expense"
    assert res["category"] == "Food"

def test_parse_missing_amount_snacks():
    res = parser_service.parse("snacks")
    assert res["status"] == "needs_clarification"
    assert res["missing_field"] == "amount"

def test_parse_missing_description_250():
    res = parser_service.parse("250")
    assert res["status"] == "needs_clarification"
    assert res["missing_field"] == "description"

# ==================================================
# MANDATORY USER TEST CASES FOR INCOME INTENT
# ==================================================

def test_income_salary_50000():
    res = parser_service.parse("salary 50000")
    assert res["status"] == "success"
    assert res["amount"] == 50000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_got_paid_5000():
    res = parser_service.parse("got paid 5000")
    assert res["status"] == "success"
    assert res["amount"] == 5000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_received_3500_from_client():
    res = parser_service.parse("received 3500 from client")
    assert res["status"] == "success"
    assert res["amount"] == 3500
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_client_paid_me_5000():
    res = parser_service.parse("client paid me 5000")
    assert res["status"] == "success"
    assert res["amount"] == 5000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_company_paid_me_10000():
    res = parser_service.parse("company paid me 10000")
    assert res["status"] == "success"
    assert res["amount"] == 10000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_rahul_sent_me_2000():
    res = parser_service.parse("Rahul sent me 2000")
    assert res["status"] == "success"
    assert res["amount"] == 2000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_salary_credited_50000():
    res = parser_service.parse("salary credited 50000")
    assert res["status"] == "success"
    assert res["amount"] == 50000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_freelance_income_8000():
    res = parser_service.parse("freelance income 8000")
    assert res["status"] == "success"
    assert res["amount"] == 8000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_5k_received():
    res = parser_service.parse("₹5k received")
    assert res["status"] == "success"
    assert res["amount"] == 5000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_income_bonus_20000():
    res = parser_service.parse("bonus 20000")
    assert res["status"] == "success"
    assert res["amount"] == 20000
    assert res["type"] == "income"
    assert res["category"] == "Income"

# ==================================================
# MANDATORY USER TEST CASES FOR EXPENSE INTENT
# ==================================================

def test_expense_55_noodles():
    res = parser_service.parse("55 noodles")
    assert res["status"] == "success"
    assert res["amount"] == 55
    assert res["type"] == "expense"
    assert res["category"] == "Food"

def test_expense_300_dinner():
    res = parser_service.parse("300 dinner")
    assert res["status"] == "success"
    assert res["amount"] == 300
    assert res["type"] == "expense"
    assert res["category"] == "Food"

def test_expense_100_bus():
    res = parser_service.parse("100 bus")
    assert res["status"] == "success"
    assert res["amount"] == 100
    assert res["type"] == "expense"
    assert res["category"] == "Transport"

def test_expense_500_shirt():
    res = parser_service.parse("500 shirt")
    assert res["status"] == "success"
    assert res["amount"] == 500
    assert res["type"] == "expense"
    assert res["category"] == "Shopping"

def test_expense_spent_1200_on_groceries():
    res = parser_service.parse("spent 1200 on groceries")
    assert res["status"] == "success"
    assert res["amount"] == 1200
    assert res["type"] == "expense"
    assert res["category"] == "Food"

def test_expense_paid_2500_for_rent():
    res = parser_service.parse("paid 2500 for rent")
    assert res["status"] == "success"
    assert res["amount"] == 2500
    assert res["type"] == "expense"
    assert res["category"] == "Housing"

def test_expense_5k_shopping():
    res = parser_service.parse("₹5k shopping")
    assert res["status"] == "success"
    assert res["amount"] == 5000
    assert res["type"] == "expense"
    assert res["category"] == "Shopping"

def test_expense_1_5k_dinner():
    res = parser_service.parse("1.5k dinner")
    assert res["status"] == "success"
    assert res["amount"] == 1500
    assert res["type"] == "expense"
    assert res["category"] == "Food"

def test_expense_500_for_lunch_from_swiggy():
    res = parser_service.parse("500 for lunch from Swiggy")
    assert res["status"] == "success"
    assert res["amount"] == 500
    assert res["type"] == "expense"
    assert res["category"] == "Food"

def test_expense_200_uber_from_station():
    res = parser_service.parse("200 uber from station")
    assert res["status"] == "success"
    assert res["amount"] == 200
    assert res["type"] == "expense"
    assert res["category"] == "Transport"

def test_expense_1000_clothes_from_zara():
    res = parser_service.parse("1000 clothes from Zara")
    assert res["status"] == "success"
    assert res["amount"] == 1000
    assert res["type"] == "expense"
    assert res["category"] == "Shopping"

# ==================================================
# MANDATORY CONVERSATIONAL PENDING CONTEXT FLOW TESTS
# ==================================================

def test_flow_1_amount_then_description():
    # Step 1: User sends "600"
    res1 = parser_service.parse("600")
    assert res1["status"] == "needs_clarification"
    ctx1 = res1["pending_context"]
    assert ctx1 is not None

    # Step 2: User replies "snacks"
    res2 = parser_service.parse("snacks", pending_context=ctx1)
    assert res2["status"] == "success"
    assert res2["amount"] == 600
    assert res2["category"] == "Food"
    assert res2["description"] == "snacks"
    assert res2["type"] == "expense"
    assert res2["pending_context"] is None

def test_flow_2_description_then_amount():
    # Step 1: User sends "snacks"
    res1 = parser_service.parse("snacks")
    assert res1["status"] == "needs_clarification"
    ctx1 = res1["pending_context"]
    assert ctx1 is not None

    # Step 2: User replies "600"
    res2 = parser_service.parse("600", pending_context=ctx1)
    assert res2["status"] == "success"
    assert res2["amount"] == 600
    assert res2["category"] == "Food"
    assert res2["description"] == "snacks"
    assert res2["type"] == "expense"
    assert res2["pending_context"] is None

def test_flow_3_complete_input():
    res = parser_service.parse("600 snacks")
    assert res["status"] == "success"
    assert res["amount"] == 600
    assert res["category"] == "Food"
    assert res["description"] == "snacks"
    assert res["type"] == "expense"
    assert res.get("pending_context") is None

def test_flow_4_bare_number_then_type():
    # Step 1: User sends "5000"
    res1 = parser_service.parse("5000")
    assert res1["status"] == "needs_clarification"
    ctx1 = res1["pending_context"]
    assert ctx1 is not None

    # Step 2: User replies "income"
    res2 = parser_service.parse("income", pending_context=ctx1)
    assert res2["status"] == "success"
    assert res2["amount"] == 5000
    assert res2["type"] == "income"
    assert res2["category"] == "Income"
    assert res2["pending_context"] is None

def test_flow_5_income_description_then_amount():
    # Step 1: User sends "freelance"
    res1 = parser_service.parse("freelance")
    assert res1["status"] == "needs_clarification"
    ctx1 = res1["pending_context"]
    assert ctx1 is not None

    # Step 2: User replies "5000"
    res2 = parser_service.parse("5000", pending_context=ctx1)
    assert res2["status"] == "success"
    assert res2["amount"] == 5000
    assert res2["type"] == "income"
    assert res2["description"] == "freelance"
    assert res2["pending_context"] is None

def test_flow_6_sequential_transactions_clears_pending_state():
    # Step 1: User sends "600"
    res1 = parser_service.parse("600")
    assert res1["status"] == "needs_clarification"
    ctx1 = res1["pending_context"]

    # Step 2: User replies "snacks" -> completes transaction 1
    res2 = parser_service.parse("snacks", pending_context=ctx1)
    assert res2["status"] == "success"
    assert res2["amount"] == 600

    # Step 3: User sends "300 dinner" -> brand new transaction 2
    res3 = parser_service.parse("300 dinner")
    assert res3["status"] == "success"
    assert res3["amount"] == 300
    assert res3["description"] == "dinner"
    assert res3["category"] == "Food"

# ==================================================
# MANDATORY MULTI-ITEM TRANSACTION TESTS
# ==================================================

def test_multi_item_200_shoes_300_chips_500_cafe():
    res = parser_service.parse("200 shoes 300 chips 500 cafe")
    assert res["status"] == "success"
    assert res.get("is_multiple") is True
    items = res["items"]
    assert len(items) == 3
    assert items[0]["amount"] == 200 and items[0]["description"] == "shoes" and items[0]["category"] == "Shopping"
    assert items[1]["amount"] == 300 and items[1]["description"] == "chips" and items[1]["category"] == "Food"
    assert items[2]["amount"] == 500 and items[2]["description"] == "cafe" and items[2]["category"] == "Food"

def test_multi_item_55_noodles_300_dinner():
    res = parser_service.parse("55 noodles 300 dinner")
    assert res["status"] == "success"
    assert res.get("is_multiple") is True
    items = res["items"]
    assert len(items) == 2
    assert items[0]["amount"] == 55 and items[0]["description"] == "noodles" and items[0]["category"] == "Food"
    assert items[1]["amount"] == 300 and items[1]["description"] == "dinner" and items[1]["category"] == "Food"

def test_multi_item_100_bus_500_shirt():
    res = parser_service.parse("100 bus 500 shirt")
    assert res["status"] == "success"
    assert res.get("is_multiple") is True
    items = res["items"]
    assert len(items) == 2
    assert items[0]["amount"] == 100 and items[0]["description"] == "bus" and items[0]["category"] == "Transport"
    assert items[1]["amount"] == 500 and items[1]["description"] == "shirt" and items[1]["category"] == "Shopping"

def test_multi_item_120_coffee_350_uber_499_netflix():
    res = parser_service.parse("120 coffee 350 uber 499 netflix")
    assert res["status"] == "success"
    assert res.get("is_multiple") is True
    items = res["items"]
    assert len(items) == 3
    assert items[0]["amount"] == 120 and items[0]["description"] == "coffee" and items[0]["category"] == "Food"
    assert items[1]["amount"] == 350 and items[1]["description"] == "uber" and items[1]["category"] == "Transport"
    assert items[2]["amount"] == 499 and items[2]["description"] == "netflix" and items[2]["category"] == "Entertainment"

def test_single_item_250_snacks():
    res = parser_service.parse("250 snacks")
    assert res["status"] == "success"
    assert res.get("is_multiple") is not True
    assert res["amount"] == 250
    assert res["description"] == "snacks"
    assert res["category"] == "Food"

def test_income_received_5000_from_rahul():
    res = parser_service.parse("received 5000 from Rahul")
    assert res["status"] == "success"
    assert res.get("is_multiple") is not True
    assert res["amount"] == 5000
    assert res["type"] == "income"
    assert res["category"] == "Income"

def test_mixed_ambiguous_quantity_not_split():
    res = parser_service.parse("I bought 2 shirts for 500")
    assert res["status"] == "success"
    assert res.get("is_multiple") is not True
    assert res["amount"] == 500
    assert res["type"] == "expense"
    assert res["category"] == "Shopping"


