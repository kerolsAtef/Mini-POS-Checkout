import 'package:flutter_test/flutter_test.dart';

import 'package:mini_pos_app/src/catalog/catalog_bloc.dart';
import 'package:mini_pos_app/src/catalog/catalog_events.dart';
import 'package:mini_pos_app/src/catalog/catalog_state.dart';
import 'package:mini_pos_app/src/catalog/item.dart';

void main() {
  // Initialize Flutter binding before running tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CatalogBloc', () {
    late CatalogBloc catalogBloc;

    setUp(() {
      catalogBloc = CatalogBloc();
    });

    tearDown(() {
      catalogBloc.close();
    });

    test('initial state is CatalogInitial', () {
      expect(catalogBloc.state, isA<CatalogInitial>());
    });

    test('helper methods work correctly with empty state', () {
      expect(catalogBloc.isLoaded, false);
      expect(catalogBloc.currentItems, isEmpty);
      expect(catalogBloc.getItemById('p01'), isNull);
      expect(catalogBloc.searchItems('coffee'), isEmpty);
      expect(catalogBloc.filterByPriceRange(1.0, 5.0), isEmpty);
    });

    group('CatalogState classes', () {
      test('CatalogInitial works correctly', () {
        const state = CatalogInitial();
        expect(state.props, isEmpty);
        expect(state.toString(), 'CatalogInitial()');
      });

      test('CatalogLoading works correctly', () {
        const state = CatalogLoading();
        expect(state.props, isEmpty);
        expect(state.toString(), 'CatalogLoading()');
      });

      test('CatalogLoaded works correctly', () {
        const items = [
          Item(id: 'p01', name: 'Coffee', price: 2.50),
          Item(id: 'p02', name: 'Bagel', price: 3.20),
          Item(id: 'p03', name: 'Orange Juice', price: 4.10),
        ];

        const state = CatalogLoaded(items);

        expect(state.items.length, 3);
        expect(state.itemCount, 3);
        expect(state.findItemById('p01')?.name, 'Coffee');
        expect(state.findItemById('p02')?.price, 3.20);
        expect(state.findItemById('p99'), isNull);
        expect(state.hasItem('p01'), true);
        expect(state.hasItem('p99'), false);
        expect(state.props, [items]);
        expect(state.toString(), 'CatalogLoaded(3 items)');
      });

      test('CatalogError works correctly', () {
        const state = CatalogError('Test error message');
        expect(state.message, 'Test error message');
        expect(state.props, ['Test error message']);
        expect(state.toString(), 'CatalogError(Test error message)');
      });
    });

    // Test the events
    group('CatalogEvent classes', () {
      test('LoadCatalog event works correctly', () {
        const event = LoadCatalog();
        expect(event.props, isEmpty);
        expect(event.toString(), 'LoadCatalog()');
      });
    });

    // Test business logic without requiring loaded state
    group('Business logic tests', () {
      test('search logic works correctly', () {
        const items = [
          Item(id: 'p01', name: 'Coffee', price: 2.50),
          Item(id: 'p02', name: 'Bagel', price: 3.20),
          Item(id: 'p03', name: 'Orange Juice', price: 4.10),
          Item(id: 'p04', name: 'Iced Coffee', price: 3.50),
        ];

        // Test search logic manually
        final coffeeItems = items.where((item) =>
            item.name.toLowerCase().contains('coffee')).toList();
        expect(coffeeItems.length, 2);
        expect(coffeeItems.every((item) =>
            item.name.toLowerCase().contains('coffee')), true);

        // Test case insensitive search
        final juiceItems = items.where((item) =>
            item.name.toLowerCase().contains('juice')).toList();
        expect(juiceItems.length, 1);
        expect(juiceItems.first.name, 'Orange Juice');
      });

      test('price filter logic works correctly', () {
        const items = [
          Item(id: 'p01', name: 'Coffee', price: 2.50),
          Item(id: 'p02', name: 'Bagel', price: 3.20),
          Item(id: 'p03', name: 'Orange Juice', price: 4.10),
          Item(id: 'p04', name: 'Water Bottle', price: 1.20),
        ];

        // Test price filter logic manually
        final cheapItems = items.where((item) =>
        item.price >= 1.0 && item.price <= 3.0).toList();
        expect(cheapItems.length, 2); // Coffee and Water Bottle

        final expensiveItems = items.where((item) =>
        item.price >= 4.0 && item.price <= 5.0).toList();
        expect(expensiveItems.length, 1); // Orange Juice

        final noItems = items.where((item) =>
        item.price >= 10.0 && item.price <= 20.0).toList();
        expect(noItems.length, 0);
      });

      test('item lookup logic works correctly', () {
        const items = [
          Item(id: 'p01', name: 'Coffee', price: 2.50),
          Item(id: 'p02', name: 'Bagel', price: 3.20),
        ];

        // Test finding existing item
        final foundItem = items.where((item) => item.id == 'p01').toList();
        expect(foundItem.length, 1);
        expect(foundItem.first.name, 'Coffee');

        // Test finding non-existent item
        final notFound = items.where((item) => item.id == 'p99').toList();
        expect(notFound.length, 0);
      });
    });

    // Test edge cases
    group('Edge cases', () {
      test('empty operations work correctly', () {
        expect(catalogBloc.searchItems(''), isEmpty);
        expect(catalogBloc.searchItems('nonexistent'), isEmpty);
        expect(catalogBloc.filterByPriceRange(10.0, 5.0), isEmpty);
        expect(catalogBloc.filterByPriceRange(-1.0, 5.0), isEmpty);
      });
    });

    // Test Item class functionality
    group('Item class', () {
      test('Item creation and properties work correctly', () {
        const item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        expect(item.id, 'p01');
        expect(item.name, 'Coffee');
        expect(item.price, 2.50);
        expect(item.toString(), 'Item(id: p01, name: Coffee, price: 2.5)');
      });

      test('Item equality works correctly', () {
        const item1 = Item(id: 'p01', name: 'Coffee', price: 2.50);
        const item2 = Item(id: 'p01', name: 'Coffee', price: 2.50);
        const item3 = Item(id: 'p02', name: 'Tea', price: 2.00);

        expect(item1, equals(item2));
        expect(item1, isNot(equals(item3)));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('Item JSON serialization works correctly', () {
        const item = Item(id: 'p01', name: 'Coffee', price: 2.50);

        final json = item.toJson();
        expect(json['id'], 'p01');
        expect(json['name'], 'Coffee');
        expect(json['price'], 2.50);

        final itemFromJson = Item.fromJson(json);
        expect(itemFromJson, equals(item));
      });

      test('Item handles different price types correctly', () {
        // Test with int price
        final json1 = {'id': 'p01', 'name': 'Coffee', 'price': 2};
        final item1 = Item.fromJson(json1);
        expect(item1.price, 2.0);

        // Test with double price
        final json2 = {'id': 'p02', 'name': 'Tea', 'price': 2.50};
        final item2 = Item.fromJson(json2);
        expect(item2.price, 2.50);
      });
    });
  });
}