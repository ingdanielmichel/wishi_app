import 'package:wishi_app/domain/models/option_group.dart';

// Represents a single item on the menu (e.g., a specific taco or drink).
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final bool available;
  final String? imageUrl;
  final List<OptionGroup> optionGroups;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
    required this.available,
    this.imageUrl,
    required this.optionGroups,
  });
}
