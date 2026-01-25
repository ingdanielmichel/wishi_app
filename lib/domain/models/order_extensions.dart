import 'package:wishi_app/data/models/order_dto.dart';

import 'package:wishi_app/domain/models/order.dart';
import 'package:wishi_app/domain/models/order_item.dart';
import 'package:wishi_app/domain/models/order_status.dart';

extension OrderExtension on Order {
  OrderDTO toDTO() {
    return OrderDTO(
      id: id,
      userId: userId,
      name: name,
      items: items.map((item) => item.toDTO()).toList(),
      total: total,
      status: status.toJson(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension OrderDTOExtension on OrderDTO {
  Order toDomain() {
    return Order(
      id: id,
      userId: userId,
      name: name,
      items: items.map((itemDto) => OrderItem.fromDTO(itemDto)).toList(),
      total: total,
      status: OrderStatus.fromJson(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
