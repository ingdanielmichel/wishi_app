class OrderBuilderControlsState {
  final bool isAddingItem;
  final bool isCreatingNewOrder;
  final String? editingItemId;

  OrderBuilderControlsState({
    this.isAddingItem = false,
    this.isCreatingNewOrder = false,
    this.editingItemId,
  });

  OrderBuilderControlsState copyWith({
    bool? isAddingItem,
    bool? isCreatingNewOrder,
    String? editingItemId,
  }) {
    return OrderBuilderControlsState(
      isAddingItem: isAddingItem ?? this.isAddingItem,
      isCreatingNewOrder: isCreatingNewOrder ?? this.isCreatingNewOrder,
      editingItemId: editingItemId ?? this.editingItemId,
    );
  }
}
