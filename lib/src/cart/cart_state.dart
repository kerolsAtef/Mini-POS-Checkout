import 'package:equatable/equatable.dart';
import '../mini_pos_checkout.dart';


/// Represents the complete state of the shopping cart
class CartState extends Equatable {
  /// List of cart line items
  final List<CartLine> lines;

  /// Calculated totals
  final CartTotals totals;

  const CartState({
    required this.lines,
    required this.totals,
  });

  /// Create empty cart state
  const CartState.empty()
      : lines = const [],
        totals = const CartTotals.empty();

  /// Check if cart is empty
  bool get isEmpty => lines.isEmpty;

  /// Get total number of items in cart
  int get totalItems => lines.fold(0, (sum, line) => sum + line.quantity);

  /// Find cart line by item ID
  CartLine? findLineByItemId(String itemId) {
    try {
      return lines.firstWhere((line) => line.item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Create a copy with updated values
  CartState copyWith({
    List<CartLine>? lines,
    CartTotals? totals,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      totals: totals ?? this.totals,
    );
  }

  @override
  List<Object?> get props => [lines, totals];

  @override
  String toString() => 'CartState(lines: ${lines.length}, totals: $totals)';
}