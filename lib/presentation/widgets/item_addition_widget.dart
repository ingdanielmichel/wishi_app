import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/option_group.dart';
import 'package:wishi_app/domain/models/order_item.dart';

class ItemAdditionWidget extends ConsumerWidget {
  final Function(OrderItem) onAddItem;
  final VoidCallback onCancel;

  const ItemAdditionWidget({
    super.key,
    required this.onAddItem,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuCategories = ref.watch(menuFutureProvider);
    final itemSelectionState = ref.watch(itemSelectionViewModelProvider);
    final itemSelectionNotifier = ref.read(
      itemSelectionViewModelProvider.notifier,
    );

    return menuCategories.when(
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
              context,
              ref,
              itemSelectionState.selectedMenuItem!.optionGroups,
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onCancel, child: const Text('Cancel')),
              ElevatedButton(
                onPressed: (itemSelectionState.selectedMenuItem == null)
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
                            final option = selectedMenuItem.optionGroups
                                .expand((group) => group.options)
                                .firstWhere((o) => o.name == key);
                            optionsPrice += option.priceModifier;
                          } else if (value is String) {
                            final optionGroup = selectedMenuItem.optionGroups
                                .firstWhere((group) => group.id == key);
                            final option = optionGroup.options.firstWhere(
                              (o) => o.name == value,
                            );
                            optionsPrice += option.priceModifier;
                          }
                        });

                        final isEditing =
                            ref
                                .read(orderBuilderControlsViewModelProvider)
                                .editingItemId !=
                            null;
                        final editingId = ref
                            .read(orderBuilderControlsViewModelProvider)
                            .editingItemId;

                        final newOrderItem = OrderItem(
                          id: isEditing && editingId != null
                              ? editingId
                              : const Uuid().v4(),
                          menuItemId: selectedMenuItem.id,
                          name: selectedMenuItem.name,
                          category:
                              itemSelectionState.selectedCategory?.name ??
                              'General',
                          quantity: itemSelectionState.quantity,
                          price: selectedMenuItem.price + optionsPrice,
                          selectedOptions: itemSelectionState.selectedOptions,
                        );
                        onAddItem(newOrderItem);
                      },
                child: Text(
                  ref
                              .watch(orderBuilderControlsViewModelProvider)
                              .editingItemId !=
                          null
                      ? 'Update Item'
                      : 'Confirm Add Item',
                ),
              ),
            ],
          ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }

  Widget _buildOptionsSelector(
    BuildContext context,
    WidgetRef ref,
    List<OptionGroup> optionGroups,
  ) {
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
