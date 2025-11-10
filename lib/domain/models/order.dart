import 'package:wishi_app/domain/models/order_item.dart';

class Order {
  final String id;
  final String userId;
  final String name;
  final List<OrderItem> items;
  final double total;

  Order({
    required this.id,
    required this.userId,
    required this.name,
    required this.items,
    required this.total,
  });

  Order copyWith({
    String? id,
    String? userId,
    String? name,
    List<OrderItem>? items,
    double? total,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}
