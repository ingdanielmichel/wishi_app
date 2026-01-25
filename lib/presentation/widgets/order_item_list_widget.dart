import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/presentation/widgets/order_item_card.dart';

class OrderItemListWidget extends ConsumerWidget {
  final List<OrderItem> items;
  final Function(OrderItem, int) onQuantityChanged;
  final Function(OrderItem) onDelete;
  final Function(OrderItem)? onTap;

  const OrderItemListWidget({
    super.key,
    required this.items,
    required this.onQuantityChanged,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onTap?.call(item),
          child: OrderItemCard(
            item: item,
            onQuantityChanged: (newQuantity) =>
                onQuantityChanged(item, newQuantity),
            onDelete: () => onDelete(item),
          ),
        );
      },
    );
  }
}
