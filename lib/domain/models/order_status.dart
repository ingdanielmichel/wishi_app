enum OrderStatus {
  draft,
  pendingPayment,
  completed,
  cancelled;

  String toJson() {
    switch (this) {
      case OrderStatus.draft:
        return 'draft';
      case OrderStatus.pendingPayment:
        return 'pending_payment';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromJson(String json) {
    switch (json) {
      case 'draft':
        return OrderStatus.draft;
      case 'pending_payment':
        return OrderStatus.pendingPayment;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.draft; // Default for existing orders
    }
  }
}
