import 'package:equatable/equatable.dart';
import '../mini_pos_checkout.dart';


/// Base class for all catalog states
abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

/// Initial state when catalog is not loaded
class CatalogInitial extends CatalogState {
  const CatalogInitial();

  @override
  String toString() => 'CatalogInitial()';
}

/// State when catalog is being loaded
class CatalogLoading extends CatalogState {
  const CatalogLoading();

  @override
  String toString() => 'CatalogLoading()';
}

/// State when catalog is successfully loaded
class CatalogLoaded extends CatalogState {
  /// List of items in the catalog
  final List<Item> items;

  const CatalogLoaded(this.items);

  /// Find item by ID
  Item? findItemById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if item exists
  bool hasItem(String id) => findItemById(id) != null;

  /// Get total number of items
  int get itemCount => items.length;

  @override
  List<Object?> get props => [items];

  @override
  String toString() => 'CatalogLoaded(${items.length} items)';
}

/// State when catalog loading fails
class CatalogError extends CatalogState {
  /// Error message
  final String message;

  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'CatalogError($message)';
}