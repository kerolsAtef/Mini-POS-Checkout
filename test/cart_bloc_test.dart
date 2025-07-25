import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mini_pos_app/src/cart/cart_bloc.dart';
import 'package:mini_pos_app/src/cart/cart_events.dart';
import 'package:mini_pos_app/src/cart/cart_state.dart';
import 'package:mini_pos_app/src/cart/models.dart';
import 'package:mini_pos_app/src/catalog/item.dart';


void main() {
  group('CartBloc', () {
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

    test('initial state is empty cart', () {
      expect(cartBloc.state, equals(const CartState.empty()));
      expect(cartBloc.state.isEmpty, true);
      expect(cartBloc.state.totalItems, 0);
    });

    group('Required Tests (as per task requirements)', () {
      // REQUIRED TEST 1: Two different items → correct totals
      blocTest<CartBloc, CartState>(
        'Test 1: Two different items should calculate correct totals',
        build: () => cartBloc,
        act: (bloc) {
          bloc.add(AddItem(coffeeItem, quantity: 2)); // 2 × 2.50 = 5.00
          bloc.add(AddItem(bagelItem, quantity: 1));  // 1 × 3.20 = 3.20
        },
        expect: () => [
          // After adding coffee
          isA<CartState>().having(
                (state) => state.lines.length,
            'lines count after coffee',
            1,
          ).having(
                (state) => state.totals.subtotal,
            'subtotal after coffee',
            5.00,
          ).having(
                (state) => state.totals.vat,
            'vat after coffee',
            0.75, // 5.00 × 0.15
          ).having(
                (state) => state.totals.grandTotal,
            'grand total after coffee',
            5.75, // 5.00 + 0.75
          ),
          // After adding bagel
          isA<CartState>().having(
                (state) => state.lines.length,
            'lines count after bagel',
            2,
          ).having(
                (state) => state.totals.subtotal,
            'subtotal after bagel',
            8.20, // 5.00 + 3.20
          ).having(
                (state) => state.totals.vat,
            'vat after bagel',
            1.23, // 8.20 × 0.15
          ).having(
                (state) => state.totals.grandTotal,
            'grand total after bagel',
            9.43, // 8.20 + 1.23
          ),
        ],
      );

      // REQUIRED TEST 2: Qty + discount changes update totals
      blocTest<CartBloc, CartState>(
        'Test 2: Quantity and discount changes should update totals correctly',
        build: () => cartBloc,
        act: (bloc) {
          bloc.add(AddItem(coffeeItem, quantity: 1)); // Start with 1 coffee
          bloc.add(const ChangeQty('p01', 3)); // Change qty to 3
          bloc.add(const ChangeDiscount('p01', 0.10)); // Add 10% discount
        },
        expect: () => [
          // After adding coffee (1×)
          isA<CartState>().having(
                (state) => state.lines.first.quantity,
            'initial quantity',
            1,
          ).having(
                (state) => state.totals.subtotal,
            'initial subtotal',
            2.50, // 2.50 × 1
          ),
          // After quantity change to 3
          isA<CartState>().having(
                (state) => state.lines.first.quantity,
            'quantity after change',
            3,
          ).having(
                (state) => state.totals.subtotal,
            'subtotal after qty change',
            7.50, // 2.50 × 3
          ).having(
                (state) => state.totals.grandTotal,
            'grand total after qty change',
            8.63, // 7.50 + (7.50 × 0.15) = 7.50 + 1.13
          ),
          // After 10% discount
          isA<CartState>().having(
                (state) => state.lines.first.discount,
            'discount after change',
            0.10,
          ).having(
                (state) => state.lines.first.lineNet,
            'line net after discount',
            6.75, // 7.50 × (1 - 0.10)
          ).having(
                (state) => state.totals.subtotal,
            'subtotal after discount',
            6.75,
          ).having(
                (state) => state.totals.totalDiscount,
            'total discount amount',
            0.75, // 7.50 × 0.10
          ).having(
                (state) => state.totals.grandTotal,
            'grand total after discount',
            7.76, // 6.75 + (6.75 × 0.15) = 6.75 + 1.01
          ),
        ],
      );

      // REQUIRED TEST 3: Clearing cart resets state
      blocTest<CartBloc, CartState>(
        'Test 3: Clearing cart should reset state to empty',
        build: () => cartBloc,
        seed: () {
          // Start with items in cart
          return CartState(
            lines: [
              CartLine(item: coffeeItem, quantity: 2),
              CartLine(item: bagelItem, quantity: 1),
            ],
            totals: const CartTotals(
              subtotal: 8.20,
              vat: 1.23,
              totalDiscount: 0.0,
              grandTotal: 9.43,
            ),
          );
        },
        act: (bloc) => bloc.add(const ClearCart()),
        expect: () => [
          isA<CartState>().having(
                (state) => state.isEmpty,
            'cart is empty',
            true,
          ).having(
                (state) => state.lines.length,
            'no lines',
            0,
          ).having(
                (state) => state.totals.subtotal,
            'subtotal is zero',
            0.0,
          ).having(
                (state) => state.totals.grandTotal,
            'grand total is zero',
            0.0,
          ),
        ],
      );
    });

    group('Additional AddItem Tests', () {
      blocTest<CartBloc, CartState>(
        'adding same item twice should update quantity',
        build: () => cartBloc,
        act: (bloc) {
          bloc.add(AddItem(coffeeItem, quantity: 1));
          bloc.add(AddItem(coffeeItem, quantity: 2)); // Should add to existing
        },
        expect: () => [
          // First add
          isA<CartState>().having(
                (state) => state.lines.length,
            'one line after first add',
            1,
          ).having(
                (state) => state.lines.first.quantity,
            'quantity after first add',
            1,
          ),
          // Second add (should combine)
          isA<CartState>().having(
                (state) => state.lines.length,
            'still one line after second add',
            1,
          ).having(
                (state) => state.lines.first.quantity,
            'combined quantity',
            3,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'should not add item with zero or negative quantity',
        build: () => cartBloc,
        act: (bloc) {
          bloc.add(AddItem(coffeeItem, quantity: 0));
          bloc.add(AddItem(bagelItem, quantity: -1));
        },
        expect: () => [],
      );
    });

    group('RemoveItem Tests', () {
      blocTest<CartBloc, CartState>(
        'should remove item from cart',
        build: () => cartBloc,
        seed: () => CartState(
          lines: [
            CartLine(item: coffeeItem, quantity: 2),
            CartLine(item: bagelItem, quantity: 1),
          ],
          totals: const CartTotals(
            subtotal: 8.20,
            vat: 1.23,
            totalDiscount: 0.0,
            grandTotal: 9.43,
          ),
        ),
        act: (bloc) => bloc.add(const RemoveItem('p01')),
        expect: () => [
          isA<CartState>().having(
                (state) => state.lines.length,
            'one item removed',
            1,
          ).having(
                (state) => state.lines.first.item.id,
            'remaining item is bagel',
            'p02',
          ).having(
                (state) => state.totals.subtotal,
            'subtotal updated',
            3.20,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'removing non-existent item should not change state',
        build: () => cartBloc,
        seed: () => CartState(
          lines: [CartLine(item: coffeeItem, quantity: 1)],
          totals: const CartTotals(
            subtotal: 2.50,
            vat: 0.38,
            totalDiscount: 0.0,
            grandTotal: 2.88,
          ),
        ),
        act: (bloc) => bloc.add(const RemoveItem('p99')),
        expect: () => [],
      );
    });

    group('ChangeQty Tests', () {
      blocTest<CartBloc, CartState>(
        'changing quantity to zero should remove item',
        build: () => cartBloc,
        seed: () => CartState(
          lines: [CartLine(item: coffeeItem, quantity: 2)],
          totals: const CartTotals(
            subtotal: 5.00,
            vat: 0.75,
            totalDiscount: 0.0,
            grandTotal: 5.75,
          ),
        ),
        act: (bloc) => bloc.add(const ChangeQty('p01', 0)),
        expect: () => [
          isA<CartState>().having(
                (state) => state.isEmpty,
            'cart becomes empty',
            true,
          ),
        ],
      );

      blocTest<CartBloc, CartState>(
        'changing quantity of non-existent item should not change state',
        build: () => cartBloc,
        act: (bloc) => bloc.add(const ChangeQty('p99', 5)),
        expect: () => [],
      );
    });

    group('ChangeDiscount Tests', () {
      blocTest<CartBloc, CartState>(
        'should reject invalid discount values',
        build: () => cartBloc,
        seed: () => CartState(
          lines: [CartLine(item: coffeeItem, quantity: 1)],
          totals: const CartTotals(
            subtotal: 2.50,
            vat: 0.38,
            totalDiscount: 0.0,
            grandTotal: 2.88,
          ),
        ),
        act: (bloc) {
          bloc.add(const ChangeDiscount('p01', -0.1)); // Invalid: negative
          bloc.add(const ChangeDiscount('p01', 1.1));  // Invalid: > 1.0
        },
        expect: () => [],
      );

      blocTest<CartBloc, CartState>(
        'changing discount of non-existent item should not change state',
        build: () => cartBloc,
        act: (bloc) => bloc.add(const ChangeDiscount('p99', 0.1)),
        expect: () => [],
      );
    });

    group('Helper Methods Tests', () {
      test('helper methods work correctly', () {
        // Add some items
        cartBloc.add(AddItem(coffeeItem, quantity: 2));

        expect(cartBloc.hasItem('p01'), false);
        expect(cartBloc.getItemQuantity('p01'), 0);
        expect(cartBloc.getItemDiscount('p01'), 0.0);
      });
    });
  });
}