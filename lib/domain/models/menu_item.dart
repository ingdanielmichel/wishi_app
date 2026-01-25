import 'package:wishi_app/data/models/menu_item_dto.dart';
import 'package:wishi_app/domain/models/option_group.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final bool available;
  final String? imageUrl;
  final List<OptionGroup> optionGroups;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
    required this.available,
    this.imageUrl,
    required this.optionGroups,
  });

  // Add fromDTO factory
  factory MenuItem.fromDTO(MenuItemDTO dto) {
    return MenuItem(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      price: dto.price,
      tags: dto.tags,
      available: dto.available,
      imageUrl: dto.imageUrl,
      optionGroups: dto.optionGroups
          .map((groupDto) => OptionGroup.fromDTO(groupDto))
          .toList(), // Need fromDTO for OptionGroup
    );
  }

  // Add toDTO method
  MenuItemDTO toDTO() {
    return MenuItemDTO(
      id: id,
      name: name,
      description: description,
      price: price,
      tags: tags,
      available: available,
      imageUrl: imageUrl,
      optionGroups: optionGroups
          .map((group) => group.toDTO())
          .toList(), // Need toDTO for OptionGroup
    );
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    List<String>? tags,
    bool? available,
    String? imageUrl,
    List<OptionGroup>? optionGroups,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      tags: tags ?? this.tags,
      available: available ?? this.available,
      imageUrl: imageUrl ?? this.imageUrl,
      optionGroups: optionGroups ?? this.optionGroups,
    );
  }
}
