import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/menu_item_option.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/presentation/views/order_item_selection_screen.dart';
import 'package:wishi_app/presentation/viewmodels/home_viewmodel.dart';
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

  Category? _selectedCategory;
  MenuItem? _selectedMenuItem;
  MenuItemOption? _selectedOption;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _orderName = widget.order.name;
    _items = widget.order.items;
    _total = widget.order.total;
    _nameController = TextEditingController(text: _orderName);
  }

  void _calculateTotal() {
    setState(() {
      _total = _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final userId = firebaseAuth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order'),
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
            ref.watch(menuFutureProvider).when(
                  data: (categories) => Column(
                    children: [
                      DropdownButton<Category>(
                        hint: const Text('Select Category'),
                        value: _selectedCategory,
                        onChanged: (Category? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                            _selectedMenuItem = null;
                            _selectedOption = null;
                          });
                        },
                        items: categories.map<DropdownMenuItem<Category>>((Category category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ),
                      if (_selectedCategory != null)
                        DropdownButton<MenuItem>(
                          hint: const Text('Select Item'),
                          value: _selectedMenuItem,
                          onChanged: (MenuItem? newValue) {
                            setState(() {
                              _selectedMenuItem = newValue;
                              _selectedOption = null;
                            });
                          },
                          items: _selectedCategory!.items.map<DropdownMenuItem<MenuItem>>((MenuItem item) {
                            return DropdownMenuItem<MenuItem>(
                              value: item,
                              child: Text(item.name),
                            );
                          }).toList(),
                        ),
                      if (_selectedMenuItem != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                            ),
                            Text('$_quantity', style: Theme.of(context).textTheme.titleLarge),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      if (_selectedMenuItem != null)
                        _buildOptionsSelector(_selectedMenuItem!.options),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_selectedMenuItem == null || _selectedOption == null)
                  ? null
                  : () {
                      final newOrderItem = OrderItem(
                        id: const Uuid().v4(),
                        menuItemId: _selectedMenuItem!.id,
                        name: _selectedMenuItem!.name,
                        quantity: _quantity,
                        price: _selectedMenuItem!.price + _selectedOption!.priceModifier,
                        selectedOption: _selectedOption,
                      );
                      setState(() {
                        _items.add(newOrderItem);
                        _calculateTotal();
                        // Reset selection
                        _selectedCategory = null;
                        _selectedMenuItem = null;
                        _selectedOption = null;
                        _quantity = 1;
                      });
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
                  ref.read(orderBuilderViewModelProvider.notifier).updateOrder(updatedOrder);
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

  Widget _buildOptionsSelector(List<MenuItemOption> options) {
    return Column(
      children: options.map((option) {
        return RadioListTile<MenuItemOption>(
          title: Text(option.name),
          value: option,
          groupValue: _selectedOption,
          onChanged: (MenuItemOption? value) {
            setState(() {
              _selectedOption = value;
            });
          },
        );
      }).toList(),
    );
  }
}
