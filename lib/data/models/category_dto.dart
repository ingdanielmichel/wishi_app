import 'package:wishi_app/data/models/menu_item_dto.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';

class CategoryDTO {
  final String id;
  final String name;
  final int? order;
  final List<MenuItemDTO> items;

  CategoryDTO({
    required this.id,
    required this.name,
    this.order,
    required this.items,
  });

  factory CategoryDTO.fromJson(Map<String, dynamic> json) => CategoryDTO(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? 'Unknown',
    order: json['order'] as int?,
    items:
        (json['items'] as List<dynamic>?)
            ?.map(
              (e) => MenuItemDTO.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'order': order,
    'items': items.map((e) => e.toJson()).toList(),
  };

  Category toDomain() {
    return Category(
      id: id,
      name: name,
      order: order ?? 0,
      items: items.map((itemDto) => MenuItem.fromDTO(itemDto)).toList(),
    );
  }
}
