import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/option_group.dart';
import 'package:wishi_app/presentation/widgets/order_item_card.dart';
import 'package:wishi_app/application/providers.dart';

class OrderBuilderScreen extends ConsumerStatefulWidget {
  final Order? order;
  const OrderBuilderScreen({super.key, this.order});

  @override
  ConsumerState<OrderBuilderScreen> createState() => _OrderBuilderScreenState();
}

class _OrderBuilderScreenState extends ConsumerState<OrderBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _orderName;
  late List<OrderItem> _items;
  late double _total;
  bool _isAddingItem = false;
  late bool _isEditMode;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.order != null;
    if (_isEditMode) {
      _orderName = widget.order!.name;
      _items = List<OrderItem>.from(widget.order!.items);
      _total = widget.order!.total;
    } else {
      _orderName = '';
      _items = [];
      _total = 0.0;
    }
  }

  void _clearOrderForm() {
    setState(() {
      _orderName = '';
      _items = [];
      _total = 0.0;
      _isEditMode = false;
      // If a TextEditingController was used for the name, it should be cleared here.
      // e.g., _nameController.clear();
    });
  }

  void _calculateTotal() {
    _total = _items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  void _resetAddItemForm() {
    ref.read(itemSelectionViewModelProvider.notifier).reset();
    setState(() {
      _isAddingItem = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final userId = firebaseAuth.currentUser?.uid ?? '';
    final menuCategories = ref.watch(menuFutureProvider);
    final itemSelectionState = ref.watch(itemSelectionViewModelProvider);
    final itemSelectionNotifier = ref.read(
      itemSelectionViewModelProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Order' : 'Create New Order'),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  initialValue: _orderName,
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
              if (!_isAddingItem)
                menuCategories.when(
                  data: (categories) => ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAddingItem = true;
                      });
                    },
                    child: const Text('Add Item'),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (err, stack) => Text('Error: $err'),
                ),
              if (_isAddingItem)
                menuCategories.when(
                  data: (categories) => Column(
                    children: [
                      DropdownButton<Category>(
                        hint: const Text('Select Category'),
                        value: itemSelectionState.selectedCategory,
                        onChanged: (Category? newValue) {
                          itemSelectionNotifier.selectCategory(newValue);
                        },
                        items: categories.map<DropdownMenuItem<Category>>((
                          Category category,
                        ) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ),
                      if (itemSelectionState.selectedCategory != null)
                        DropdownButton<MenuItem>(
                          hint: const Text('Select Item'),
                          value: itemSelectionState.selectedMenuItem,
                          onChanged: (MenuItem? newValue) {
                            itemSelectionNotifier.selectMenuItem(newValue);
                          },
                          items: (itemSelectionState.selectedCategory!.items)
                              .map<DropdownMenuItem<MenuItem>>((MenuItem item) {
                                return DropdownMenuItem<MenuItem>(
                                  value: item,
                                  child: Text(item.name),
                                );
                              })
                              .toList(),
                        ),
                      if (itemSelectionState.selectedMenuItem != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (itemSelectionState.quantity > 1) {
                                  itemSelectionNotifier.setQuantity(
                                    itemSelectionState.quantity - 1,
                                  );
                                }
                              },
                            ),
                            Text(
                              '${itemSelectionState.quantity}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                itemSelectionNotifier.setQuantity(
                                  itemSelectionState.quantity + 1,
                                );
                              },
                            ),
                          ],
                        ),
                      if (itemSelectionState.selectedMenuItem != null)
                        _buildOptionsSelector(
                          itemSelectionState.selectedMenuItem!.optionGroups,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _resetAddItemForm,
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed:
                                (itemSelectionState.selectedMenuItem == null)
                                ? null
                                : () {
                                    double optionsPrice = 0.0;
                                    final selectedMenuItem =
                                        itemSelectionState.selectedMenuItem!;
                                    itemSelectionState.selectedOptions.forEach((
                                      key,
                                      value,
                                    ) {
                                      if (value is bool && value == true) {
                                        // This is a checkbox option, 'key' is the option name
                                        final option = selectedMenuItem
                                            .optionGroups
                                            .expand((group) => group.options)
                                            .firstWhere(
                                              (o) => o.name == key,
                                              orElse: () => throw Exception(
                                                'Checkbox option not found: $key',
                                              ),
                                            );
                                        optionsPrice += option.priceModifier;
                                      } else if (value is String) {
                                        // This is a radio button option, 'key' is the group ID, 'value' is the selected option name
                                        final optionGroup = selectedMenuItem
                                            .optionGroups
                                            .firstWhere(
                                              (group) => group.id == key,
                                              orElse: () => throw Exception(
                                                'Option group not found: $key',
                                              ),
                                            );
                                        final option = optionGroup.options
                                            .firstWhere(
                                              (o) => o.name == value,
                                              orElse: () => throw Exception(
                                                'Radio option not found: $value in group $key',
                                              ),
                                            );
                                        optionsPrice += option.priceModifier;
                                      }
                                    });

                                    final newOrderItem = OrderItem(
                                      id: const Uuid().v4(),
                                      menuItemId: selectedMenuItem.id,
                                      name: selectedMenuItem.name,
                                      quantity: itemSelectionState.quantity,
                                      price:
                                          selectedMenuItem.price + optionsPrice,
                                      selectedOptions:
                                          itemSelectionState.selectedOptions,
                                    );
                                    setState(() {
                                      _items.add(newOrderItem);
                                      _calculateTotal();
                                    });
                                    _resetAddItemForm();
                                  },
                            child: const Text('Confirm Add Item'),
                          ),
                        ],
                      ),
                    ],
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
                  return OrderItemCard(
                    item: item,
                    onQuantityChanged: (newQuantity) {
                      setState(() {
                        _items[index] = item.copyWith(quantity: newQuantity);
                        _calculateTotal();
                      });
                    },
                    onDelete: () {
                      setState(() {
                        _items.removeAt(index);
                        _calculateTotal();
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Total: ${_total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      if (_isEditMode) {
                        final updatedOrder = widget.order!.copyWith(
                          name: _orderName,
                          items: _items,
                          total: _total,
                        );
                        ref
                            .read(orderBuilderViewModelProvider.notifier)
                            .updateOrder(updatedOrder);
                      } else {
                        final newOrder = Order(
                          id: const Uuid().v4(),
                          userId: userId,
                          name: _orderName,
                          items: _items,
                          total: _total,
                        );
                        ref
                            .read(orderBuilderViewModelProvider.notifier)
                            .createOrder(newOrder);
                      }
                      _resetAddItemForm();
                      if (!_isEditMode) {
                        _clearOrderForm();
                      }
                      ref.read(mainScreenIndexProvider.notifier).setIndex(2); // Navigate to Profile
                    }
                  },
                  child: const Text('Save Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSelector(List<OptionGroup> optionGroups) {
    final itemSelectionState = ref.watch(itemSelectionViewModelProvider);
    final itemSelectionNotifier = ref.read(
      itemSelectionViewModelProvider.notifier,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: optionGroups.expand((group) {
        List<Widget> groupWidgets = [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              group.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ];

        if (group.selectionType == 'single') {
          groupWidgets.addAll(
            group.options.map((option) {
              return RadioListTile<String>(
                title: Text(
                  '${option.name} (+\$${option.priceModifier.toStringAsFixed(2)})',
                ),
                value: option.name,
                groupValue: itemSelectionState.selectedOptions[group.id],
                onChanged: (String? value) {
                  itemSelectionNotifier.selectSingleOption(group.id, value);
                },
              );
            }),
          );
        } else {
          // Default to multiple selection (checkboxes)
          groupWidgets.addAll(
            group.options.map((option) {
              return CheckboxListTile(
                title: Text(
                  '${option.name} (+\$${option.priceModifier.toStringAsFixed(2)})',
                ),
                value: itemSelectionState.selectedOptions[option.name] ?? false,
                onChanged: (bool? value) {
                  itemSelectionNotifier.toggleOption(
                    option.name,
                    value ?? false,
                  );
                },
              );
            }),
          );
        }
        return groupWidgets;
      }).toList(),
    );
  }
}
