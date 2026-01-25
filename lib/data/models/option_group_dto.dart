import 'package:wishi_app/data/models/option_dto.dart';

class OptionGroupDTO {
  final String id;
  final String name;
  final String selectionType;
  final List<OptionDTO> options;
  final bool display;

  OptionGroupDTO({
    required this.id,
    required this.name,
    required this.selectionType,
    required this.options,
    required this.display,
  });

  factory OptionGroupDTO.fromJson(Map<String, dynamic> json) => OptionGroupDTO(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    selectionType: json['selection_type'] as String? ?? 'single',
    options:
        (json['options'] as List<dynamic>?)
            ?.map(
              (e) => OptionDTO.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [],
    display: (json['display'] ?? json['Display']) as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'selection_type': selectionType,
    'options': options.map((e) => e.toJson()).toList(),
    'display': display,
  };
}
