import 'package:wishi_app/data/models/menu_item_option_dto.dart';
import 'package:wishi_app/domain/models/order_item.dart';

class OrderItemDTO {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final MenuItemOptionDTO? selectedOption;

  OrderItemDTO({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.selectedOption,
  });

  factory OrderItemDTO.fromDomain(OrderItem orderItem) {
    return OrderItemDTO(
      id: orderItem.id,
      menuItemId: orderItem.menuItemId,
      name: orderItem.name,
      quantity: orderItem.quantity,
      price: orderItem.price,
      selectedOption: orderItem.selectedOption != null
          ? MenuItemOptionDTO.fromDomain(orderItem.selectedOption!)
          : null,
    );
  }

  OrderItem toDomain() {
    return OrderItem(
      id: id,
      menuItemId: menuItemId,
      name: name,
      quantity: quantity,
      price: price,
      selectedOption: selectedOption?.toDomain(),
    );
  }

  factory OrderItemDTO.fromFirestore(Map<String, dynamic> data) {
    return OrderItemDTO(
      id: data['id'] ?? '',
      menuItemId: data['menuItemId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      selectedOption: data['selectedOption'] != null
          ? MenuItemOptionDTO.fromFirestore(data['selectedOption'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'menuItemId': menuItemId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'selectedOption': selectedOption?.toFirestore(),
    };
  }
}
