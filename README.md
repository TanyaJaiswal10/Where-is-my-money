# Where's My Money? 💸

> **Conversational Personal Finance App for Mobile & Web.**

*Where's My Money?* is a mobile-first, conversational personal finance application built with Flutter, FastAPI, PostgreSQL, and data-driven financial intelligence. Instead of forcing users through tedious multi-step form fields, the app allows users to simply type or dictate what they spent in plain natural language (e.g. *"250 snacks"*, *"$20 coffee"*, *"1200 rent"*), automatically parsing, categorizing, validating, and tracking expenses seamlessly.

---

## 🌟 Core Features

- 💬 **Conversational Chat Experience**: Type natural short prompts like `"250 snacks"` or `"$20 coffee"` to record transactions instantly with confirmation cards and instant undo/edit options.
- ⚡ **Natural-Language Transaction Parser**: Rule-based & regex parser supporting income/expense classification, category tagging, explicit symbols (`$`, `₹`, `£`, `€`, `¥`), and ISO currency codes (`20 USD`, `15 GBP`).
- 🛡️ **Transaction Safety & Smart Validation**: Statistical anomaly detection comparing entries against personal spending baselines to flag typos (e.g., `₹25,000 Food` $\rightarrow$ *"Did you mean ₹250.00?"*) without blocking transactions.
- 📊 **Insights & Analytics**: Sleek visual breakdowns, category rankings, period-over-period comparison, and spending trend charts.
- 🎯 **Budgets, Goals & Temporary Plans**:
  - Category budget tracking with spending pace predictions.
  - Savings goals with monthly contribution pacing.
  - Event/trip plans (*Japan Trip*) with itemized budget tracking.
- 🌍 **Global Currency & Localization Support**: Multi-currency architecture supporting ISO 4217 codes (`INR`, `USD`, `GBP`, `EUR`, `JPY`, etc.), custom symbol formatting, and mixed-currency safety.
- 🧠 **Personalized Financial Intelligence Engine**: Deterministic algorithms learning personal spending baselines, detecting month-over-month trends, recurring expenses, subscriptions, budget risk warnings, and ranking top insights.
- 🔁 **Recurring Expenses & Reminders**: Recurring bill tracking, upcoming payment alerts, missed payment prompts, and deduplicated notifications.
- 🔒 **User Authentication & Data Isolation**: Password hashing using native `bcrypt`, JWT access tokens, and strict database query scoping to isolate user data.

---

## 🏗️ System Architecture

```
┌────────────────────────────────────────────────────────┐
│                   Flutter Mobile & Web                 │
│         (Chat, Insights, Plans, Recurring, Auth)       │
└───────────────────────────▲────────────────────────────┘
                            │ REST API (JSON / Bearer JWT)
┌───────────────────────────┴────────────────────────────┐
│                    FastAPI Backend                     │
│  (Parser, Validation, Intelligence, Analytics, Auth)   │
└───────────────────────────▲────────────────────────────┘
                            │ SQLAlchemy ORM & Alembic
┌───────────────────────────┴────────────────────────────┐
│                  PostgreSQL Database                   │
│      (Users, Transactions, Budgets, Goals, Plans)      │
└────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.x, Dart, Material 3 Dark Obsidian Theme (`#0B0F17`).
- **Backend**: Python 3.13, FastAPI, Pydantic v2, PyJWT.
- **Database**: PostgreSQL, SQLAlchemy ORM, SQLite (Automatic dev fallback).
- **Database Migrations**: Alembic.
- **Containerization**: Docker, Docker Compose.
- **Testing**: Pytest (45 automated backend test cases), Flutter Analyze.

---

## 🚀 Quick Start (Local Development)

### Option 1: Running with Docker Compose (Recommended)

1. Clone repository and set up environment:
   ```bash
   cp .env.example .env
   ```
2. Launch database and backend containers:
   ```bash
   docker-compose up --build
   ```
3. Access API Documentation at [http://localhost:8000/docs](http://localhost:8000/docs).

---

### Option 2: Running Locally Without Docker

#### 1. Backend Setup (FastAPI & Python 3.13)
```bash
cd backend
python -m venv venv
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

pip install -r requirements.txt
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 2. Database Migrations (Alembic)
```bash
cd backend
alembic upgrade head
```

#### 3. Frontend Setup (Flutter)
```bash
flutter pub get
flutter run -d chrome  # Or flutter run -d edge / android / windows
```

---

## 🧪 Running Test Suites

### Backend Unit & Integration Tests (Pytest)
```bash
cd backend
python -m pytest
```
*Executes 45 comprehensive test cases covering authentication, natural-language parsing, currency handling, intelligence algorithms, budget risk predictions, recurring expenses, and notification deduplication.*

### Frontend Static Code Analysis (Flutter)
```bash
flutter analyze .
```

---

## 📄 API Documentation

FastAPI automatically serves interactive Swagger and ReDoc documentation:
- **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **ReDoc**: [http://localhost:8000/redoc](http://localhost:8000/redoc)
- **Health Check**: [http://localhost:8000/health](http://localhost:8000/health)

---

## 🔒 Security & Privacy

- **Password Security**: Passwords hashed using native `bcrypt`.
- **Stateless Auth**: JWT access tokens signed with `HS256`.
- **Data Scoping**: Every database query filters by `user_id == current_user.id`. Manipulation of resource IDs on API endpoints returns `404 Not Found`.

---

## 🛣️ Future Enhancements

- 🎙️ Voice input / Speech-to-Text integration for expense logging.
- 📱 Native mobile push notification service integration (FCM / APNs).
- 💬 Optional LLM natural-language explanation layer (reading verified structured insights).
