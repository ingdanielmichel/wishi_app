import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/option.dart';
import 'package:wishi_app/domain/models/option_group.dart';
import 'package:wishi_app/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final FirebaseDatabase _database;

  MenuRepositoryImpl(this._database);

  @override
  Future<List<Category>> getMenu() async {
    final snapshot = await _database.ref('menus').get();
    if (snapshot.exists) {
      log(snapshot.value.toString());
      return _parseCategories(snapshot.value);
    } else {
      return [];
    }
  }

  @override
  Stream<List<Category>> getMenuStream() {
    return _database.ref('menus').onValue.map((event) {
      if (event.snapshot.exists) {
        return _parseCategories(event.snapshot.value);
      } else {
        return [];
      }
    });
  }

  List<Category> _parseCategories(dynamic categoriesValue) {
    final menu = (categoriesValue as List<dynamic>).first;
    final categoriesList = menu['categories'] as List<dynamic>;
    final categories = categoriesList.map((categoryData) {
      final categoryId = categoryData['id'];
      final itemsList = categoryData['items'] as List<dynamic>? ?? [];
      final items = itemsList.map((itemData) {
        final itemId = itemData['id'];
        final optionGroupsList =
            itemData['option_groups'] as List<dynamic>? ?? [];

        final optionGroups = optionGroupsList.map((groupData) {
          final optionsList = groupData['options'] as List<dynamic>? ?? [];
          final options = optionsList.map((optionData) {
            return Option(
              name: optionData['name'] ?? '',
              priceModifier: (optionData['price_modifier'] ?? 0).toDouble(),
            );
          }).toList();

          return OptionGroup(
            id: groupData['id'] ?? '',
            name: groupData['name'] ?? '',
            selectionType: groupData['selection_type'] ?? 'single',
            options: options,
          );
        }).toList();

        return MenuItem(
          id: itemId,
          name: itemData['name'] ?? '',
          description: itemData['description'] ?? '',
          price: (itemData['price'] ?? 0).toDouble(),
          tags: List<String>.from(itemData['tags'] ?? []),
          available: itemData['available'] ?? false,
          optionGroups: optionGroups,
        );
      }).toList();

      return Category(
        id: categoryId,
        name: categoryData['name'] ?? '',
        order: categoryData['order'] ?? 0,
        items: items,
      );
    }).toList();

    return categories..sort((a, b) => a.order.compareTo(b.order));
  }
}
