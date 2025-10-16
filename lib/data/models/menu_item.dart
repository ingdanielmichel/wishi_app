// Represents a single item on the menu (e.g., a specific taco or drink).
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final bool available;
  // final List<MenuItemOption> options;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
    required this.available,
    // required this.options,
  });

  // TODO: Add factory constructor for Firestore data
  // factory MenuItem.fromFirestore(DocumentSnapshot doc) { ... }
}
