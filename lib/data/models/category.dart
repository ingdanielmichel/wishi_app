// Represents a menu category (e.g., Tacos, Bebidas).
class MenuCategory {
  final String id;
  final String name;
  final int order;

  MenuCategory({
    required this.id,
    required this.name,
    required this.order,
  });

  // TODO: Add factory constructor for Firestore data
  // factory MenuCategory.fromFirestore(DocumentSnapshot doc) { ... }
}
