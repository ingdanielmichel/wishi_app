import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/category.dart';
import '../../domain/models/menu_item.dart';
import '../../domain/repositories/menu_repository.dart';
import '../models/category_dto.dart';
import '../models/menu_item_dto.dart';

class MenuRepositoryImpl implements MenuRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<MenuCategory>> getCategories() async {
    final snapshot = await _firestore.collection('categories').orderBy('order').get();
    return snapshot.docs.map((doc) => MenuCategoryDTO.fromFirestore(doc).toDomain()).toList();
  }

  @override
  Future<List<MenuItem>> getItems(String categoryId) async {
    final snapshot = await _firestore.collection('menu_items').where('categoryId', isEqualTo: categoryId).get();
    return snapshot.docs.map((doc) => MenuItemDTO.fromFirestore(doc).toDomain()).toList();
  }
}
