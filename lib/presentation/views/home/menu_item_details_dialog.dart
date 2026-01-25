import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/presentation/views/order_builder/order_builder_screen.dart';

class MenuItemDetailsDialog extends ConsumerStatefulWidget {
  const MenuItemDetailsDialog({
    super.key,
    required this.item,
    required this.categoryName,
  });

  final MenuItem item;
  final String categoryName;

  @override
  ConsumerState<MenuItemDetailsDialog> createState() =>
      _MenuItemDetailsDialogState();
}

class _MenuItemDetailsDialogState extends ConsumerState<MenuItemDetailsDialog> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    // Select item to trigger analytics logging and setup state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(itemSelectionViewModelProvider.notifier)
          .selectMenuItem(widget.item);
    });
  }

  void _addToNewOrder() {
    final orderItem = OrderItem(
      id: const Uuid().v4(),
      menuItemId: widget.item.id,
      name: widget.item.name,
      category: widget.categoryName,
      quantity: quantity,
      price: widget.item.price,
      selectedOptions: {}, // TODO: Handle options if displayed
    );

    // Clear shared state for new order
    ref.read(selectedOrderProvider.notifier).selectOrder(null);

    // Setup current order view model
    ref.read(currentOrderViewModelProvider.notifier).clearOrder();
    ref.read(currentOrderViewModelProvider.notifier).addItem(orderItem);

    // Setup UI controls
    ref
        .read(orderBuilderControlsViewModelProvider.notifier)
        .setIsCreatingNewOrder(true);

    // Capture context before async gaps or closing dialog if needed
    // However, here we are synchronous so we can use context directly after pop if we pop first.
    // Or just push replacement. Since we are in a dialog, we probably want to pop the dialog and then push the screen.

    Navigator.of(context).pop(); // Close dialog

    // Navigate to Order Builder Screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const OrderBuilderScreen()));
  }

  Future<void> _addToExistingOrder() async {
    try {
      // Refresh the orders provider to get the latest data from Firestore
      ref.invalidate(draftOrdersProvider);
      final ordersAsync = ref.read(draftOrdersProvider);

      // Wait for the orders to load
      final firestoreOrders = ordersAsync.when(
        data: (orders) => orders,
        loading: () => <Order>[],
        error: (_, __) => <Order>[],
      );

      // Check if there's a current unsaved order
      final selectedOrder = ref.read(selectedOrderProvider);
      final currentOrderState = ref.read(currentOrderViewModelProvider);
      final isCreatingOrder = ref
          .read(orderBuilderControlsViewModelProvider)
          .isCreatingNewOrder;

      // Combine Firestore orders with the current unsaved order if it exists
      final List<Order> allOrders = [...firestoreOrders];

      // Add current order if it's being created and has items but isn't saved yet
      if (isCreatingOrder &&
          currentOrderState.items.isNotEmpty &&
          selectedOrder != null &&
          !firestoreOrders.any((o) => o.id == selectedOrder.id)) {
        allOrders.add(selectedOrder);
      }

      if (!mounted) return;

      if (allOrders.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('No Active Orders'),
              content: const Text(
                'You don\'t have any active orders yet. Create a new order first.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Order'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allOrders.length,
                itemBuilder: (context, index) {
                  final order = allOrders[index];
                  return ListTile(
                    title: Text(order.name),
                    subtitle: Text(
                      'Total: \$${order.total.toStringAsFixed(2)}',
                    ),
                    onTap: () async {
                      await _addItemToOrder(order);
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
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching orders: $e')));
      }
    }
  }

  Future<void> _addItemToOrder(Order order) async {
    final orderItem = OrderItem(
      id: const Uuid().v4(),
      menuItemId: widget.item.id,
      name: widget.item.name,
      category: widget.categoryName,
      quantity: quantity,
      price: widget.item.price,
      selectedOptions: {},
    );

    final updatedItems = [...order.items, orderItem];
    final updatedTotal = updatedItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    final updatedOrder = order.copyWith(
      items: updatedItems,
      total: updatedTotal,
    );

    await ref.read(orderRepositoryProvider).updateOrder(updatedOrder);

    if (mounted) {
      // Set shared state to the updated order
      ref.read(selectedOrderProvider.notifier).selectOrder(updatedOrder);

      // Load items into current order view model (needed for OrderBuilderScreen logic)
      ref.read(currentOrderViewModelProvider.notifier).loadOrder(updatedItems);

      // Setup UI controls - set to true to display the order form
      ref
          .read(orderBuilderControlsViewModelProvider.notifier)
          .setIsCreatingNewOrder(true);

      Navigator.of(context).pop(); // Close selection dialog

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Item Added!',
                  style: Theme.of(
                    dialogContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Successfully added to ${order.name}',
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close success dialog
                  Navigator.of(context).pop(); // Close details dialog
                },
                child: const Text('Keep Shopping'),
              ),
              FilledButton(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  Navigator.of(dialogContext).pop(); // Close success dialog
                  nav.pop(); // Close details dialog

                  // Navigate to Order Builder Screen
                  nav.push(
                    MaterialPageRoute(
                      builder: (context) => const OrderBuilderScreen(),
                    ),
                  );
                },
                child: const Text('View Order'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.item.imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: widget.item.imageUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${widget.item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.item.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                },
                              ),
                              Text(
                                quantity.toString(),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _addToNewOrder,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Add to New Order'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _addToExistingOrder,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Add to Existing Order'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Close button positioned at top-right
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                padding: const EdgeInsets.all(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
