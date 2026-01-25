import 'package:wishi_app/data/models/option_group_dto.dart';

class MenuItemDTO {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final bool available;
  final String? imageUrl;
  final List<OptionGroupDTO> optionGroups;

  MenuItemDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
    required this.available,
    this.imageUrl,
    required this.optionGroups,
  });

  factory MenuItemDTO.fromJson(Map<String, dynamic> json) => MenuItemDTO(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
    available: json['available'] as bool? ?? true,
    imageUrl: json['image_url'] as String?,
    optionGroups:
        (json['option_groups'] as List<dynamic>?)
            ?.map(
              (e) =>
                  OptionGroupDTO.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'tags': tags,
    'available': available,
    'image_url': imageUrl,
    'option_groups': optionGroups.map((e) => e.toJson()).toList(),
  };
}
