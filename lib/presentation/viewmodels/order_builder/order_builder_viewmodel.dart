import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/presentation/viewmodels/order_builder/order_builder_state.dart';
import 'package:wishi_app/application/providers.dart';

class OrderBuilderViewModel extends Notifier<OrderBuilderState> {
  @override
  OrderBuilderState build() {
    return OrderBuilderState();
  }

  Future<void> createOrder(Order order) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    try {
      state = state.copyWith(isLoading: true);
      await orderRepository.createOrder(order);
      final updatedOrders = List<Order>.from(state.orders)..add(order);
      state = state.copyWith(isLoading: false, orders: updatedOrders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateOrder(Order order) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    try {
      state = state.copyWith(isLoading: true);
      // Find the index of the order to update
      final index = state.orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        // Replace the old order with the updated one
        final updatedOrders = List<Order>.from(state.orders);
        updatedOrders[index] = order;
        await orderRepository.updateOrder(order);
        state = state.copyWith(isLoading: false, orders: updatedOrders);
      } else {
        // If the order doesn't exist, create it
        await createOrder(order);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
