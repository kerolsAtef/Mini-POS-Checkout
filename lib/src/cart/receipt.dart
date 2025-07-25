import 'package:equatable/equatable.dart';
import 'package:mini_pos_app/util/money_extensions.dart';
import 'cart_state.dart';
import 'models.dart';

class ReceiptHeader extends Equatable {
  /// Transaction timestamp
  final DateTime timestamp;

  /// Transaction ID (optional)
  final String? transactionId;

  /// Store information (optional)
  final String? storeName;

  const ReceiptHeader({
    required this.timestamp,
    this.transactionId,
    this.storeName,
  });

  @override
  List<Object?> get props => [timestamp, transactionId, storeName];

  @override
  String toString() => 'ReceiptHeader(timestamp: $timestamp, transactionId: $transactionId)';
}

/// Represents a line item on the receipt
class ReceiptLine extends Equatable {
  /// Item ID
  final String itemId;

  /// Item name
  final String itemName;

  /// Unit price
  final double unitPrice;

  /// Quantity
  final int quantity;

  /// Discount percentage (0.0 to 1.0)
  final double discount;

  /// Net amount for this line
  final double lineNet;

  const ReceiptLine({
    required this.itemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.discount,
    required this.lineNet,
  });

  /// Create ReceiptLine from CartLine
  factory ReceiptLine.fromCartLine(CartLine cartLine) {
    return ReceiptLine(
      itemId: cartLine.item.id,
      itemName: cartLine.item.name,
      unitPrice: cartLine.item.price,
      quantity: cartLine.quantity,
      discount: cartLine.discount,
      lineNet: cartLine.lineNet,
    );
  }

  /// Gross amount before discount
  double get grossAmount => unitPrice * quantity;

  /// Discount amount in currency
  double get discountAmount => grossAmount * discount;

  @override
  List<Object?> get props => [itemId, itemName, unitPrice, quantity, discount, lineNet];

  @override
  String toString() => 'ReceiptLine($itemName x$quantity @ ${unitPrice.asMoney} = ${lineNet.asMoney})';
}

/// Represents the totals section of the receipt
class ReceiptTotals extends Equatable {
  /// Subtotal amount
  final double subtotal;

  /// VAT amount
  final double vat;

  /// Total discount amount
  final double totalDiscount;

  /// Grand total amount
  final double grandTotal;

  const ReceiptTotals({
    required this.subtotal,
    required this.vat,
    required this.totalDiscount,
    required this.grandTotal,
  });

  /// Create ReceiptTotals from CartTotals
  factory ReceiptTotals.fromCartTotals(CartTotals cartTotals) {
    return ReceiptTotals(
      subtotal: cartTotals.subtotal,
      vat: cartTotals.vat,
      totalDiscount: cartTotals.totalDiscount,
      grandTotal: cartTotals.grandTotal,
    );
  }

  @override
  List<Object?> get props => [subtotal, vat, totalDiscount, grandTotal];

  @override
  String toString() => 'ReceiptTotals(subtotal: ${subtotal.asMoney}, vat: ${vat.asMoney}, grandTotal: ${grandTotal.asMoney})';
}

/// Represents a complete receipt
class Receipt extends Equatable {
  /// Receipt header information
  final ReceiptHeader header;

  /// List of receipt line items
  final List<ReceiptLine> lines;

  /// Receipt totals
  final ReceiptTotals totals;

  const Receipt({
    required this.header,
    required this.lines,
    required this.totals,
  });

  /// Total number of items on the receipt
  int get totalItems => lines.fold(0, (sum, line) => sum + line.quantity);

  /// Check if receipt is empty
  bool get isEmpty => lines.isEmpty;

  @override
  List<Object?> get props => [header, lines, totals];

  @override
  String toString() => 'Receipt(${lines.length} lines, total: ${totals.grandTotal.asMoney})';
}

/// Pure function to build a receipt from cart state
/// This is the main receipt builder function as required
Receipt buildReceipt(CartState cartState, DateTime timestamp) {
  // Create header
  final header = ReceiptHeader(
    timestamp: timestamp,
    transactionId: 'TXN-${timestamp.millisecondsSinceEpoch}',
    storeName: 'Izam Store',
  );

  // Convert cart lines to receipt lines
  final lines = cartState.lines.map((cartLine) =>
      ReceiptLine.fromCartLine(cartLine)
  ).toList();

  // Convert cart totals to receipt totals
  final totals = ReceiptTotals.fromCartTotals(cartState.totals);

  return Receipt(
    header: header,
    lines: lines,
    totals: totals,
  );
}