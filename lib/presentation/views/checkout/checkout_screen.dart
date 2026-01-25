import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/presentation/viewmodels/checkout/checkout_state.dart';
import 'package:wishi_app/presentation/views/checkout/order_status_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // Initiate checkout when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutViewModelProvider.notifier).initiateCheckout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutViewModelProvider);

    // Listen for status changes
    ref.listen<CheckoutState>(checkoutViewModelProvider, (previous, next) {
      if (next.status == CheckoutStatus.paymentSucceeded ||
          next.status == CheckoutStatus.orderCompleted) {
        // Navigate to order status screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderStatusScreen(
              orderIds: next.orders.map((o) => o.id).toList(),
            ),
          ),
        );
      } else if (next.status == CheckoutStatus.paymentFailed &&
          next.error != null) {
        // Show error dialog
        _showErrorDialog(next.error!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusWidget(checkoutState.status),
              const SizedBox(height: 24),
              _buildStatusText(checkoutState.status),
              if (checkoutState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  checkoutState.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              if (checkoutState.debugMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  checkoutState.debugMessage!,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
              if (checkoutState.status == CheckoutStatus.paymentFailed) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(checkoutViewModelProvider.notifier).retryPayment();
                  },
                  child: const Text('Retry Payment'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget(CheckoutStatus status) {
    switch (status) {
      case CheckoutStatus.creatingSession:
      case CheckoutStatus.waitingForPayment:
      case CheckoutStatus.processingPayment:
        return const CircularProgressIndicator();
      case CheckoutStatus.paymentSucceeded:
      case CheckoutStatus.orderCompleted:
        return const Icon(Icons.check_circle, size: 64, color: Colors.green);
      case CheckoutStatus.paymentFailed:
        return const Icon(Icons.error, size: 64, color: Colors.red);
      default:
        return const CircularProgressIndicator();
    }
  }

  Widget _buildStatusText(CheckoutStatus status) {
    String text;
    switch (status) {
      case CheckoutStatus.creatingSession:
        text = 'Preparing payment...';
        break;
      case CheckoutStatus.waitingForPayment:
        text = 'Opening payment sheet...';
        break;
      case CheckoutStatus.processingPayment:
        text = 'Processing payment...';
        break;
      case CheckoutStatus.paymentSucceeded:
        text = 'Payment successful!';
        break;
      case CheckoutStatus.orderCompleted:
        text = 'Order completed!';
        break;
      case CheckoutStatus.paymentFailed:
        text = 'Payment failed';
        break;
      default:
        text = 'Initializing...';
    }

    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center,
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(checkoutViewModelProvider.notifier).retryPayment();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
