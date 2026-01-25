import 'package:wishi_app/domain/models/checkout_session.dart';
import 'package:wishi_app/domain/models/order.dart';

class CheckoutState {
  final List<Order> orders;
  final double totalAmount;
  final bool isLoading;
  final CheckoutSession? checkoutSession;
  final String? error;
  final CheckoutStatus status;
  final String? debugMessage;

  CheckoutState({
    this.orders = const [],
    this.totalAmount = 0.0,
    this.isLoading = false,
    this.checkoutSession,
    this.error,
    this.status = CheckoutStatus.initial,
    this.debugMessage,
  });

  CheckoutState copyWith({
    List<Order>? orders,
    double? totalAmount,
    bool? isLoading,
    CheckoutSession? checkoutSession,
    String? error,
    CheckoutStatus? status,
    String? debugMessage,
  }) {
    return CheckoutState(
      orders: orders ?? this.orders,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      checkoutSession: checkoutSession ?? this.checkoutSession,
      error: error ?? this.error,
      status: status ?? this.status,
      debugMessage: debugMessage ?? this.debugMessage,
    );
  }

  CheckoutState clearError() {
    return copyWith(error: null);
  }

  CheckoutState clearSession() {
    return CheckoutState(
      orders: orders,
      totalAmount: totalAmount,
      isLoading: false,
      checkoutSession: null,
      error: null,
      status: CheckoutStatus.initial,
      debugMessage: null,
    );
  }
}

enum CheckoutStatus {
  initial,
  creatingSession,
  waitingForPayment,
  processingPayment,
  paymentSucceeded,
  paymentFailed,
  orderCompleted,
}
