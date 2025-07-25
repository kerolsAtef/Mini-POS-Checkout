/// Extension on num to format currency values
extension MoneyExtension on num {
  /// Formats a number as money string (e.g., "12.34")
  String get asMoney {
    return toStringAsFixed(2);
  }
}

/// Utility class for money-related calculations
class MoneyUtils {
  /// VAT rate (15%)
  static const double vatRate = 0.15;

  /// Round money value to 2 decimal places
  static double roundMoney(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  /// Calculate VAT amount from subtotal
  static double calculateVat(double subtotal) {
    return roundMoney(subtotal * vatRate);
  }

  /// Calculate grand total (subtotal + vat)
  static double calculateGrandTotal(double subtotal, double vat) {
    return roundMoney(subtotal + vat);
  }
}