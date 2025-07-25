import 'package:equatable/equatable.dart';
import '../catalog/item.dart';

/// Base class for all cart events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Event to add an item to the cart
class AddItem extends CartEvent {
  /// The item to add
  final Item item;

  /// Quantity to add (default: 1)
  final int quantity;

  const AddItem(this.item, {this.quantity = 1});

  @override
  List<Object?> get props => [item, quantity];

  @override
  String toString() => 'AddItem(${item.name}, qty: $quantity)';
}

/// Event to remove an item from the cart
class RemoveItem extends CartEvent {
  /// ID of the item to remove
  final String itemId;

  const RemoveItem(this.itemId);

  @override
  List<Object?> get props => [itemId];

  @override
  String toString() => 'RemoveItem($itemId)';
}

/// Event to change quantity of an item in the cart
class ChangeQty extends CartEvent {
  /// ID of the item to update
  final String itemId;

  /// New quantity
  final int newQuantity;

  const ChangeQty(this.itemId, this.newQuantity);

  @override
  List<Object?> get props => [itemId, newQuantity];

  @override
  String toString() => 'ChangeQty($itemId, qty: $newQuantity)';
}

/// Event to change discount of an item in the cart
class ChangeDiscount extends CartEvent {
  /// ID of the item to update
  final String itemId;

  /// New discount percentage (0.0 to 1.0)
  final double newDiscount;

  const ChangeDiscount(this.itemId, this.newDiscount);

  @override
  List<Object?> get props => [itemId, newDiscount];

  @override
  String toString() => 'ChangeDiscount($itemId, discount: ${(newDiscount * 100).toStringAsFixed(1)}%)';
}

/// Event to clear the entire cart
class ClearCart extends CartEvent {
  const ClearCart();

  @override
  String toString() => 'ClearCart()';
}

/// Event to undo the last cart action
class UndoCart extends CartEvent {
  const UndoCart();

  @override
  String toString() => 'UndoCart()';
}

/// Event to redo the last undone cart action
class RedoCart extends CartEvent {
  const RedoCart();

  @override
  String toString() => 'RedoCart()';
}