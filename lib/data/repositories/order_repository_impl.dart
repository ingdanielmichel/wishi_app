import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wishi_app/data/models/order_dto.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final firestore.FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  OrderRepositoryImpl(this._firestore, this._firebaseAuth);

  @override
  Future<void> createOrder(Order order) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final orderWithUserId = Order(
      id: order.id,
      userId: userId,
      name: order.name,
      items: order.items,
      total: order.total,
    );

    final orderDTO = OrderDTO.fromDomain(orderWithUserId);
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
  Future<List<Order>> getOrders() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => OrderDTO.fromFirestore(doc.data()).toDomain())
        .toList();
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
