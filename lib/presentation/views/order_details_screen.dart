import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/presentation/views/order_item_selection_screen.dart';
import 'package:wishi_app/application/providers.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _orderName;
  late List<OrderItem> _items;
  late double _total;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _orderName = widget.order.name;
    _items = List.from(widget.order.items); // Make a mutable copy
    _total = widget.order.total;
    _nameController = TextEditingController(text: _orderName);
  }

  void _calculateTotal() {
    setState(() {
      _total = _items.fold(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final userId = firebaseAuth.currentUser?.uid ?? '';
    final menuCategories = ref.watch(menuFutureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Order Name',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _orderName = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an order name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              menuCategories.when(
                data: (categories) => ElevatedButton(
                  onPressed: () async {
                    final newOrderItem = await Navigator.push<OrderItem>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderItemSelectionScreen(
                          order: widget.order,
                          categories: categories,
                        ),
                      ),
                    );
                    if (newOrderItem != null) {
                      setState(() {
                        _items.add(newOrderItem);
                        _calculateTotal();
                      });
                    }
                  },
                  child: const Text('Add Item'),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err'),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final categories = await ref.read(
                              menuFutureProvider.future,
                            );
                            if (!context.mounted) return;

                            final updatedItem = await Navigator.push<OrderItem>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderItemSelectionScreen(
                                  order: widget.order,
                                  categories: categories,
                                  initialOrderItem: item,
                                ),
                              ),
                            );
                            if (updatedItem != null) {
                              setState(() {
                                _items[index] = updatedItem;
                                _calculateTotal();
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _items.removeAt(index);
                              _calculateTotal();
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Total: \$${_total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final updatedOrder = Order(
                      id: widget.order.id,
                      userId: userId,
                      name: _orderName,
                      items: _items,
                      total: _total,
                    );
                    ref
                        .read(orderBuilderViewModelProvider.notifier)
                        .updateOrder(updatedOrder);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
