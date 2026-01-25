import 'package:wishi_app/domain/models/checkout_session.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_status.dart';

abstract class IOrderRepository {
  Future<Order?> getOrder(String orderId);
  Future<List<Order>> getOrders();
  Future<List<Order>> getOrdersByStatus(OrderStatus status);
  Future<List<Order>> getDraftOrders();
  Future<List<Order>> getCompletedOrders();
  Future<void> createOrder(Order order);
  Future<void> updateOrder(Order order);
  Future<void> deleteOrder(String orderId);

  // Checkout session methods
  Future<String> createCheckoutSession(List<Order> orders);
  Stream<CheckoutSession?> watchCheckoutSession(String sessionId);
  Future<void> completeOrders(List<String> orderIds, String paymentIntentId);
}
