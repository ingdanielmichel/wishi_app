import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/services/analytics_service.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/order_item.dart'
    as wishi_app_order_item;

class ItemSelectionState {
  final Category? selectedCategory;
  final MenuItem? selectedMenuItem;
  final Map<String, dynamic> selectedOptions;
  final int quantity;

  ItemSelectionState({
    this.selectedCategory,
    this.selectedMenuItem,
    this.selectedOptions = const {},
    this.quantity = 1,
  });

  ItemSelectionState copyWith({
    Category? selectedCategory,
    MenuItem? selectedMenuItem,
    Map<String, dynamic>? selectedOptions,
    int? quantity,
  }) {
    return ItemSelectionState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedMenuItem: selectedMenuItem ?? this.selectedMenuItem,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      quantity: quantity ?? this.quantity,
    );
  }
}

final itemSelectionViewModelProvider =
    NotifierProvider<ItemSelectionViewModel, ItemSelectionState>(() {
      return ItemSelectionViewModel();
    });

class ItemSelectionViewModel extends Notifier<ItemSelectionState> {
  @override
  ItemSelectionState build() {
    return ItemSelectionState();
  }

  void selectCategory(Category? category) {
    state = state.copyWith(
      selectedCategory: category,
      selectedMenuItem: null,
      selectedOptions: {},
    );
  }

  void selectMenuItem(MenuItem? menuItem) {
    state = state.copyWith(selectedMenuItem: menuItem, selectedOptions: {});

    if (menuItem != null) {
      ref
          .read(analyticsServiceProvider)
          .logViewItem(
            itemId: menuItem.id,
            itemName: menuItem.name,
            category: state.selectedCategory?.name ?? 'Unknown',
            price: menuItem.price,
          );
    }
  }

  void toggleOption(String optionName, bool isSelected) {
    final newSelectedOptions = Map<String, dynamic>.from(state.selectedOptions);
    newSelectedOptions[optionName] = isSelected;
    state = state.copyWith(selectedOptions: newSelectedOptions);
  }

  void setQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
  }

  void reset() {
    state = ItemSelectionState();
  }

  void selectSingleOption(String groupId, String? optionName) {
    final newSelectedOptions = Map<String, dynamic>.from(state.selectedOptions);
    if (optionName != null) {
      newSelectedOptions[groupId] = optionName;
    } else {
      newSelectedOptions.remove(groupId);
    }
    state = state.copyWith(selectedOptions: newSelectedOptions);
  }

  void setOrderItem(
    wishi_app_order_item.OrderItem item,
    List<Category> categories,
  ) {
    // Find category and menu item
    Category? matchingCategory;
    MenuItem? matchingMenuItem;

    for (final category in categories) {
      for (final menuItem in category.items) {
        if (menuItem.id == item.menuItemId) {
          matchingCategory = category;
          matchingMenuItem = menuItem;
          break;
        }
      }
      if (matchingMenuItem != null) break;
    }

    if (matchingMenuItem != null) {
      state = state.copyWith(
        selectedCategory: matchingCategory,
        selectedMenuItem: matchingMenuItem,
        selectedOptions: Map<String, dynamic>.from(item.selectedOptions),
        quantity: item.quantity,
      );
    }
  }
}
