from dataclasses import dataclass
from typing import Dict, Optional, List
from decimal import Decimal

@dataclass
class CurrencyMetadata:
    code: str
    symbol: str
    name: str
    flag: str
    decimal_digits: int = 2

CURRENCIES_REGISTRY: Dict[str, CurrencyMetadata] = {
    "INR": CurrencyMetadata(code="INR", symbol="₹", name="Indian Rupee", flag="🇮🇳", decimal_digits=2),
    "USD": CurrencyMetadata(code="USD", symbol="$", name="US Dollar", flag="🇺🇸", decimal_digits=2),
    "GBP": CurrencyMetadata(code="GBP", symbol="£", name="British Pound", flag="🇬🇧", decimal_digits=2),
    "EUR": CurrencyMetadata(code="EUR", symbol="€", name="Euro", flag="🇪🇺", decimal_digits=2),
    "JPY": CurrencyMetadata(code="JPY", symbol="¥", name="Japanese Yen", flag="🇯🇵", decimal_digits=0),
    "CAD": CurrencyMetadata(code="CAD", symbol="C$", name="Canadian Dollar", flag="🇨🇦", decimal_digits=2),
    "AUD": CurrencyMetadata(code="AUD", symbol="A$", name="Australian Dollar", flag="🇦🇺", decimal_digits=2),
    "SGD": CurrencyMetadata(code="SGD", symbol="S$", name="Singapore Dollar", flag="🇸🇬", decimal_digits=2),
    "CHF": CurrencyMetadata(code="CHF", symbol="CHF", name="Swiss Franc", flag="🇨🇭", decimal_digits=2),
    "CNY": CurrencyMetadata(code="CNY", symbol="¥", name="Chinese Yuan", flag="🇨🇳", decimal_digits=2),
}

DEFAULT_CURRENCY_CODE = "INR"

SYMBOL_TO_CURRENCY: Dict[str, str] = {
    "₹": "INR",
    "rs": "INR",
    "rs.": "INR",
    "inr": "INR",
    "$": "USD",
    "usd": "USD",
    "£": "GBP",
    "gbp": "GBP",
    "€": "EUR",
    "eur": "EUR",
    "¥": "JPY",
    "jpy": "JPY",
    "c$": "CAD",
    "cad": "CAD",
    "a$": "AUD",
    "aud": "AUD",
    "s$": "SGD",
    "sgd": "SGD",
}

def get_currency_metadata(code: Optional[str]) -> CurrencyMetadata:
    """Returns currency metadata for code, falling back to INR."""
    if not code:
        return CURRENCIES_REGISTRY[DEFAULT_CURRENCY_CODE]
    clean_code = code.upper().strip()
    return CURRENCIES_REGISTRY.get(clean_code, CURRENCIES_REGISTRY[DEFAULT_CURRENCY_CODE])

def is_valid_currency(code: str) -> bool:
    """Checks if currency ISO code is registered."""
    return code.upper().strip() in CURRENCIES_REGISTRY

def format_currency_amount(amount: Decimal | float, code: str) -> str:
    """Formats monetary amount according to currency decimal rules."""
    meta = get_currency_metadata(code)
    num = float(amount)
    if meta.decimal_digits == 0:
        formatted_num = f"{int(round(num)):,}"
    else:
        formatted_num = f"{num:,.2f}"
    return f"{meta.symbol}{formatted_num}"

def list_all_currencies() -> List[Dict[str, str]]:
    """Returns list of all available currencies."""
    return [
        {
            "code": c.code,
            "symbol": c.symbol,
            "name": c.name,
            "flag": c.flag,
            "decimal_digits": c.decimal_digits,
        }
        for c in CURRENCIES_REGISTRY.values()
    ]
