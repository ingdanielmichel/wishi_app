import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';

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
    state = state.copyWith(
      selectedMenuItem: menuItem,
      selectedOptions: {},
    );
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
}

final itemSelectionViewModelProvider =
    NotifierProvider<ItemSelectionViewModel, ItemSelectionState>(
  ItemSelectionViewModel.new,
);
