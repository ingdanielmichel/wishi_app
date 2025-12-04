import 'package:wishi_app/domain/models/menu_item_option.dart';

class MenuItemOptionDTO {
  final String name;
  final double priceModifier;
  final List<MenuItemOptionDTO> subOptions;

  MenuItemOptionDTO({
    required this.name,
    required this.priceModifier,
    this.subOptions = const [],
  });

  factory MenuItemOptionDTO.fromFirestore(Map<String, dynamic> data) {
    return MenuItemOptionDTO(
      name: data['name'] ?? '',
      priceModifier: (data['priceModifier'] ?? 0).toDouble(),
      subOptions: (data['subOptions'] as List<dynamic>? ?? [])
          .map((option) => MenuItemOptionDTO.fromFirestore(option))
          .toList(),
    );
  }

  MenuItemOption toDomain() {
    return MenuItemOption(
      name: name,
      priceModifier: priceModifier,
      subOptions: subOptions.map((dto) => dto.toDomain()).toList(),
    );
  }

  factory MenuItemOptionDTO.fromDomain(MenuItemOption option) {
    return MenuItemOptionDTO(
      name: option.name,
      priceModifier: option.priceModifier,
      subOptions: option.subOptions
          .map((subOption) => MenuItemOptionDTO.fromDomain(subOption))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'priceModifier': priceModifier,
      'subOptions': subOptions.map((option) => option.toFirestore()).toList(),
    };
  }
}
