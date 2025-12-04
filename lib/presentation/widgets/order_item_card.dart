import 'package:flutter/material.dart';
import 'package:wishi_app/domain/models/order_item.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onDelete;
  final ValueChanged<int> onQuantityChanged;

  const OrderItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
              ],
            ),
            const SizedBox(height: 8.0),
            if (item.selectedOptions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  item.selectedOptions.values.join(', '),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: item.quantity > 1
                          ? () => onQuantityChanged(item.quantity - 1)
                          : null,
                    ),
                    Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => onQuantityChanged(item.quantity + 1),
                    ),
                  ],
                ),
                Text(
                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
