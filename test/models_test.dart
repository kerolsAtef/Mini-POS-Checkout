import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pos_app/src/cart/cart_state.dart';
import 'package:mini_pos_app/src/mini_pos_checkout.dart';


void main() {
  group('Models Tests', () {
    late Item coffeeItem;
    late Item bagelItem;

    setUp(() {
      coffeeItem = const Item(id: 'p01', name: 'Coffee', price: 2.50);
      bagelItem = const Item(id: 'p02', name: 'Bagel', price: 3.20);
    });

    group('Item', () {
      test('equality works correctly', () {
        const item1 = Item(id: 'p01', name: 'Coffee', price: 2.50);
        const item2 = Item(id: 'p01', name: 'Coffee', price: 2.50);
        const item3 = Item(id: 'p02', name: 'Tea', price: 2.00);

        expect(item1, equals(item2));
        expect(item1, isNot(equals(item3)));
      });

      test('JSON serialization works correctly', () {
        const item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        final json = item.toJson();
        expect(json['id'], 'p01');
        expect(json['name'], 'Coffee');
        expect(json['price'], 2.50);

        final itemFromJson = Item.fromJson(json);
        expect(itemFromJson, equals(item));
      });

      test('toString provides useful information', () {
        const item = Item(id: 'p01', name: 'Coffee', price: 2.50);
        expect(item.toString(), contains('Coffee'));
        expect(item.toString(), contains('2.5'));
      });
    });

    group('CartLine', () {
      test('calculates lineNet correctly without discount', () {
        final line = CartLine(item: coffeeItem, quantity: 3);
        expect(line.lineNet, 7.50); // 2.50 × 3
      });

      test('calculates lineNet correctly with discount', () {
        final line = CartLine(
          item: coffeeItem,
          quantity: 2,
          discount: 0.2, // 20% discount
        );

        // 2.50 × 2 × (1 - 0.2) = 5.00 × 0.8 = 4.00
        expect(line.lineNet, 4.00);
      });

      test('copyWith works correctly', () {
        final original = CartLine(item: coffeeItem, quantity: 2, discount: 0.1);

        final withNewQuantity = original.copyWith(quantity: 5);
        expect(withNewQuantity.quantity, 5);
        expect(withNewQuantity.item, coffeeItem);
        expect(withNewQuantity.discount, 0.1);

        final withNewDiscount = original.copyWith(discount: 0.2);
        expect(withNewDiscount.discount, 0.2);
        expect(withNewDiscount.quantity, 2);
        expect(withNewDiscount.item, coffeeItem);
      });

      test('equality works correctly', () {
        final line1 = CartLine(item: coffeeItem, quantity: 2, discount: 0.1);
        final line2 = CartLine(item: coffeeItem, quantity: 2, discount: 0.1);
        final line3 = CartLine(item: bagelItem, quantity: 2, discount: 0.1);

        expect(line1, equals(line2));
        expect(line1, isNot(equals(line3)));
      });
    });

    group('CartTotals', () {
      test('empty constructor works correctly', () {
        const totals = CartTotals.empty();
        expect(totals.subtotal, 0.0);
        expect(totals.vat, 0.0);
        expect(totals.totalDiscount, 0.0);
        expect(totals.grandTotal, 0.0);
      });

      test('equality works correctly', () {
        const totals1 = CartTotals(
          subtotal: 10.0,
          vat: 1.5,
          totalDiscount: 2.0,
          grandTotal: 11.5,
        );

        const totals2 = CartTotals(
          subtotal: 10.0,
          vat: 1.5,
          totalDiscount: 2.0,
          grandTotal: 11.5,
        );

        expect(totals1, equals(totals2));
      });
    });

    group('CartState', () {
      test('empty constructor works correctly', () {
        const state = CartState.empty();
        expect(state.isEmpty, true);
        expect(state.totalItems, 0);
        expect(state.lines.length, 0);
      });

      test('totalItems calculation works correctly', () {
        final state = CartState(
          lines: [
            CartLine(item: coffeeItem, quantity: 2),
            CartLine(item: bagelItem, quantity: 3),
          ],
          totals: const CartTotals.empty(),
        );

        expect(state.totalItems, 5); // 2 + 3
      });

      test('findLineByItemId works correctly', () {
        final state = CartState(
          lines: [
            CartLine(item: coffeeItem, quantity: 2),
            CartLine(item: bagelItem, quantity: 1),
          ],
          totals: const CartTotals.empty(),
        );

        final coffeeLine = state.findLineByItemId('p01');
        expect(coffeeLine?.item.name, 'Coffee');

        final nonExistentLine = state.findLineByItemId('p99');
        expect(nonExistentLine, isNull);
      });

      test('copyWith works correctly', () {
        const originalState = CartState.empty();
        final newLines = [CartLine(item: coffeeItem, quantity: 1)];

        final newState = originalState.copyWith(lines: newLines);
        expect(newState.lines.length, 1);
        expect(newState.totals, const CartTotals.empty());
      });
    });
  });

  group('Money Extensions', () {
    test('asMoney formats correctly', () {
      expect(2.5.asMoney, '2.50');
      expect(10.asMoney, '10.00');
      expect(3.14159.asMoney, '3.14');
      expect(0.asMoney, '0.00');
    });

    test('MoneyUtils.roundMoney works correctly', () {
      expect(MoneyUtils.roundMoney(2.555), 2.56);
      expect(MoneyUtils.roundMoney(2.554), 2.55);
      expect(MoneyUtils.roundMoney(10.0), 10.0);
    });

    test('MoneyUtils.calculateVat works correctly', () {
      expect(MoneyUtils.calculateVat(100.0), 15.0); // 100 × 0.15
      expect(MoneyUtils.calculateVat(10.0), 1.5);   // 10 × 0.15
      expect(MoneyUtils.calculateVat(0.0), 0.0);
    });

    test('MoneyUtils.calculateGrandTotal works correctly', () {
      expect(MoneyUtils.calculateGrandTotal(100.0, 15.0), 115.0);
      expect(MoneyUtils.calculateGrandTotal(10.0, 1.5), 11.5);
    });
  });

  group('CartCalculator', () {
    late Item coffeeItem;
    late Item bagelItem;
    setUp(() {
      coffeeItem = const Item(id: 'p01', name: 'Coffee', price: 2.50);
      bagelItem = const Item(id: 'p02', name: 'Bagel', price: 3.20);
    });
    test('calculates totals correctly for empty cart', () {
     var  totals = CartCalculator.calculateTotals([]);
      expect(totals, equals(const CartTotals.empty()));
    });

    test('calculates totals correctly for single item without discount', () {
      final lines = [CartLine(item: coffeeItem, quantity: 2)]; // 2 × 2.50 = 5.00

      final totals = CartCalculator.calculateTotals(lines);
      expect(totals.subtotal, 5.0);
      expect(totals.vat, 0.75); // 5.00 × 0.15
      expect(totals.totalDiscount, 0.0);
      expect(totals.grandTotal, 5.75); // 5.00 + 0.75
    });

    test('calculates totals correctly for multiple items with discounts', () {
      final lines = [
        CartLine(item: coffeeItem, quantity: 2, discount: 0.1), // 5.00 × 0.9 = 4.50
        CartLine(item: bagelItem, quantity: 1, discount: 0.0),  // 3.20 × 1.0 = 3.20
      ];

      final totals = CartCalculator.calculateTotals(lines);
      expect(totals.subtotal, 7.70); // 4.50 + 3.20
      expect(totals.vat, 1.16); // 7.70 × 0.15 (rounded)
      expect(totals.totalDiscount, 0.50); // 5.00 × 0.1
      expect(totals.grandTotal, 8.86); // 7.70 + 1.16
    });

    test('handles complex discount scenarios correctly', () {
      final expensiveItem = const Item(id: 'p99', name: 'Expensive', price: 100.0);
      final lines = [
        CartLine(item: expensiveItem, quantity: 1, discount: 0.5), // 50% off
        CartLine(item: coffeeItem, quantity: 4, discount: 0.25),   // 25% off
      ];

      final totals = CartCalculator.calculateTotals(lines);

      // expensiveItem: 100.0 × 1 × 0.5 = 50.0
      // coffeeItem: 2.50 × 4 × 0.75 = 7.5
      expect(totals.subtotal, 57.5); // 50.0 + 7.5
      expect(totals.vat, 8.63); // 57.5 × 0.15 (rounded)
      expect(totals.totalDiscount, 52.5); // (100.0 × 0.5) + (10.0 × 0.25)
      expect(totals.grandTotal, 66.13); // 57.5 + 8.63
    });
  });
}