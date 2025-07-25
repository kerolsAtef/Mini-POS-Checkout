import 'package:equatable/equatable.dart';

/// Represents a product item in the catalog
class Item extends Equatable {
  /// Unique identifier for the item
  final String id;

  /// Display name of the item
  final String name;

  /// Price of the item in currency units
  final double price;

  const Item({
    required this.id,
    required this.name,
    required this.price,
  });

  /// Creates an Item from JSON map
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  /// Converts Item to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [id, name, price];

  @override
  String toString() => 'Item(id: $id, name: $name, price: $price)';
}