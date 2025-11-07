import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/domain/models/menu_item_option.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/domain/models/order.dart';

class OrderItemSelectionScreen extends ConsumerStatefulWidget {
  final Order order;
  final List<Category> categories;
  final OrderItem? initialOrderItem;

  const OrderItemSelectionScreen( 
      {super.key,
      required this.order,
      required this.categories,
      this.initialOrderItem});

  @override
  ConsumerState<OrderItemSelectionScreen> createState() =>
      _OrderItemSelectionScreenState();
}

class _OrderItemSelectionScreenState
    extends ConsumerState<OrderItemSelectionScreen> {
  Category? selectedCategory;
  MenuItem? selectedMenuItem;
  MenuItemOption? selectedOption;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialOrderItem != null) {
      for (var category in widget.categories) {
        for (var item in category.items) {
          if (item.id == widget.initialOrderItem!.menuItemId) {
            selectedCategory = category;
            selectedMenuItem = item;
            break;
          }
        }
        if (selectedMenuItem != null) break;
      }
      selectedOption = widget.initialOrderItem!.selectedOption;
      _quantity = widget.initialOrderItem!.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialOrderItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Item' : 'Add to ${widget.order.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            
            DropdownButton<Category>(
              hint: const Text('Select Category'),
              value: selectedCategory,
              onChanged: (Category? newValue) {
                setState(() {
                  selectedCategory = newValue;
                  selectedMenuItem = null;
                  selectedOption = null;
                });
              },
              items: widget.categories
                  .map<DropdownMenuItem<Category>>((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
            ),
            if (selectedCategory != null)
              DropdownButton<MenuItem>(
                hint: const Text('Select Item'),
                value: selectedMenuItem,
                onChanged: (MenuItem? newValue) {
                  setState(() {
                    selectedMenuItem = newValue;
                    selectedOption = null;
                  });
                },
                items: selectedCategory!.items
                    .map<DropdownMenuItem<MenuItem>>((MenuItem item) {
                  return DropdownMenuItem<MenuItem>(
                    value: item,
                    child: Text(item.name),
                  );
                }).toList(),
              ),
            if (selectedMenuItem != null)
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
            if (selectedMenuItem != null)
              Expanded(
                child: _buildOptionsSelector(selectedMenuItem!.options),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: (selectedMenuItem == null || selectedOption == null)
                  ? null
                  : () {
                      final newOrderItem = OrderItem(
                        id: widget.initialOrderItem?.id ?? const Uuid().v4(),
                        menuItemId: selectedMenuItem!.id,
                        name: selectedMenuItem!.name,
                        quantity: _quantity,
                        price: selectedMenuItem!.price + selectedOption!.priceModifier,
                        selectedOption: selectedOption,
                      );
                      Navigator.pop(context, newOrderItem);
                    },
              child: Text(isEditMode ? 'Update Item' : 'Add to Order'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSelector(List<MenuItemOption> options) {
    return ListView(
      children: options.map((option) {
        return RadioListTile<MenuItemOption>(
          title: Text(option.name),
          value: option,
          groupValue: selectedOption,
          onChanged: (MenuItemOption? value) {
            setState(() {
              selectedOption = value;
            });
          },
        );
      }).toList(),
    );
  }
}
