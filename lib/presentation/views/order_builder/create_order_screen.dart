import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/presentation/views/order_item_selection_screen.dart';
import 'package:wishi_app/presentation/views/cart_screen.dart';
import 'package:wishi_app/presentation/viewmodels/home_viewmodel.dart';
import 'package:wishi_app/application/providers.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String _orderName = '';
  final List<OrderItem> _items = [];
  double _total = 0.0;

  void _calculateTotal() {
    _total = _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(items: _items, total: _total),
                ),
              );
            },
            child: const Text('Checkout'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final newOrder = Order(
                  id: const Uuid().v4(),
                  name: _orderName,
                  items: _items,
                  total: _total,
                );
                ref.read(orderBuilderViewModelProvider.notifier).createOrder(newOrder);
                Navigator.pop(context);
              }
            },
            child: const Text('Save Order'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
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
                    trailing: Text((item.price * item.quantity).toStringAsFixed(2)),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Total: ${_total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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
          ],
        ),
      ),
    );
  }
}
