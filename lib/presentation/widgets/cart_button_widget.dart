import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/presentation/views/order_builder/order_builder_screen.dart';

class CartButton extends ConsumerWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftOrdersAsync = ref.watch(draftOrdersProvider);

    return draftOrdersAsync.when(
      data: (orders) {
        final orderCount = orders.length;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrderBuilderScreen(),
                  ),
                );
              },
            ),
            if (orderCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    orderCount.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const OrderBuilderScreen()),
          );
        },
      ),
      error: (_, __) => IconButton(
        icon: const Icon(Icons.shopping_cart),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const OrderBuilderScreen()),
          );
        },
      ),
    );
  }
}
