import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/repositories/order_repository.dart';

class SaveOrderUseCase {
  final IOrderRepository _orderRepository;

  SaveOrderUseCase(this._orderRepository);

  Future<void> call(Order order) async {
    return await _orderRepository.createOrder(order);
  }
}
