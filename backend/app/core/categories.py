from typing import Dict, List

# Centralized Category Mapping & Keyword Definitions
CATEGORY_MAPPINGS: Dict[str, List[str]] = {
    "Food": [
        "snack", "snacks", "lunch", "dinner", "breakfast", "brunch",
        "restaurant", "groceries", "grocery", "pizza", "coffee", "tea",
        "burger", "zomato", "swiggy", "food", "eat", "cafe", "bakery",
        "milk", "vegetables", "fruits", "meat", "chicken", "noodle", "noodles",
        "chip", "chips"
    ],
    "Transport": [
        "uber", "ola", "taxi", "cab", "metro", "bus", "fuel", "petrol",
        "diesel", "parking", "auto", "ride", "rickshaw", "toll", "train",
        "flight", "rapido", "station"
    ],
    "Housing": [
        "rent", "maintenance", "landlord", "flat", "apartment", "deposit",
        "house"
    ],
    "Bills": [
        "electricity", "water", "internet", "wifi", "phone", "mobile",
        "recharge", "broadband", "gas", "utility", "bill", "bills",
        "dth", "newspaper"
    ],
    "Shopping": [
        "clothes", "clothing", "amazon", "flipkart", "shoes", "shirt",
        "shirts", "pants", "dress", "shopping", "mall", "myntra", "electronics",
        "watch", "bag", "zara"
    ],
    "Entertainment": [
        "movie", "cinema", "netflix", "spotify", "games", "gaming",
        "concert", "show", "pub", "bar", "drinks", "party", "subscription",
        "hotstar", "prime"
    ],
    "Health": [
        "medicine", "pharmacy", "doctor", "hospital", "clinic", "lab",
        "test", "gym", "fitness", "medical", "pills"
    ],
    "Education": [
        "course", "books", "book", "college", "school", "tuition",
        "udemy", "coursera", "exam", "fees", "fee", "stationery"
    ],
    "Travel": [
        "hotel", "stay", "resort", "trip", "tour", "vacation",
        "booking", "airbnb"
    ],
}

# Explicit Income Terms and Contextual Income Phrases
INCOME_EXPLICIT_TERMS: List[str] = [
    "salary", "paycheck", "payroll", "allowance", "freelance", "stipend",
    "bonus", "cashback", "refund", "reimbursement", "reimbursed", "dividend",
    "interest", "gift", "won", "sold", "received", "receive", "income"
]

INCOME_PHRASES: List[str] = [
    "got paid", "paid me", "sent me", "transferred to me", "money received",
    "payment received", "salary credited", "credited", "deposited", "deposit"
]

EXPENSE_KEYWORDS: List[str] = [
    "spent", "paid", "bought", "gave", "cost", "fee", "for", "on", "debit", "debited"
]
