import 'package:bloc/bloc.dart';
import '../../util/cart_calculator.dart';
import '../../util/undo_redo_mixin.dart';
import 'cart_state.dart';
import 'models.dart';
import 'cart_events.dart';

/// BLoC for managing shopping cart state and operations
class CartBloc extends Bloc<CartEvent, CartState> with UndoRedoMixin<CartState> {
  /// Creates a new CartBloc with empty initial state
  CartBloc() : super(const CartState.empty()) {
    // Register event handlers
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<ChangeQty>(_onChangeQty);
    on<ChangeDiscount>(_onChangeDiscount);
    on<ClearCart>(_onClearCart);
    on<UndoCart>(_onUndoCart);
    on<RedoCart>(_onRedoCart);
  }

  /// Handles adding an item to the cart
  void _onAddItem(AddItem event, Emitter<CartState> emit) {
    // Save current state for undo
    saveState(state);

    // Validate quantity
    if (event.quantity <= 0) {
      return; // Don't add items with invalid quantity
    }

    final currentLines = List<CartLine>.from(state.lines);
    final existingLineIndex = currentLines.indexWhere(
          (line) => line.item.id == event.item.id,
    );

    if (existingLineIndex >= 0) {
      // Item already exists, update quantity
      final existingLine = currentLines[existingLineIndex];
      final newQuantity = existingLine.quantity + event.quantity;

      currentLines[existingLineIndex] = existingLine.copyWith(
        quantity: newQuantity,
      );
    } else {
      // New item, add to cart
      currentLines.add(CartLine(
        item: event.item,
        quantity: event.quantity,
      ));
    }

    // Recalculate totals and emit new state
    final newTotals = CartCalculator.calculateTotals(currentLines);
    emit(CartState(lines: currentLines, totals: newTotals));
  }

  /// Handles removing an item from the cart
  void _onRemoveItem(RemoveItem event, Emitter<CartState> emit) {
    // Save current state for undo
    saveState(state);

    final currentLines = List<CartLine>.from(state.lines);
    currentLines.removeWhere((line) => line.item.id == event.itemId);

    // Recalculate totals and emit new state
    final newTotals = CartCalculator.calculateTotals(currentLines);
    emit(CartState(lines: currentLines, totals: newTotals));
  }

  /// Handles changing quantity of an item in the cart
  void _onChangeQty(ChangeQty event, Emitter<CartState> emit) {
    // Save current state for undo
    saveState(state);

    final currentLines = List<CartLine>.from(state.lines);
    final lineIndex = currentLines.indexWhere(
          (line) => line.item.id == event.itemId,
    );

    if (lineIndex < 0) {
      return; // Item not found in cart
    }

    if (event.newQuantity <= 0) {
      // Remove item if quantity is 0 or negative
      currentLines.removeAt(lineIndex);
    } else {
      // Update quantity
      currentLines[lineIndex] = currentLines[lineIndex].copyWith(
        quantity: event.newQuantity,
      );
    }

    // Recalculate totals and emit new state
    final newTotals = CartCalculator.calculateTotals(currentLines);
    emit(CartState(lines: currentLines, totals: newTotals));
  }

  /// Handles changing discount of an item in the cart
  void _onChangeDiscount(ChangeDiscount event, Emitter<CartState> emit) {
    // Save current state for undo
    saveState(state);

    // Validate discount range (0.0 to 1.0)
    if (event.newDiscount < 0.0 || event.newDiscount > 1.0) {
      return; // Invalid discount percentage
    }

    final currentLines = List<CartLine>.from(state.lines);
    final lineIndex = currentLines.indexWhere(
          (line) => line.item.id == event.itemId,
    );

    if (lineIndex < 0) {
      return; // Item not found in cart
    }

    // Update discount
    currentLines[lineIndex] = currentLines[lineIndex].copyWith(
      discount: event.newDiscount,
    );

    // Recalculate totals and emit new state
    final newTotals = CartCalculator.calculateTotals(currentLines);
    emit(CartState(lines: currentLines, totals: newTotals));
  }

  /// Handles clearing the entire cart
  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    // Save current state for undo
    saveState(state);

    emit(const CartState.empty());
  }

  /// Handles undoing the last cart action
  void _onUndoCart(UndoCart event, Emitter<CartState> emit) {
    final previousState = getPreviousState(state);
    if (previousState != null) {
      emit(previousState);
    }
  }

  /// Handles redoing the last undone cart action
  void _onRedoCart(RedoCart event, Emitter<CartState> emit) {
    final nextState = getNextState(state);
    if (nextState != null) {
      emit(nextState);
    }
  }

  /// Helper method to get current cart line by item ID
  CartLine? getLineByItemId(String itemId) {
    return state.findLineByItemId(itemId);
  }

  /// Helper method to check if item exists in cart
  bool hasItem(String itemId) {
    return getLineByItemId(itemId) != null;
  }

  /// Helper method to get item quantity in cart
  int getItemQuantity(String itemId) {
    final line = getLineByItemId(itemId);
    return line?.quantity ?? 0;
  }

  /// Helper method to get item discount in cart
  double getItemDiscount(String itemId) {
    final line = getLineByItemId(itemId);
    return line?.discount ?? 0.0;
  }
}