import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/usecases/save_order_usecase.dart';
import 'package:wishi_app/presentation/viewmodels/order_creation/order_creation_state.dart' show OrderCreationState, InitialOrderCreationState, LoadingOrderCreationState, SuccessOrderCreationState, ErrorOrderCreationState;
import 'package:wishi_app/application/providers.dart';

class OrderCreationViewModel extends Notifier<OrderCreationState> {
  late final SaveOrderUseCase _saveOrderUseCase;

  @override
  OrderCreationState build() {
    _saveOrderUseCase = ref.watch(saveOrderUseCaseProvider);
    return InitialOrderCreationState();
  }

  Future<void> saveOrder(Order order) async {
    state = LoadingOrderCreationState();
    try {
      await _saveOrderUseCase(order);
      state = SuccessOrderCreationState();
    } catch (e) {
      state = ErrorOrderCreationState(e.toString());
    }
  }
}
