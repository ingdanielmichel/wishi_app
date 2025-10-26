import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/menu_item.dart';

class MenuItemDTO {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> tags;
  final bool available;

  MenuItemDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.tags,
    required this.available,
  });

  factory MenuItemDTO.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MenuItemDTO(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      available: data['available'] ?? false,
    );
  }

  MenuItem toDomain() {
    return MenuItem(
      id: id,
      name: name,
      description: description,
      price: price,
      tags: tags,
      available: available,
    );
  }
}
