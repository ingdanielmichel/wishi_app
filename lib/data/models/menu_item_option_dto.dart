class MenuItemOptionDTO {
  final String name;
  final double priceModifier;
  final List<MenuItemOptionDTO> subOptions;

  MenuItemOptionDTO({
    required this.name,
    required this.priceModifier,
    this.subOptions = const [],
  });

  factory MenuItemOptionDTO.fromJson(Map<String, dynamic> json) => MenuItemOptionDTO(
        name: json['name'] as String,
        priceModifier: json['price_modifier'] as double,
        subOptions: (json['sub_options'] as List<dynamic>?)
                ?.map((e) => MenuItemOptionDTO.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price_modifier': priceModifier,
        'sub_options': subOptions.map((e) => e.toJson()).toList(),
      };
}
