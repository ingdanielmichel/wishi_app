import 'package:wishi_app/data/models/category_dto.dart';
import 'package:wishi_app/domain/models/menu_item.dart';

class Category {
  final String id;
  final String name;
  final int? order;
  final List<MenuItem> items;

  Category({
    required this.id,
    required this.name,
    this.order,
    required this.items,
  });

  factory Category.fromDTO(CategoryDTO dto) {
    return Category(
      id: dto.id,
      name: dto.name,
      order: dto.order,
      items: dto.items.map((itemDto) => MenuItem.fromDTO(itemDto)).toList(),
    );
  }

  CategoryDTO toDTO() {
    return CategoryDTO(
      id: id,
      name: name,
      order: order ?? 0,
      items: items.map((item) => item.toDTO()).toList(),
    );
  }

  Category copyWith({
    String? id,
    String? name,
    int? order,
    List<MenuItem>? items,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      items: items ?? this.items,
    );
  }
}
