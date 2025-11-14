import 'package:wishi_app/domain/models/option.dart';

class OptionGroup {
  final String id;
  final String name;
  final String selectionType;
  final List<Option> options;

  OptionGroup({
    required this.id,
    required this.name,
    required this.selectionType,
    required this.options,
  });
}
