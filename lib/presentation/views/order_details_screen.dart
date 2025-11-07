import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/presentation/views/order_item_selection_screen.dart';
import 'package:wishi_app/presentation/viewmodels/home_viewmodel.dart';
import 'package:wishi_app/application/providers.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final Order? order;

  const OrderDetailsScreen({super.key, this.order});

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
    _orderName = widget.order?.name ?? '';
    _items = widget.order?.items ?? [];
    _total = widget.order?.total ?? 0.0;
    _nameController = TextEditingController(text: _orderName);
  }

  void _calculateTotal() {
    setState(() {
      _total = _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Create Order' : 'Edit Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            ElevatedButton(
              onPressed: () async {
                final categories = await ref.read(menuFutureProvider.future);
                if (!context.mounted) return;
                final newItem = await Navigator.push<OrderItem>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderItemSelectionScreen(
                      order: Order(id: '', name: '', items: [], total: 0.0), // Dummy order
                      categories: categories,
                    ),
                  ),
                );
                if (newItem != null) {
                  setState(() {
                    _items.add(newItem);
                    _calculateTotal();
                  });
                }
              },
              child: const Text('Add Item'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final categories = await ref.read(menuFutureProvider.future);
                            if (!context.mounted) return;
                            final updatedItem = await Navigator.push<OrderItem>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderItemSelectionScreen(
                                  order: widget.order ?? Order(id: '', name: _orderName, items: [], total: 0.0),
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
                  final newOrder = Order(
                    id: widget.order?.id ?? const Uuid().v4(),
                    name: _orderName,
                    items: _items,
                    total: _total,
                  );
                  if (widget.order == null) {
                    ref.read(orderBuilderViewModelProvider.notifier).createOrder(newOrder);
                  } else {
                    ref.read(orderBuilderViewModelProvider.notifier).updateOrder(newOrder);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Order'),
            ),
          ],
        ),
      ),
    );
  }
}
