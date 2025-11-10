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

  Category? _selectedCategory;
  MenuItem? _selectedMenuItem;
  MenuItemOption? _selectedOption;
  int _quantity = 1;

  void _calculateTotal() {
    _total = _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final userId = firebaseAuth.currentUser?.uid ?? '';
    final menuCategories = ref.watch(menuFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Order'),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                final newOrder = Order(
                  id: const Uuid().v4(),
                  userId: userId,
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
        child: SingleChildScrollView(
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
              menuCategories.when(
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
                        Text((item.price * item.quantity).toStringAsFixed(2)),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final categories = await ref.read(menuFutureProvider.future);
                            if (!context.mounted) return;
                            final updatedItem = await Navigator.push<OrderItem>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderItemSelectionScreen(
                                  order: Order(id: '', userId: userId, name: _orderName, items: [], total: 0.0),
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
                'Total: ${_total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
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
