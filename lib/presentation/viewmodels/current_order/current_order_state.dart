import 'package:wishi_app/domain/models/order_item.dart';

class CurrentOrderState {
  final List<OrderItem> items;
  final double total;

  CurrentOrderState({
    this.items = const [],
    this.total = 0.0,
  });

  CurrentOrderState copyWith({
    List<OrderItem>? items,
    double? total,
  }) {
    return CurrentOrderState(
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}
