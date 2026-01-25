import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/data/models/checkout_session_dto.dart';
import 'package:wishi_app/domain/models/checkout_session.dart';
import 'package:wishi_app/domain/models/order_extensions.dart';

import 'package:wishi_app/data/models/order_dto.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_status.dart';
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

    final orderWithUserId = order.copyWith(userId: userId);

    final orderDTO = orderWithUserId.toDTO();
    await _firestore
        .collection('orders')
        .doc(orderDTO.id)
        .set(orderDTO.toJson());
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }

  @override
  Future<Order?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return OrderDTO.fromJson(doc.data()!).toDomain();
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
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => OrderDTO.fromJson(doc.data()).toDomain())
        .toList();
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .where('status', isEqualTo: status.toJson())
        .get();

    return snapshot.docs
        .map((doc) => OrderDTO.fromJson(doc.data()).toDomain())
        .toList();
  }

  @override
  Future<List<Order>> getDraftOrders() async {
    return getOrdersByStatus(OrderStatus.draft);
  }

  @override
  Future<List<Order>> getCompletedOrders() async {
    return getOrdersByStatus(OrderStatus.completed);
  }

  @override
  Future<void> updateOrder(Order order) async {
    final orderDTO = order.toDTO();
    await _firestore
        .collection('orders')
        .doc(orderDTO.id)
        .update(orderDTO.toJson());
  }

  @override
  Future<String> createCheckoutSession(List<Order> orders) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    if (orders.isEmpty) {
      throw Exception('No orders to checkout');
    }

    // Calculate total amount in cents (Mexican Peso)
    // Used for potential validation or logging, though line_items overrides it for checkout
    // final totalAmount = orders.fold<double>(
    //   0,
    //   (sum, order) => sum + order.total,
    // );
    // final amountInCents = (totalAmount * 100).round();

    // Create a unique session ID
    const uuid = Uuid();
    final sessionId = uuid.v4();

    // Prepare order IDs for reference
    final orderIds = orders.map((o) => o.id).toList();

    // Create checkout session document in Firestore
    // The Stripe extension will listen to this and add payment secrets

    // Ensure customer document exists for the extension to work
    final customerDocRef = _firestore.collection('customers').doc(userId);
    final customerDoc = await customerDocRef.get();

    if (!customerDoc.exists) {
      await customerDocRef.set({
        'email': _firebaseAuth.currentUser?.email,
        'metadata': {'source': 'app'},
      });
    }

    // Create line items for Stripe Checkout
    final lineItems = [];
    for (final order in orders) {
      for (final item in order.items) {
        lineItems.add({
          'price_data': {
            'currency': 'mxn',
            'product_data': {'name': item.name},
            'unit_amount': (item.price * 100).round(),
          },
          'quantity': item.quantity,
        });
      }
    }

    final sessionData = {
      'id': sessionId,
      'orderId': orderIds.join(','), // Store multiple order IDs
      'client': kIsWeb ? 'web' : 'mobile',
      'mode': 'payment',
      'line_items': lineItems,
      'success_url': 'https://wishi-app.web.app/success',
      'cancel_url': 'https://wishi-app.web.app/cancel',
      'status': 'open',
      'createdAt': firestore.FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('customers')
        .doc(userId)
        .collection('checkout_sessions')
        .doc(sessionId)
        .set(sessionData);

    // Update orders to pending payment status
    for (final order in orders) {
      await updateOrder(order.copyWith(status: OrderStatus.pendingPayment));
    }

    return sessionId;
  }

  @override
  Stream<CheckoutSession?> watchCheckoutSession(String sessionId) {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('customers')
        .doc(userId)
        .collection('checkout_sessions')
        .doc(sessionId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;

          final data = snapshot.data()!;
          print('DEBUG: Checkout Session Snapshot: $data');
          // Add the document ID to the data
          data['id'] = snapshot.id;

          // Handle Firestore Timestamp conversion
          if (data['createdAt'] is firestore.Timestamp) {
            final timestamp = data['createdAt'] as firestore.Timestamp;
            data['createdAt'] = timestamp.millisecondsSinceEpoch;
          }

          return CheckoutSession.fromDTO(CheckoutSessionDTO.fromJson(data));
        });
  }

  @override
  Future<void> completeOrders(
    List<String> orderIds,
    String paymentIntentId,
  ) async {
    // Update all orders to completed status
    for (final orderId in orderIds) {
      final order = await getOrder(orderId);
      if (order != null) {
        await updateOrder(
          order.copyWith(
            status: OrderStatus.completed,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }
}
