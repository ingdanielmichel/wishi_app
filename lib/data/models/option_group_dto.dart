import 'package:wishi_app/data/models/option_dto.dart';
import '../../domain/models/option_group.dart';

class OptionGroupDTO {
  final String id;
  final String name;
  final String selectionType;
  final List<OptionDTO> options;

  OptionGroupDTO({
    required this.id,
    required this.name,
    required this.selectionType,
    required this.options,
  });

  factory OptionGroupDTO.fromFirestore(Map<String, dynamic> data) {
    var optionsData = data['options'] as List<dynamic>? ?? [];
    List<OptionDTO> options = optionsData
        .map(
          (optionData) =>
              OptionDTO.fromFirestore(optionData as Map<String, dynamic>),
        )
        .toList();

    return OptionGroupDTO(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      selectionType: data['selection_type'] ?? 'single',
      options: options,
    );
  }

  OptionGroup toDomain() {
    return OptionGroup(
      id: id,
      name: name,
      selectionType: selectionType,
      options: options.map((dto) => dto.toDomain()).toList(),
    );
  }
}
