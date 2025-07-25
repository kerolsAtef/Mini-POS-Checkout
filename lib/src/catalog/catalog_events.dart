import 'package:equatable/equatable.dart';
import 'item.dart';

/// Base class for all catalog events
abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the catalog from assets
class LoadCatalog extends CatalogEvent {
  const LoadCatalog();

  @override
  String toString() => 'LoadCatalog()';
}
