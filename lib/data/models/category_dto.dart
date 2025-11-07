import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/category.dart';

class MenuCategoryDTO {
  final String id;
  final String name;
  final int order;

  MenuCategoryDTO({required this.id, required this.name, required this.order});

  factory MenuCategoryDTO.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MenuCategoryDTO(
      id: doc.id,
      name: data['name'] ?? '',
      order: data['order'] ?? 0,
    );
  }

  Category toDomain() {
    return Category(
      id: id,
      name: name,
      order: order,
      items: [], // The Category model requires an items list.
    );
  }
}
