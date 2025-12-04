import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wishi_app/data/models/option_group_dto.dart';
import '../../domain/models/menu_item.dart';

class MenuItemDTO {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final bool available;
  final List<OptionGroupDTO> optionGroups;

  MenuItemDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
    required this.available,
    required this.optionGroups,
  });

  factory MenuItemDTO.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    var optionGroupsData = data['option_groups'] as List<dynamic>? ?? [];
    List<OptionGroupDTO> optionGroups = optionGroupsData
        .map(
          (groupData) =>
              OptionGroupDTO.fromFirestore(groupData as Map<String, dynamic>),
        )
        .toList();

    return MenuItemDTO(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      available: data['available'] ?? false,
      optionGroups: optionGroups,
    );
  }

  MenuItem toDomain() {
    return MenuItem(
      id: id,
      name: name,
      description: description,
      price: price,
      tags: tags,
      available: available,
      optionGroups: optionGroups.map((dto) => dto.toDomain()).toList(),
    );
  }
}
