import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'catalog_events.dart';
import 'catalog_state.dart';
import 'item.dart';

/// BLoC for managing catalog state and operations
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  /// Creates a new CatalogBloc with initial state
  CatalogBloc() : super(const CatalogInitial()) {
    // Register event handlers
    on<LoadCatalog>(_onLoadCatalog);
  }

  /// Handles loading the catalog from assets
  Future<void> _onLoadCatalog(LoadCatalog event, Emitter<CatalogState> emit) async {
    emit(const CatalogLoading());

    try {
      // Load JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/catalog.json');

      // Parse JSON
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      // Convert to Item objects
      final List<Item> items = jsonList
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();

      // Validate that we have items
      if (items.isEmpty) {
        emit(const CatalogError('Catalog is empty'));
        return;
      }

      // Emit loaded state
      emit(CatalogLoaded(items));

    } catch (e) {
      // Handle any errors during loading
      String errorMessage;

      if (e is FormatException) {
        errorMessage = 'Invalid JSON format in catalog.json';
      } else if (e is FlutterError) {
        errorMessage = 'Could not load catalog.json from assets';
      } else {
        errorMessage = 'Failed to load catalog: ${e.toString()}';
      }

      emit(CatalogError(errorMessage));
    }
  }

  /// Helper method to get current items (if loaded)
  List<Item> get currentItems {
    final currentState = state;
    if (currentState is CatalogLoaded) {
      return currentState.items;
    }
    return [];
  }

  /// Helper method to check if catalog is loaded
  bool get isLoaded => state is CatalogLoaded;

  /// Helper method to get item by ID
  Item? getItemById(String id) {
    final currentState = state;
    if (currentState is CatalogLoaded) {
      return currentState.findItemById(id);
    }
    return null;
  }

  /// Helper method to search items by name
  List<Item> searchItems(String query) {
    final currentState = state;
    if (currentState is CatalogLoaded && query.isNotEmpty) {
      return currentState.items
          .where((item) =>
          item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return [];
  }

  /// Helper method to filter items by price range
  List<Item> filterByPriceRange(double minPrice, double maxPrice) {
    final currentState = state;
    if (currentState is CatalogLoaded) {
      return currentState.items
          .where((item) => item.price >= minPrice && item.price <= maxPrice)
          .toList();
    }
    return [];
  }
}