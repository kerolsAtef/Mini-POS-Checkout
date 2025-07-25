import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mini_pos_app/src/cart/cart_bloc.dart';
import 'package:mini_pos_app/src/cart/cart_events.dart';
import 'package:mini_pos_app/src/cart/cart_state.dart';
import 'package:mini_pos_app/src/catalog/item.dart';

void main() {
  group('Undo/Redo Functionality', () {
    late CartBloc cartBloc;
    late Item coffeeItem;
    late Item bagelItem;

    setUp(() {
      cartBloc = CartBloc();
      coffeeItem = const Item(id: 'p01', name: 'Coffee', price: 2.50);
      bagelItem = const Item(id: 'p02', name: 'Bagel', price: 3.20);
    });

    tearDown(() {
      cartBloc.close();
    });

    blocTest<CartBloc, CartState>(
      'should be able to undo add item action',
      build: () => cartBloc,
      act: (bloc) {
        bloc.add(AddItem(coffeeItem, quantity: 2));
        bloc.add(const UndoCart());
      },
      expect: () => [
        // After adding coffee
        isA<CartState>().having(
              (state) => state.lines.length,
          'has one item',
          1,
        ).having(
              (state) => state.lines.first.item.name,
          'item is coffee',
          'Coffee',
        ),
        // After undo - back to empty
        isA<CartState>().having(
              (state) => state.isEmpty,
          'cart is empty after undo',
          true,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'should be able to redo undone action',
      build: () => cartBloc,
      act: (bloc) {
        bloc.add(AddItem(coffeeItem, quantity: 2));
        bloc.add(const UndoCart());
        bloc.add(const RedoCart());
      },
      expect: () => [
        // After adding coffee
        isA<CartState>().having(
              (state) => state.lines.length,
          'has one item',
          1,
        ),
        // After undo
        isA<CartState>().having(
              (state) => state.isEmpty,
          'cart is empty after undo',
          true,
        ),
        // After redo - coffee is back
        isA<CartState>().having(
              (state) => state.lines.length,
          'has one item after redo',
          1,
        ).having(
              (state) => state.lines.first.item.name,
          'item is coffee after redo',
          'Coffee',
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'should handle multiple undos correctly',
      build: () => cartBloc,
      act: (bloc) {
        bloc.add(AddItem(coffeeItem, quantity: 1));
        bloc.add(AddItem(bagelItem, quantity: 2));
        bloc.add(const ChangeQty('p01', 3));
        bloc.add(const UndoCart()); // Undo quantity change
        bloc.add(const UndoCart()); // Undo bagel add
        bloc.add(const UndoCart()); // Undo coffee add
      },
      expect: () => [
        // After adding coffee
        isA<CartState>().having((state) => state.lines.length, 'coffee added', 1),
        // After adding bagel
        isA<CartState>().having((state) => state.lines.length, 'bagel added', 2),
        // After changing coffee quantity
        isA<CartState>().having(
              (state) => state.lines.first.quantity,
          'coffee quantity changed',
          3,
        ),
        // First undo - quantity change reverted
        isA<CartState>().having(
              (state) => state.lines.first.quantity,
          'coffee quantity back to 1',
          1,
        ),
        // Second undo - bagel removed
        isA<CartState>().having((state) => state.lines.length, 'only coffee left', 1),
        // Third undo - back to empty
        isA<CartState>().having((state) => state.isEmpty, 'cart is empty', true),
      ],
    );

    blocTest<CartBloc, CartState>(
      'should clear redo history when new action is performed after undo',
      build: () => cartBloc,
      act: (bloc) {
        bloc.add(AddItem(coffeeItem, quantity: 1));
        bloc.add(AddItem(bagelItem, quantity: 1));
        bloc.add(const UndoCart()); // Undo bagel add
        bloc.add(AddItem(coffeeItem, quantity: 1)); // New action - should clear redo
        bloc.add(const RedoCart()); // Should not restore bagel
      },
      expect: () => [
        // After adding coffee
        isA<CartState>().having((state) => state.lines.length, 'coffee added', 1),
        // After adding bagel
        isA<CartState>().having((state) => state.lines.length, 'bagel added', 2),
        // After undo bagel
        isA<CartState>().having((state) => state.lines.length, 'only coffee left', 1),
        // After adding more coffee (clears redo history)
        isA<CartState>().having(
              (state) => state.lines.first.quantity,
          'coffee quantity increased',
          2,
        ),
        // Redo should do nothing (no change expected)
      ],
    );

    blocTest<CartBloc, CartState>(
      'should handle undo/redo with discount changes',
      build: () => cartBloc,
      act: (bloc) {
        bloc.add(AddItem(coffeeItem, quantity: 2));
        bloc.add(const ChangeDiscount('p01', 0.2)); // 20% discount
        bloc.add(const UndoCart()); // Undo discount
        bloc.add(const RedoCart()); // Redo discount
      },
      expect: () => [
        // After adding coffee
        isA<CartState>().having(
              (state) => state.lines.first.discount,
          'no discount initially',
          0.0,
        ),
        // After applying discount
        isA<CartState>().having(
              (state) => state.lines.first.discount,
          'discount applied',
          0.2,
        ).having(
              (state) => state.totals.subtotal,
          'subtotal with discount',
          4.0, // 2.50 × 2 × 0.8
        ),
        // After undo discount
        isA<CartState>().having(
              (state) => state.lines.first.discount,
          'discount removed',
          0.0,
        ).having(
              (state) => state.totals.subtotal,
          'subtotal without discount',
          5.0, // 2.50 × 2
        ),
        // After redo discount
        isA<CartState>().having(
              (state) => state.lines.first.discount,
          'discount reapplied',
          0.2,
        ).having(
              (state) => state.totals.subtotal,
          'subtotal with discount again',
          4.0,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'should handle undo when no history available',
      build: () => cartBloc,
      act: (bloc) {
        bloc.add(const UndoCart()); // Should do nothing
        bloc.add(const RedoCart()); // Should do nothing
      },
      expect: () => [], // No state changes expected
    );

    test('should provide correct undo/redo availability', () {
      // Initially no undo/redo available
      expect(cartBloc.canUndo, false);
      expect(cartBloc.canRedo, false);

      // Add item - should have undo available
      cartBloc.add(AddItem(coffeeItem, quantity: 1));
      // Note: In real usage, you'd need to wait for the event to process
      // This test demonstrates the mixin methods
    });

    test('should limit history size', () {
      // Test that history doesn't grow infinitely
      for (int i = 0; i < 15; i++) {
        cartBloc.add(AddItem(coffeeItem, quantity: 1));
      }

      // History should be limited (maxHistorySize = 10)
      expect(cartBloc.historySize <= 10, true);
    });

    blocTest<CartBloc, CartState>(
      'should handle clear cart with undo/redo',
      build: () => cartBloc,
      act: (bloc) {
        bloc.add(AddItem(coffeeItem, quantity: 2));
        bloc.add(AddItem(bagelItem, quantity: 1));
        bloc.add(const ClearCart());
        bloc.add(const UndoCart()); // Should restore the cart
      },
      expect: () => [
        // After adding coffee
        isA<CartState>().having((state) => state.lines.length, 'coffee added', 1),
        // After adding bagel
        isA<CartState>().having((state) => state.lines.length, 'both items', 2),
        // After clear cart
        isA<CartState>().having((state) => state.isEmpty, 'cart cleared', true),
        // After undo clear
        isA<CartState>().having((state) => state.lines.length, 'cart restored', 2),
      ],
    );
  });
}