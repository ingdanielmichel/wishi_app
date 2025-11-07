import 'package:wishi_app/domain/models/order.dart';

class OrderBuilderState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  OrderBuilderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrderBuilderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderBuilderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
