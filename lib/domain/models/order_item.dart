import 'package:wishi_app/data/models/order_item_dto.dart';

class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final Map<String, dynamic> selectedOptions;

  OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    this.category = 'General',
    required this.quantity,
    required this.price,
    this.selectedOptions = const {},
  });

  factory OrderItem.fromDTO(OrderItemDTO dto) {
    return OrderItem(
      id: dto.id,
      menuItemId: dto.menuItemId,
      name: dto.name,
      category: dto.category ?? 'General',
      quantity: dto.quantity,
      price: dto.price,
      selectedOptions: dto.selectedOptions,
    );
  }

  OrderItemDTO toDTO() {
    return OrderItemDTO(
      id: id,
      menuItemId: menuItemId,
      name: name,
      category: category,
      quantity: quantity,
      price: price,
      selectedOptions: selectedOptions,
    );
  }

  OrderItem copyWith({
    String? id,
    String? menuItemId,
    String? name,
    String? category,
    int? quantity,
    double? price,
    Map<String, dynamic>? selectedOptions,
  }) {
    return OrderItem(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }
}
