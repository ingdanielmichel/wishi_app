class OptionDTO {
  final String name;
  final double priceModifier;

  OptionDTO({required this.name, required this.priceModifier});

  factory OptionDTO.fromJson(Map<String, dynamic> json) => OptionDTO(
    name: json['name'] as String,
    priceModifier: (json['price_modifier'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price_modifier': priceModifier,
  };
}
