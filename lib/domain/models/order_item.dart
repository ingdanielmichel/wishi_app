
class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final Map<String, dynamic> selectedOptions;

  OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.selectedOptions = const {},
  });

  OrderItem copyWith({
    String? id,
    String? menuItemId,
    String? name,
    int? quantity,
    double? price,
    Map<String, dynamic>? selectedOptions,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }
}
