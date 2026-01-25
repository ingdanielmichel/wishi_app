import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/presentation/viewmodels/current_order/current_order_state.dart';

class CurrentOrderViewModel extends Notifier<CurrentOrderState> {
  @override
  CurrentOrderState build() {
    return CurrentOrderState();
  }

  void addItem(OrderItem item) {
    state = state.copyWith(items: [...state.items, item]);
    _calculateTotal();
  }

  void updateItem(OrderItem item) {
    final updatedItems = state.items.map((i) {
      if (i.id == item.id) {
        return item;
      }
      return i;
    }).toList();
    state = state.copyWith(items: updatedItems);
    _calculateTotal();
  }

  void updateItemQuantity(OrderItem item, int newQuantity) {
    final updatedItems = state.items.map((i) {
      if (i.id == item.id) {
        return i.copyWith(quantity: newQuantity);
      }
      return i;
    }).toList();
    state = state.copyWith(items: updatedItems);
    _calculateTotal();
  }

  void removeItem(OrderItem item) {
    final updatedItems = state.items.where((i) => i.id != item.id).toList();
    state = state.copyWith(items: updatedItems);
    _calculateTotal();
  }

  void _calculateTotal() {
    final newTotal = state.items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    state = state.copyWith(total: newTotal);
  }

  void clearOrder() {
    state = CurrentOrderState();
  }

  void loadOrder(List<OrderItem> items) {
    state = state.copyWith(items: items);
    _calculateTotal();
  }
}
