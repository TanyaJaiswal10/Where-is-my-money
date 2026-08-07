import re
from decimal import Decimal
from typing import Optional, Dict, Any, Tuple, List
from app.core.categories import CATEGORY_MAPPINGS, INCOME_EXPLICIT_TERMS, INCOME_PHRASES, EXPENSE_KEYWORDS
from app.core.currencies import SYMBOL_TO_CURRENCY, DEFAULT_CURRENCY_CODE, is_valid_currency, format_currency_amount

class ParserService:
    @staticmethod
    def parse(
        text: str,
        default_currency: str = "INR",
        pending_context: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """
        Parses natural language transaction input into structured intent.
        Supports multi-item transaction prompts e.g. '200 shoes 300 chips 500 cafe'.
        Maintains conversational pending transaction context across follow-up messages.
        """
        clean_text = text.strip()
        if not clean_text:
            return {
                "status": "needs_clarification",
                "missing_field": "input",
                "message": "Please enter a transaction, e.g. '250 snacks' or '500 uber'."
            }

        # 0. Check for Multiple Transactions in a Single Input
        if not pending_context:
            multi_items = ParserService._try_parse_multiple(clean_text, default_currency)
            if multi_items and len(multi_items) >= 2:
                return {
                    "status": "success",
                    "is_multiple": True,
                    "items": multi_items,
                    "amount": multi_items[0]["amount"],
                    "type": multi_items[0]["type"],
                    "description": multi_items[0]["description"],
                    "category": multi_items[0]["category"],
                    "confidence": multi_items[0]["confidence"],
                    "currency": multi_items[0]["currency"],
                    "pending_context": None,
                }

        # 1. Extract Currency and Amount from current input
        amount, currency, amount_raw_str = ParserService._extract_amount_and_currency(clean_text, default_currency)
        description = ParserService._extract_description(clean_text, amount_raw_str)

        # 2. Check if current message is a brand-new complete transaction that overrides pending context
        is_new_complete_tx = (amount is not None and amount > 0 and len(description) > 0)

        # 3. Handle Conversational Follow-Up with Pending Context
        if pending_context and not is_new_complete_tx:
            missing = pending_context.get("missing_field")

            # Case A: Missing Description (User sent "600", now replies "snacks" or "income")
            if missing == "description":
                p_amount = Decimal(str(pending_context["amount"]))
                p_curr = pending_context.get("currency", currency)
                desc = description if description else clean_text
                tx_type = pending_context.get("type") or ParserService._determine_type(clean_text, desc)
                category, confidence = ParserService._classify_category(desc, tx_type)
                return {
                    "status": "success",
                    "amount": p_amount,
                    "type": tx_type,
                    "description": desc,
                    "category": category,
                    "confidence": confidence,
                    "currency": p_curr,
                    "pending_context": None,
                }

            # Case B: Missing Amount (User sent "snacks" or "freelance", now replies "600" or "5000")
            elif missing == "amount" and amount is not None and amount > 0:
                p_desc = pending_context.get("description", "Expense")
                p_type = pending_context.get("type") or "expense"
                p_cat = pending_context.get("category") or ("Income" if p_type == "income" else "Other")
                p_curr = currency or pending_context.get("currency", default_currency)
                return {
                    "status": "success",
                    "amount": amount,
                    "type": p_type,
                    "description": p_desc,
                    "category": p_cat,
                    "confidence": 0.95,
                    "currency": p_curr,
                    "pending_context": None,
                }

            # Case C: Missing Type (User sent "5000", now replies "income" or "spending")
            elif missing == "type":
                p_amount = Decimal(str(pending_context["amount"]))
                p_curr = pending_context.get("currency", currency)
                tx_type = "income" if any(w in clean_text.lower() for w in ("income", "received", "earned", "credit")) else "expense"
                category = "Income" if tx_type == "income" else "Other"
                desc = "Income" if tx_type == "income" else "Expense"
                return {
                    "status": "success",
                    "amount": p_amount,
                    "type": tx_type,
                    "description": desc,
                    "category": category,
                    "confidence": 0.95,
                    "currency": p_curr,
                    "pending_context": None,
                }

        # 4. Standalone Parsing (New Transaction)
        if amount is None or amount <= 0:
            if description:
                tx_type = ParserService._determine_type(clean_text, description)
                category, _ = ParserService._classify_category(description, tx_type)
                msg = f"How much did you receive from {description}?" if tx_type == "income" else f"How much did you spend on {description}?"
                return {
                    "status": "needs_clarification",
                    "missing_field": "amount",
                    "message": msg,
                    "pending_context": {
                        "description": description,
                        "category": category,
                        "type": tx_type,
                        "currency": currency,
                        "missing_field": "amount",
                    },
                }
            return {
                "status": "needs_clarification",
                "missing_field": "amount",
                "message": "How much was the transaction?",
            }

        # Amount exists, check description
        if not description:
            tx_type = ParserService._determine_type(clean_text, "")
            if any(w in clean_text.lower() for w in ("income", "salary", "expense", "spent", "paid")):
                category = "Income" if tx_type == "income" else "Other"
                desc = "Income" if tx_type == "income" else "Expense"
                return {
                    "status": "success",
                    "amount": amount,
                    "type": tx_type,
                    "description": desc,
                    "category": category,
                    "confidence": 0.90,
                    "currency": currency,
                    "pending_context": None,
                }

            formatted_amt = format_currency_amount(amount, currency)
            return {
                "status": "needs_clarification",
                "missing_field": "description",
                "message": f"What was the {formatted_amt} for?",
                "pending_context": {
                    "amount": float(amount),
                    "currency": currency,
                    "missing_field": "description",
                },
            }

        # Complete input (Amount + Description) -> Complete immediately!
        tx_type = ParserService._determine_type(clean_text, description)
        category, confidence = ParserService._classify_category(description, tx_type)

        return {
            "status": "success",
            "amount": amount,
            "type": tx_type,
            "description": description,
            "category": category,
            "confidence": confidence,
            "currency": currency,
            "pending_context": None,
        }

    @staticmethod
    def _try_parse_multiple(text: str, default_currency: str) -> Optional[List[Dict[str, Any]]]:
        """
        Attempts to parse multiple [amount + item] pairs from a single input string.
        e.g. '200 shoes 300 chips 500 cafe' -> 3 separate items.
        """
        amount_pattern = r'(?:[₹$€£¥]\s*|(?:rs|rs\.|usd|gbp|eur|jpy|inr|cad|aud|sgd)\s*)?(\d+(?:,\d+)*(?:\.\d+)?)\s*([kK])?\b'
        matches = list(re.finditer(amount_pattern, text, re.IGNORECASE))
        if len(matches) < 2:
            return None

        # 1. Try splitting by explicit delimiters (commas, semicolons, newlines, "and")
        delimiters_pattern = r'[,;\n]|\band\b'
        raw_chunks = re.split(delimiters_pattern, text, flags=re.IGNORECASE)

        valid_chunk_items = []
        if len(raw_chunks) >= 2:
            for chunk in raw_chunks:
                chunk_clean = chunk.strip()
                if not chunk_clean:
                    continue
                amt, curr, raw_amt = ParserService._extract_amount_and_currency(chunk_clean, default_currency)
                if amt and amt > 0:
                    desc = ParserService._extract_description(chunk_clean, raw_amt)
                    if desc and len(desc) > 0:
                        tx_type = ParserService._determine_type(chunk_clean, desc)
                        cat, conf = ParserService._classify_category(desc, tx_type)
                        valid_chunk_items.append({
                            "amount": amt,
                            "type": tx_type,
                            "description": desc,
                            "category": cat,
                            "confidence": conf,
                            "currency": curr,
                        })

        if len(valid_chunk_items) >= 2 and len(valid_chunk_items) == len(matches):
            return valid_chunk_items

        # 2. Try splitting by match positions (e.g. "200 shoes 300 chips 500 cafe")
        segments = []
        for i in range(len(matches)):
            start_pos = matches[i].start()
            end_pos = matches[i+1].start() if i + 1 < len(matches) else len(text)
            seg_text = text[start_pos:end_pos].strip()
            segments.append(seg_text)

        positional_items = []
        for seg in segments:
            amt, curr, raw_amt = ParserService._extract_amount_and_currency(seg, default_currency)
            if amt and amt > 0:
                desc = ParserService._extract_description(seg, raw_amt)
                if desc and len(desc) > 0:
                    tx_type = ParserService._determine_type(seg, desc)
                    cat, conf = ParserService._classify_category(desc, tx_type)
                    positional_items.append({
                        "amount": amt,
                        "type": tx_type,
                        "description": desc,
                        "category": cat,
                        "confidence": conf,
                        "currency": curr,
                    })

        if len(positional_items) >= 2 and len(positional_items) == len(matches):
            return positional_items

        return None

    @staticmethod
    def _extract_amount_and_currency(text: str, default_currency: str) -> Tuple[Optional[Decimal], str, str]:
        currency = default_currency.upper().strip() if default_currency else DEFAULT_CURRENCY_CODE
        lower_text = text.lower()

        for sym, curr in SYMBOL_TO_CURRENCY.items():
            if sym in text or re.search(rf'\b{re.escape(sym)}\b', lower_text):
                currency = curr
                break

        iso_match = re.search(r'\b([a-zA-Z]{3})\b', text)
        if iso_match:
            potential_iso = iso_match.group(1).upper()
            if is_valid_currency(potential_iso):
                currency = potential_iso

        pattern = r'(?:[₹$€£¥]\s*|(?:rs|rs\.|usd|gbp|eur|jpy|inr|cad|aud|sgd)\s*)?(\d+(?:,\d+)*(?:\.\d+)?)\s*([kK])?\b'
        matches = list(re.finditer(pattern, text, re.IGNORECASE))
        if not matches:
            return None, currency, ""

        found = []
        for match in matches:
            val_str = match.group(1).replace(',', '')
            is_k = bool(match.group(2))
            try:
                val = Decimal(val_str)
                if is_k:
                    val = val * Decimal('1000')
                if val > 0:
                    raw_match_str = match.group(0)
                    start_pos = match.start()
                    prefix = text[max(0, start_pos - 10):start_pos].lower()
                    suffix = text[match.end():min(len(text), match.end() + 10)].lower()

                    score = 0
                    if any(c in raw_match_str for c in "₹$€£¥"):
                        score += 10
                    if any(c in prefix for c in ("for", "rs", "inr", "usd", "spent", "paid", "cost")):
                        score += 5
                    if any(q in suffix for q in ("shirt", "shirts", "people", "items", "pcs", "pieces")):
                        score -= 5

                    found.append((score, val, currency, raw_match_str))
            except Exception:
                continue

        if found:
            found.sort(key=lambda x: x[0], reverse=True)
            best = found[0]
            return best[1], best[2], best[3]

        return None, currency, ""

    @staticmethod
    def _extract_description(text: str, amount_raw_str: str) -> str:
        clean = text
        if amount_raw_str:
            clean = clean.replace(amount_raw_str, " ")

        clean = re.sub(r'[₹$€£¥]', ' ', clean)
        clean = re.sub(r'\b(rs|rs\.|inr|usd|gbp|eur|jpy|cad|aud|sgd)\b', ' ', clean, flags=re.IGNORECASE)
        clean = re.sub(r'\b\d+(?:,\d+)*(?:\.\d+)?\s*[kK]?\b', ' ', clean)

        stop_words = {"spent", "paid", "bought", "gave", "for", "on", "the", "a", "an"}
        tokens = clean.split()
        filtered = [t for t in tokens if t.lower() not in stop_words or t.lower() in ("salary", "rent", "food", "dinner", "lunch")]

        desc = " ".join(filtered).strip()
        desc = re.sub(r'^[^\w]+|[^\w]+$', '', desc).strip()
        return desc

    @staticmethod
    def _determine_type(text: str, description: str) -> str:
        lower = text.lower()

        for phrase in INCOME_PHRASES:
            if phrase in lower:
                return "income"

        if re.search(r'\b(me|us)\b', lower) and "paid" in lower:
            return "income"
        if re.search(r'\b(client|company|boss|employer|friend|rahul|john|dad|mom|father|mother)\s+paid\b', lower):
            return "income"

        for term in INCOME_EXPLICIT_TERMS:
            if re.search(rf'\b{re.escape(term)}\b', lower):
                return "income"

        if "from" in lower:
            expense_origin_keywords = ["swiggy", "zomato", "amazon", "flipkart", "zara", "station", "mall", "myntra", "store", "shop"]
            if any(kw in lower for kw in expense_origin_keywords):
                return "expense"
            for keywords in CATEGORY_MAPPINGS.values():
                if any(kw in lower for kw in keywords):
                    return "expense"
            if "received" in lower or re.search(r'\bfrom\s+[a-z]+\b', lower):
                return "income"

        return "expense"

    @staticmethod
    def _classify_category(description: str, tx_type: str) -> Tuple[str, float]:
        if tx_type == "income":
            return "Income", 0.95

        desc_lower = description.lower()
        tokens = re.findall(r'\b\w+\b', desc_lower)

        for category, keywords in CATEGORY_MAPPINGS.items():
            for kw in keywords:
                for token in tokens:
                    if token == kw:
                        return category, 0.98

        for category, keywords in CATEGORY_MAPPINGS.items():
            for kw in keywords:
                for token in tokens:
                    if len(kw) > 3 and (kw in token or token in kw):
                        return category, 0.75

        return "Other", 0.40

parser_service = ParserService()
