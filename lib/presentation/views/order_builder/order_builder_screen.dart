import 'package:wishi_app/presentation/widgets/user_avatar_button.dart';
import 'package:wishi_app/presentation/widgets/order_item_list_widget.dart';
import 'package:wishi_app/presentation/widgets/item_addition_widget.dart';
import 'package:wishi_app/presentation/widgets/order_selection_widget.dart';
import 'package:wishi_app/presentation/views/checkout/order_validation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_status.dart';

import 'package:wishi_app/application/providers.dart';

class OrderBuilderScreen extends ConsumerStatefulWidget {
  const OrderBuilderScreen({super.key});

  @override
  ConsumerState<OrderBuilderScreen> createState() => _OrderBuilderScreenState();
}

class _OrderBuilderScreenState extends ConsumerState<OrderBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize if provider already has data (e.g. from Dialog)
    final selectedOrder = ref.read(selectedOrderProvider);
    if (selectedOrder != null) {
      _orderNameController.text = selectedOrder.name;
    }
  }

  @override
  void dispose() {
    _orderNameController.dispose();
    super.dispose();
  }

  void _clearOrderForm() {
    _orderNameController.clear();
    ref.read(currentOrderViewModelProvider.notifier).clearOrder();
    ref
        .read(selectedOrderProvider.notifier)
        .selectOrder(null); // Clear shared state
    ref
        .read(orderBuilderControlsViewModelProvider.notifier)
        .setIsCreatingNewOrder(false);
    ref
        .read(orderBuilderControlsViewModelProvider.notifier)
        .setEditingItem(null);
  }

  void _resetAddItemForm() {
    ref.read(itemSelectionViewModelProvider.notifier).reset();
    ref
        .read(orderBuilderControlsViewModelProvider.notifier)
        .setIsAddingItem(false);
    ref
        .read(orderBuilderControlsViewModelProvider.notifier)
        .setEditingItem(null);
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final userId = firebaseAuth.currentUser?.uid ?? '';
    final orderBuilderState = ref.watch(orderBuilderViewModelProvider);
    final currentOrderState = ref.watch(currentOrderViewModelProvider);
    final orderBuilderControlsState = ref.watch(
      orderBuilderControlsViewModelProvider,
    );
    final selectedOrder = ref.watch(selectedOrderProvider);
    final draftOrdersAsync = ref.watch(draftOrdersProvider);

    // Listen to changes elsewhere (optional, primarily for initial load which is handled in initState or set from outside)
    ref.listen<Order?>(selectedOrderProvider, (previous, next) {
      if (next != null && next != previous) {
        _orderNameController.text = next.name;
      } else if (next == null && previous != null) {
        _orderNameController.clear();
      }
    });

    ref.listen(orderBuilderViewModelProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Builder'),
        actions: [
          // Checkout button - only show if there are draft orders
          draftOrdersAsync.when(
            data: (orders) {
              if (orders.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrderValidationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.payment),
                label: const Text('Checkout'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const UserAvatarButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderSelectionWidget(
                selectedOrder: selectedOrder,
                onOrderSelected: (order) {
                  ref.read(selectedOrderProvider.notifier).selectOrder(order);
                  if (order != null) {
                    _orderNameController.text = order.name;
                    ref
                        .read(currentOrderViewModelProvider.notifier)
                        .loadOrder(order.items);
                    ref
                        .read(orderBuilderControlsViewModelProvider.notifier)
                        .setIsCreatingNewOrder(true);
                  } else {
                    _clearOrderForm();
                    ref
                        .read(orderBuilderControlsViewModelProvider.notifier)
                        .setIsCreatingNewOrder(true);
                  }
                },
                onOrderDeleted: (orderId) async {
                  await ref
                      .read(orderBuilderViewModelProvider.notifier)
                      .deleteOrder(orderId);
                  // Refresh orders list
                  ref.refresh(draftOrdersProvider);
                  // Clear form if deleted order was selected
                  if (selectedOrder?.id == orderId) {
                    _clearOrderForm();
                  }
                },
              ),
              const SizedBox(height: 20),
              if (orderBuilderControlsState.isCreatingNewOrder)
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _orderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Order Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an order name';
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 20),
              if (orderBuilderControlsState.isCreatingNewOrder &&
                  !orderBuilderControlsState.isAddingItem)
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(orderBuilderControlsViewModelProvider.notifier)
                        .setIsAddingItem(true);
                  },
                  child: const Text('Add Item'),
                ),
              if (orderBuilderControlsState.isAddingItem)
                ItemAdditionWidget(
                  onAddItem: (orderItem) {
                    final isEditing =
                        ref
                            .read(orderBuilderControlsViewModelProvider)
                            .editingItemId !=
                        null;
                    if (isEditing) {
                      ref
                          .read(currentOrderViewModelProvider.notifier)
                          .updateItem(orderItem);
                    } else {
                      ref
                          .read(currentOrderViewModelProvider.notifier)
                          .addItem(orderItem);
                    }
                    _resetAddItemForm();
                  },
                  onCancel: _resetAddItemForm,
                ),
              const SizedBox(height: 20),
              OrderItemListWidget(
                items: currentOrderState.items,
                onQuantityChanged: (item, newQuantity) {
                  ref
                      .read(currentOrderViewModelProvider.notifier)
                      .updateItemQuantity(item, newQuantity);
                },
                onDelete: (item) {
                  ref
                      .read(currentOrderViewModelProvider.notifier)
                      .removeItem(item);
                },
                onTap: (item) {
                  ref.read(menuFutureProvider).whenData((categories) {
                    ref
                        .read(itemSelectionViewModelProvider.notifier)
                        .setOrderItem(item, categories);
                    ref
                        .read(orderBuilderControlsViewModelProvider.notifier)
                        .setEditingItem(item.id);
                    ref
                        .read(orderBuilderControlsViewModelProvider.notifier)
                        .setIsAddingItem(true);
                  });
                },
              ),
              const SizedBox(height: 20),
              if (orderBuilderControlsState.isCreatingNewOrder)
                Text(
                  'Total: ${currentOrderState.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              const SizedBox(height: 20),
              if (orderBuilderControlsState.isCreatingNewOrder)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: orderBuilderState.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              if (selectedOrder != null) {
                                final updatedOrder = selectedOrder.copyWith(
                                  name: _orderNameController.text,
                                  items: currentOrderState.items,
                                  total: currentOrderState.total,
                                  updatedAt: DateTime.now(),
                                );
                                await ref
                                    .read(
                                      orderBuilderViewModelProvider.notifier,
                                    )
                                    .updateOrder(updatedOrder);
                              } else {
                                final now = DateTime.now();
                                final newOrder = Order(
                                  id: const Uuid().v4(),
                                  userId: userId,
                                  name: _orderNameController.text,
                                  items: currentOrderState.items,
                                  total: currentOrderState.total,
                                  status: OrderStatus.draft,
                                  createdAt: now,
                                  updatedAt: now,
                                );
                                await ref
                                    .read(
                                      orderBuilderViewModelProvider.notifier,
                                    )
                                    .createOrder(newOrder);
                              }
                              _resetAddItemForm();
                              _clearOrderForm();

                              ref.refresh(draftOrdersProvider);
                            }
                          },
                    child: orderBuilderState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Order'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
