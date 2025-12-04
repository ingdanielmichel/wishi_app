import '../../domain/models/option.dart';

class OptionDTO {
  final String name;
  final double priceModifier;

  OptionDTO({required this.name, required this.priceModifier});

  factory OptionDTO.fromFirestore(Map<String, dynamic> data) {
    return OptionDTO(
      name: data['name'] ?? '',
      priceModifier: (data['price_modifier'] ?? 0).toDouble(),
    );
  }

  Option toDomain() {
    return Option(name: name, priceModifier: priceModifier);
  }
}
