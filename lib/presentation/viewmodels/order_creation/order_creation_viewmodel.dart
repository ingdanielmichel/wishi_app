import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/usecases/save_order_usecase.dart';
import 'package:wishi_app/presentation/viewmodels/order_creation/order_creation_state.dart';
import 'package:wishi_app/application/providers.dart';

class OrderCreationViewModel extends Notifier<OrderCreationState> {
  late final SaveOrderUseCase _saveOrderUseCase;

  @override
  OrderCreationState build() {
    _saveOrderUseCase = ref.watch(saveOrderUseCaseProvider);
    return const OrderCreationState.initial();
  }

  Future<void> saveOrder(Order order) async {
    state = const OrderCreationState.loading();
    try {
      await _saveOrderUseCase(order);
      state = const OrderCreationState.success();
    } catch (e) {
      state = OrderCreationState.error(e.toString());
    }
  }
}
