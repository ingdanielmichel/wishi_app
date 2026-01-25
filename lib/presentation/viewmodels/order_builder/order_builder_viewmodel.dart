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
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateOrder(Order order) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    try {
      state = state.copyWith(isLoading: true);
      await orderRepository.updateOrder(order);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteOrder(String orderId) async {
    final orderRepository = ref.read(orderRepositoryProvider);
    try {
      state = state.copyWith(isLoading: true);
      await orderRepository.deleteOrder(orderId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
