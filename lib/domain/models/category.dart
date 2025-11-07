import 'package:wishi_app/domain/models/menu_item.dart';

// Represents a menu category (e.g., Tacos, Bebidas).
class Category {
  final String id;
  final String name;
  final int order;
  final List<MenuItem> items;

  Category({
    required this.id,
    required this.name,
    required this.order,
    required this.items,
  });
}
