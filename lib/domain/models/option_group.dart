import 'package:wishi_app/data/models/option_group_dto.dart';

import 'package:wishi_app/domain/models/option.dart';

class OptionGroup {
  final String id;
  final String name;
  final String selectionType;
  final List<Option> options;
  final bool display;

  OptionGroup({
    required this.id,
    required this.name,
    required this.selectionType,
    required this.options,
    required this.display,
  });

  // Add fromDTO factory
  factory OptionGroup.fromDTO(OptionGroupDTO dto) {
    return OptionGroup(
      id: dto.id,
      name: dto.name,
      selectionType: dto.selectionType,
      options: dto.options
          .map((optionDto) => Option.fromDTO(optionDto))
          .toList(), // Needs Option.fromDTO
      display: dto.display,
    );
  }

  // Add toDTO method
  OptionGroupDTO toDTO() {
    return OptionGroupDTO(
      id: id,
      name: name,
      selectionType: selectionType,
      options: options
          .map((option) => option.toDTO())
          .toList(), // Needs Option.toDTO
      display: display,
    );
  }

  OptionGroup copyWith({
    String? id,
    String? name,
    String? selectionType,
    List<Option>? options,
    bool? display,
  }) {
    return OptionGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      selectionType: selectionType ?? this.selectionType,
      options: options ?? this.options,
      display: display ?? this.display,
    );
  }
}
