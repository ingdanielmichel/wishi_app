import 'package:wishi_app/domain/models/order.dart';

abstract class IOrderRepository {
  Future<Order?> getOrder(String orderId);
  Future<List<Order>> getOrders();
  Future<void> createOrder(Order order);
  Future<void> updateOrder(Order order);
  Future<void> deleteOrder(String orderId);
}
