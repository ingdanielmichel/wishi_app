import 'package:wishi_app/domain/models/order_item.dart';

class Order {
  final String id;
  final String name;
  final List<OrderItem> items;
  final double total;

  Order({
    required this.id,
    required this.name,
    required this.items,
    required this.total,
  });
}
