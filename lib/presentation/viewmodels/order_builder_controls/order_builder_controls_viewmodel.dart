import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/presentation/viewmodels/order_builder_controls/order_builder_controls_state.dart';

class OrderBuilderControlsViewModel
    extends Notifier<OrderBuilderControlsState> {
  @override
  OrderBuilderControlsState build() {
    return OrderBuilderControlsState();
  }

  void setIsAddingItem(bool value) {
    state = state.copyWith(isAddingItem: value);
  }

  void setIsCreatingNewOrder(bool value) {
    state = state.copyWith(isCreatingNewOrder: value);
  }

  void setEditingItem(String? itemId) {
    state = state.copyWith(editingItemId: itemId);
  }
}
