import 'package:wishi_app/domain/models/order_item.dart';

class OrderItemDTO {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final Map<String, dynamic> selectedOptions;

  OrderItemDTO({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.selectedOptions = const {},
  });

  factory OrderItemDTO.fromDomain(OrderItem orderItem) {
    return OrderItemDTO(
      id: orderItem.id,
      menuItemId: orderItem.menuItemId,
      name: orderItem.name,
      quantity: orderItem.quantity,
      price: orderItem.price,
      selectedOptions: orderItem.selectedOptions,
    );
  }

  OrderItem toDomain() {
    return OrderItem(
      id: id,
      menuItemId: menuItemId,
      name: name,
      quantity: quantity,
      price: price,
      selectedOptions: selectedOptions,
    );
  }

  factory OrderItemDTO.fromFirestore(Map<String, dynamic> data) {
    return OrderItemDTO(
      id: data['id'] ?? '',
      menuItemId: data['menuItemId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      selectedOptions: (data['selectedOptions'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'selectedOptions': selectedOptions,
    };
  }
}
