import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:wishi_app/data/models/order_dto.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final firestore.FirebaseFirestore _firestore;

  OrderRepositoryImpl(this._firestore);

  @override
  Future<void> createOrder(Order order) async {
    final orderDTO = OrderDTO.fromDomain(order);
    await _firestore
        .collection('orders')
        .doc(orderDTO.id)
        .set(orderDTO.toFirestore());
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderDTO.fromFirestore(doc.data()!).toDomain();
    }
    return null;
  }

  @override
  Future<void> updateOrder(Order order) async {
    final orderDTO = OrderDTO.fromDomain(order);
    await _firestore
        .collection('orders')
        .doc(orderDTO.id)
        .update(orderDTO.toFirestore());
  }
}
