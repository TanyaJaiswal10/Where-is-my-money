import '../constants/currencies.dart';

class CurrencyFormatter {
  /// Formats monetary amount based on ISO currency rules (decimals, symbol).
  static String format(double amount, String currencyCode) {
    final currency = getCurrencyByCode(currencyCode);
    final absAmount = amount.abs();

    String formattedNumber;
    if (currency.decimalDigits == 0) {
      formattedNumber = absAmount.round().toString();
    } else {
      formattedNumber = absAmount.toStringAsFixed(currency.decimalDigits);
    }

    // Add thousand comma separators
    final parts = formattedNumber.split('.');
    final integerPart = parts[0].replaceAllRegExp(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
    final resultNumber = parts.length > 1 ? "$integerPart.${parts[1]}" : integerPart;

    final sign = amount < 0 ? "-" : "";
    return "$sign${currency.symbol}$resultNumber";
  }
}

extension RegExpReplace on String {
  String replaceAllRegExp(RegExp exp, String replacement) {
    return replaceAllMapped(exp, (match) => replacement);
  }
}
