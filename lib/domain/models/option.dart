import 'package:wishi_app/data/models/option_dto.dart'; // Add this import

class Option {
  final String name;
  final double priceModifier;

  Option({required this.name, required this.priceModifier});

  // Add fromDTO factory
  factory Option.fromDTO(OptionDTO dto) {
    return Option(name: dto.name, priceModifier: dto.priceModifier);
  }

  // Add toDTO method
  OptionDTO toDTO() {
    return OptionDTO(name: name, priceModifier: priceModifier);
  }

  Option copyWith({String? name, double? priceModifier}) {
    return Option(
      name: name ?? this.name,
      priceModifier: priceModifier ?? this.priceModifier,
    );
  }
}
