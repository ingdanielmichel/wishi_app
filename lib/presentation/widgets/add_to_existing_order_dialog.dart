import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/domain/models/order_item.dart';

class AddToExistingOrderDialog extends ConsumerWidget {
  final OrderItem newItem;

  const AddToExistingOrderDialog({super.key, required this.newItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderBuilderViewModelProvider);

    return AlertDialog(
      title: const Text('Add to Existing Order'),
      content: SizedBox(
        width: double.maxFinite,
        child: orderState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderState.orders.isEmpty
                ? const Text('You have no existing orders.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: orderState.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderState.orders[index];
                      return ListTile(
                        title: Text(order.name),
                        onTap: () {
                          final updatedItems = List<OrderItem>.from(order.items)..add(newItem.copyWith());
                          final updatedOrder = order.copyWith(
                            items: updatedItems,
                            total: order.total + (newItem.price * newItem.quantity),
                          );
                          ref.read(orderBuilderViewModelProvider.notifier).updateOrder(updatedOrder);
                          Navigator.of(context).pop(); // Close the dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${newItem.name} to ${order.name}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
