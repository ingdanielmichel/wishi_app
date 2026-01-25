class OrderItemDTO {
  final String id;
  final String menuItemId;
  final String name;
  final String? category;
  final int quantity;
  final double price;
  final Map<String, dynamic> selectedOptions;

  OrderItemDTO({
    required this.id,
    required this.menuItemId,
    required this.name,
    this.category,
    required this.quantity,
    required this.price,
    this.selectedOptions = const {},
  });

  factory OrderItemDTO.fromJson(Map<String, dynamic> json) => OrderItemDTO(
    id: json['id'] as String? ?? '',
    menuItemId: json['menu_item_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    category: json['category'] as String?,
    quantity: json['quantity'] as int? ?? 1,
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    selectedOptions: json['selected_options'] != null
        ? Map<String, dynamic>.from(json['selected_options'] as Map)
        : const {},
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'menu_item_id': menuItemId,
    'name': name,
    'category': category,
    'quantity': quantity,
    'price': price,
    'selected_options': selectedOptions,
  };
}
