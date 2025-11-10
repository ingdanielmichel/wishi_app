import 'package:wishi_app/data/models/order_item_dto.dart';
import 'package:wishi_app/domain/models/order.dart';

class OrderDTO {
  final String id;
  final String userId;
  final String name;
  final List<OrderItemDTO> items;
  final double total;

  OrderDTO({
    required this.id,
    required this.userId,
    required this.name,
    required this.items,
    required this.total,
  });

  factory OrderDTO.fromDomain(Order order) {
    return OrderDTO(
      id: order.id,
      userId: order.userId,
      name: order.name,
      items: order.items.map((item) => OrderItemDTO.fromDomain(item)).toList(),
      total: order.total,
    );
  }

  Order toDomain() {
    return Order(
      id: id,
      userId: userId,
      name: name,
      items: items.map((dto) => dto.toDomain()).toList(),
      total: total,
    );
  }

  factory OrderDTO.fromFirestore(Map<String, dynamic> data) {
    return OrderDTO(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemDTO.fromFirestore(item))
          .toList(),
      total: (data['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'items': items.map((item) => item.toFirestore()).toList(),
      'total': total,
    };
  }
}
