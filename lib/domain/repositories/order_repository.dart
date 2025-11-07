import 'package:wishi_app/domain/models/order.dart';

abstract class IOrderRepository {
  Future<void> createOrder(Order order);
  Future<Order?> getOrder(String orderId);
  Future<void> updateOrder(Order order);
  Future<void> deleteOrder(String orderId);
}
