import '../src/cart/models.dart';
import 'money_extensions.dart';

/// Utility class for calculating cart totals
class CartCalculator {
  /// Calculate totals from list of cart lines
  static CartTotals calculateTotals(List<CartLine> lines) {
    if (lines.isEmpty) {
      return const CartTotals.empty();
    }

    // Calculate subtotal (sum of all line net amounts)
    final subtotal = MoneyUtils.roundMoney(
      lines.fold(0.0, (sum, line) => sum + line.lineNet),
    );

    // Calculate total discount amount
    final totalDiscount = MoneyUtils.roundMoney(
      lines.fold(0.0, (sum, line) {
        final grossAmount = line.item.price * line.quantity;
        final discountAmount = grossAmount * line.discount;
        return sum + discountAmount;
      }),
    );

    // Calculate VAT (15% of subtotal)
    final vat = MoneyUtils.calculateVat(subtotal);

    // Calculate grand total
    final grandTotal = MoneyUtils.calculateGrandTotal(subtotal, vat);

    return CartTotals(
      subtotal: subtotal,
      vat: vat,
      totalDiscount: totalDiscount,
      grandTotal: grandTotal,
    );
  }
}