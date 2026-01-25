import 'package:wishi_app/data/models/order_dto.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/domain/models/order_status.dart';

class Order {
  final String id;
  final String userId;
  final String name;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.name,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromDTO(OrderDTO dto) {
    return Order(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      items: dto.items.map((itemDto) => OrderItem.fromDTO(itemDto)).toList(),
      total: dto.total,
      status: OrderStatus.fromJson(dto.status),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  OrderDTO toDTO() {
    return OrderDTO(
      id: id,
      userId: userId,
      name: name,
      items: items.map((item) => item.toDTO()).toList(),
      total: total,
      status: status.toJson(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Order copyWith({
    String? id,
    String? userId,
    String? name,
    List<OrderItem>? items,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
