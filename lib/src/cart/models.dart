import 'package:equatable/equatable.dart';
import 'package:mini_pos_app/util/money_extensions.dart';
import '../catalog/item.dart';

/// Represents a line item in the shopping cart
class CartLine extends Equatable {
  /// The product item
  final Item item;

  /// Quantity of the item
  final int quantity;

  /// Discount percentage (0.0 to 1.0)
  final double discount;

  const CartLine({
    required this.item,
    required this.quantity,
    this.discount = 0.0,
  });

  /// Calculate the net amount for this line
  /// Formula: price × qty × (1 – discount%)
  double get lineNet {
    final grossAmount = item.price * quantity;
    final discountAmount = grossAmount * discount;
    final netAmount = grossAmount - discountAmount;
    return double.parse(netAmount.toStringAsFixed(2));
  }

  /// Create a copy with updated values
  CartLine copyWith({
    Item? item,
    int? quantity,
    double? discount,
  }) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  @override
  List<Object?> get props => [item, quantity, discount];

  @override
  String toString() => 'CartLine(item: ${item.name}, qty: $quantity, discount: ${(discount * 100).toStringAsFixed(1)}%, lineNet: ${lineNet.asMoney})';
}

/// Represents the calculated totals for the cart
class CartTotals extends Equatable {
  /// Sum of all line net amounts
  final double subtotal;

  /// VAT amount (15% of subtotal)
  final double vat;

  /// Total discount amount across all lines
  final double totalDiscount;

  /// Final amount (subtotal + vat)
  final double grandTotal;

  const CartTotals({
    required this.subtotal,
    required this.vat,
    required this.totalDiscount,
    required this.grandTotal,
  });

  /// Create empty totals
  const CartTotals.empty()
      : subtotal = 0.0,
        vat = 0.0,
        totalDiscount = 0.0,
        grandTotal = 0.0;

  @override
  List<Object?> get props => [subtotal, vat, totalDiscount, grandTotal];

  @override
  String toString() => 'CartTotals(subtotal: ${subtotal.asMoney}, vat: ${vat.asMoney}, discount: ${totalDiscount.asMoney}, grandTotal: ${grandTotal.asMoney})';
}
