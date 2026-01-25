import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/application/services/analytics_service.dart';
import 'package:wishi_app/domain/repositories/order_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishi_app/presentation/viewmodels/checkout/checkout_state.dart';

class CheckoutViewModel extends Notifier<CheckoutState> {
  StreamSubscription? _sessionSubscription;

  @override
  CheckoutState build() {
    ref.onDispose(() {
      _sessionSubscription?.cancel();
    });
    return CheckoutState();
  }

  IOrderRepository get _orderRepository => ref.read(orderRepositoryProvider);

  /// Load draft orders for checkout
  Future<void> loadDraftOrders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final orders = await _orderRepository.getDraftOrders();
      final total = orders.fold<double>(0, (sum, order) => sum + order.total);

      state = state.copyWith(
        orders: orders,
        totalAmount: total,
        isLoading: false,
      );

      // Log begin checkout
      ref.read(analyticsServiceProvider).logBeginCheckout(value: total);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load orders: ${e.toString()}',
      );
    }
  }

  /// Create checkout session and initiate payment
  Future<void> initiateCheckout() async {
    if (state.orders.isEmpty) {
      state = state.copyWith(error: 'No orders to checkout');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      status: CheckoutStatus.creatingSession,
      debugMessage: 'Creating checkout session...',
    );

    try {
      // Create checkout session in Firestore
      final sessionId = await _orderRepository.createCheckoutSession(
        state.orders,
      );

      // Watch for Stripe extension to populate payment secrets
      _sessionSubscription?.cancel();
      _sessionSubscription = _orderRepository
          .watchCheckoutSession(sessionId)
          .listen((session) {
            if (session != null) {
              String debugMsg = 'Session update received. ';
              if (session.paymentIntentClientSecret == null) {
                debugMsg += 'Missing paymentIntent. ';
              }
              if (session.ephemeralKeySecret == null) {
                debugMsg += 'Missing ephemeralKey. ';
              }
              if (session.customer == null) {
                debugMsg += 'Missing customer. ';
              }
              if (session.paymentIntentClientSecret != null &&
                  session.ephemeralKeySecret != null &&
                  session.customer != null) {
                debugMsg += 'All secrets present.';
              }
              if (session.url != null) {
                debugMsg += 'Checkout URL present.';
              }

              state = state.copyWith(
                checkoutSession: session,
                status: CheckoutStatus.waitingForPayment,
                isLoading: false,
                debugMessage: debugMsg,
              );

              // Handle Web Checkout
              if (kIsWeb && session.url != null) {
                _launchCheckoutUrl(session.url!);
                _sessionSubscription?.cancel(); // Stop listening after redirect
              }
              // Handle Mobile Payment Sheet
              else if (!kIsWeb &&
                  session.paymentIntentClientSecret != null &&
                  session.ephemeralKeySecret != null &&
                  session.customer != null) {
                _presentPaymentSheet(
                  session.paymentIntentClientSecret!,
                  session.ephemeralKeySecret!,
                  session.customer!,
                );
              }
            }
          });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create checkout session: ${e.toString()}',
        status: CheckoutStatus.initial,
      );
    }
  }

  /// Present Stripe payment sheet
  Future<void> _presentPaymentSheet(
    String paymentIntentClientSecret,
    String ephemeralKeySecret,
    String customerId,
  ) async {
    try {
      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: 'Wishi Restaurant',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKeySecret,
          style: ThemeMode.system,
        ),
      );

      // Present payment sheet
      state = state.copyWith(status: CheckoutStatus.processingPayment);
      await Stripe.instance.presentPaymentSheet();

      // Payment succeeded
      await _handlePaymentSuccess();
    } catch (e) {
      // Payment failed or was cancelled
      if (e is StripeException) {
        final stripeError = e.error;
        if (stripeError.code == FailureCode.Canceled) {
          // User cancelled
          state = state.copyWith(
            status: CheckoutStatus.waitingForPayment,
            error: null,
          );
        } else {
          // Payment failed
          state = state.copyWith(
            status: CheckoutStatus.paymentFailed,
            error: stripeError.message ?? 'Payment failed',
          );
        }
      } else {
        state = state.copyWith(
          status: CheckoutStatus.paymentFailed,
          error: 'Payment failed: ${e.toString()}',
        );
      }
    }
  }

  /// Launch Stripe Checkout URL (Web)
  Future<void> _launchCheckoutUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, webOnlyWindowName: '_self');
        // Note: The user will be redirected back to the success_url/cancel_url
        // We might want to handle the return state in init() or a separate route
      } else {
        state = state.copyWith(
          status: CheckoutStatus.paymentFailed,
          error: 'Could not launch payment page',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.paymentFailed,
        error: 'Failed to launch payment page: ${e.toString()}',
      );
    }
  }

  /// Handle successful payment
  Future<void> _handlePaymentSuccess() async {
    state = state.copyWith(status: CheckoutStatus.paymentSucceeded);

    try {
      // Complete orders in Firestore
      final orderIds = state.orders.map((o) => o.id).toList();
      await _orderRepository.completeOrders(
        orderIds,
        state.checkoutSession?.paymentIntentClientSecret ?? '',
      );

      // Log purchase
      final total = state.orders.fold<double>(
        0,
        (sum, order) => sum + order.total,
      );
      final orderIdsStr = orderIds.join(',');

      ref
          .read(analyticsServiceProvider)
          .logPurchase(
            orderId:
                orderIdsStr, // Ideally this would be a single transaction ID from Stripe or our backend
            value: total,
          );

      state = state.copyWith(status: CheckoutStatus.orderCompleted);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to complete orders: ${e.toString()}',
      );
    }
  }

  /// Retry payment after failure
  Future<void> retryPayment() async {
    if (state.checkoutSession?.paymentIntentClientSecret != null &&
        state.checkoutSession?.ephemeralKeySecret != null &&
        state.checkoutSession?.customer != null) {
      await _presentPaymentSheet(
        state.checkoutSession!.paymentIntentClientSecret!,
        state.checkoutSession!.ephemeralKeySecret!,
        state.checkoutSession!.customer!,
      );
    } else {
      // Need to create a new session
      await initiateCheckout();
    }
  }

  /// Clear error message
  void clearError() {
    state = state.clearError();
  }

  /// Reset checkout state
  void reset() {
    _sessionSubscription?.cancel();
    state = CheckoutState();
  }
}

// This will be added to providers.dart
// final checkoutViewModelProvider =
//     NotifierProvider<CheckoutViewModel, CheckoutState>(
//       CheckoutViewModel.new,
//     );
