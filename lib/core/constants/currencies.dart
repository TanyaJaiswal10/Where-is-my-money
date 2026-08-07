class CurrencyItem {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final int decimalDigits;

  const CurrencyItem({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    this.decimalDigits = 2,
  });

  String get displayName => "$flag $code — $name ($symbol)";
}

const List<CurrencyItem> availableCurrencies = [
  CurrencyItem(code: "INR", symbol: "₹", name: "Indian Rupee", flag: "🇮🇳", decimalDigits: 2),
  CurrencyItem(code: "USD", symbol: "\$", name: "US Dollar", flag: "🇺🇸", decimalDigits: 2),
  CurrencyItem(code: "GBP", symbol: "£", name: "British Pound", flag: "🇬🇧", decimalDigits: 2),
  CurrencyItem(code: "EUR", symbol: "€", name: "Euro", flag: "🇪🇺", decimalDigits: 2),
  CurrencyItem(code: "JPY", symbol: "¥", name: "Japanese Yen", flag: "🇯🇵", decimalDigits: 0),
  CurrencyItem(code: "CAD", symbol: "C\$", name: "Canadian Dollar", flag: "🇨🇦", decimalDigits: 2),
  CurrencyItem(code: "AUD", symbol: "A\$", name: "Australian Dollar", flag: "🇦🇺", decimalDigits: 2),
  CurrencyItem(code: "SGD", symbol: "S\$", name: "Singapore Dollar", flag: "🇸🇬", decimalDigits: 2),
  CurrencyItem(code: "CHF", symbol: "CHF", name: "Swiss Franc", flag: "🇨🇭", decimalDigits: 2),
  CurrencyItem(code: "CNY", symbol: "¥", name: "Chinese Yuan", flag: "🇨🇳", decimalDigits: 2),
];

CurrencyItem getCurrencyByCode(String code) {
  final upper = code.toUpperCase().trim();
  return availableCurrencies.firstWhere(
    (c) => c.code == upper,
    orElse: () => availableCurrencies.first,
  );
}
