import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wishi_app/data/models/order_item_dto.dart';

class OrderDTO {
  final String id;
  final String userId;
  final String name;
  final List<OrderItemDTO> items;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDTO({
    required this.id,
    required this.userId,
    required this.name,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDTO.fromJson(Map<String, dynamic> json) => OrderDTO(
    id: json['id'] as String? ?? '',
    userId: json['user_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    items:
        (json['items'] as List<dynamic>?)
            ?.map(
              (e) => OrderItemDTO.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [],
    total: (json['total'] as num?)?.toDouble() ?? 0.0,
    status: json['status'] as String? ?? 'draft',
    createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    updatedAt: (json['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'status': status,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };
}
