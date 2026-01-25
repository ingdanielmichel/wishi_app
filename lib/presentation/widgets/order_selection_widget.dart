import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/domain/models/order.dart';

class OrderSelectionWidget extends ConsumerWidget {
  final Function(Order?) onOrderSelected;
  final Function(String) onOrderDeleted;
  final Order? selectedOrder;

  const OrderSelectionWidget({
    super.key,
    required this.onOrderSelected,
    required this.onOrderDeleted,
    this.selectedOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(draftOrdersProvider);

    return ordersAsync.when(
      data: (orders) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved Orders:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              // "New Order" Card
              GestureDetector(
                onTap: () => onOrderSelected(null),
                child: Card(
                  color: selectedOrder == null
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline, size: 32),
                        SizedBox(height: 8),
                        Text('New Order', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
              // Saved Orders Cards
              ...orders.map((order) {
                final isSelected = selectedOrder?.id == order.id;
                return GestureDetector(
                  onTap: () => onOrderSelected(order),
                  child: Card(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${order.items.length} items',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => onOrderDeleted(order.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading orders: $err')),
    );
  }
}
