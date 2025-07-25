import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pos_app/src/cart/cart_state.dart';
import 'package:mini_pos_app/src/cart/models.dart';
import 'package:mini_pos_app/src/cart/receipt.dart';
import 'package:mini_pos_app/src/catalog/item.dart';


void main() {
  group('Receipt', () {
    late Item coffeeItem;
    late Item bagelItem;
    late CartState cartState;
    late DateTime testTimestamp;

    setUp(() {
      coffeeItem = const Item(id: 'p01', name: 'Coffee', price: 2.50);
      bagelItem = const Item(id: 'p02', name: 'Bagel', price: 3.20);
      testTimestamp = DateTime(2025, 1, 15, 10, 30, 0);

      cartState = CartState(
        lines: [
          CartLine(item: coffeeItem, quantity: 2, discount: 0.1), // 10% discount
          CartLine(item: bagelItem, quantity: 1, discount: 0.0),  // No discount
        ],
        totals: const CartTotals(
          subtotal: 7.70, // (2.50 × 2 × 0.9) + (3.20 × 1) = 4.50 + 3.20
          vat: 1.16,      // 7.70 × 0.15
          totalDiscount: 0.50, // 5.00 × 0.1
          grandTotal: 8.86,    // 7.70 + 1.16
        ),
      );
    });

    group('buildReceipt function', () {
      test('creates receipt with correct header information', () {
        final receipt = buildReceipt(cartState, testTimestamp);

        expect(receipt.header.timestamp, testTimestamp);
        expect(receipt.header.transactionId, isNotNull);
        expect(receipt.header.transactionId, contains('TXN-'));
        expect(receipt.header.storeName, 'Izam Store');
      });

      test('creates receipt with correct line items', () {
        final receipt = buildReceipt(cartState, testTimestamp);

        expect(receipt.lines.length, 2);

        // Check coffee line
        final coffeeLine = receipt.lines[0];
        expect(coffeeLine.itemId, 'p01');
        expect(coffeeLine.itemName, 'Coffee');
        expect(coffeeLine.unitPrice, 2.50);
        expect(coffeeLine.quantity, 2);
        expect(coffeeLine.discount, 0.1);
        expect(coffeeLine.lineNet, 4.50); // 2.50 × 2 × (1 - 0.1)

        // Check bagel line
        final bagelLine = receipt.lines[1];
        expect(bagelLine.itemId, 'p02');
        expect(bagelLine.itemName, 'Bagel');
        expect(bagelLine.unitPrice, 3.20);
        expect(bagelLine.quantity, 1);
        expect(bagelLine.discount, 0.0);
        expect(bagelLine.lineNet, 3.20);
      });

      test('creates receipt with correct totals', () {
        final receipt = buildReceipt(cartState, testTimestamp);

        expect(receipt.totals.subtotal, 7.70);
        expect(receipt.totals.vat, 1.16);
        expect(receipt.totals.totalDiscount, 0.50);
        expect(receipt.totals.grandTotal, 8.86);
      });

      test('handles empty cart correctly', () {
        const emptyCart = CartState.empty();
        final receipt = buildReceipt(emptyCart, testTimestamp);

        expect(receipt.isEmpty, true);
        expect(receipt.lines.length, 0);
        expect(receipt.totalItems, 0);
        expect(receipt.totals.subtotal, 0.0);
        expect(receipt.totals.grandTotal, 0.0);
      });

      test('calculates total items correctly', () {
        final receipt = buildReceipt(cartState, testTimestamp);
        expect(receipt.totalItems, 3); // 2 coffees + 1 bagel
      });
    });

    group('ReceiptLine', () {
      test('calculates gross amount correctly', () {
        final line = ReceiptLine(
          itemId: 'p01',
          itemName: 'Coffee',
          unitPrice: 2.50,
          quantity: 3,
          discount: 0.2,
          lineNet: 6.00,
        );

        expect(line.grossAmount, 7.50); // 2.50 × 3
        expect(line.discountAmount, 1.50); // 7.50 × 0.2
      });

      test('fromCartLine factory works correctly', () {
        final cartLine = CartLine(
          item: coffeeItem,
          quantity: 2,
          discount: 0.15,
        );

        final receiptLine = ReceiptLine.fromCartLine(cartLine);

        expect(receiptLine.itemId, coffeeItem.id);
        expect(receiptLine.itemName, coffeeItem.name);
        expect(receiptLine.unitPrice, coffeeItem.price);
        expect(receiptLine.quantity, cartLine.quantity);
        expect(receiptLine.discount, cartLine.discount);
        expect(receiptLine.lineNet, cartLine.lineNet);
      });
    });

    group('ReceiptTotals', () {
      test('fromCartTotals factory works correctly', () {
        const cartTotals = CartTotals(
          subtotal: 10.00,
          vat: 1.50,
          totalDiscount: 2.00,
          grandTotal: 11.50,
        );

        final receiptTotals = ReceiptTotals.fromCartTotals(cartTotals);

        expect(receiptTotals.subtotal, cartTotals.subtotal);
        expect(receiptTotals.vat, cartTotals.vat);
        expect(receiptTotals.totalDiscount, cartTotals.totalDiscount);
        expect(receiptTotals.grandTotal, cartTotals.grandTotal);
      });
    });

    group('Receipt string representations', () {
      test('toString methods provide useful information', () {
        final receipt = buildReceipt(cartState, testTimestamp);

        expect(receipt.toString(), contains('2 lines'));
        expect(receipt.toString(), contains('8.86'));

        expect(receipt.lines.first.toString(), contains('Coffee'));
        expect(receipt.lines.first.toString(), contains('x2'));

        expect(receipt.totals.toString(), contains('7.70'));
        expect(receipt.totals.toString(), contains('8.86'));
      });
    });
  });
}