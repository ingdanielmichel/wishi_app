import 'package:firebase_database/firebase_database.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/models/menu_item_option.dart';
import 'package:wishi_app/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final FirebaseDatabase _database;

  MenuRepositoryImpl(this._database);

  @override
  Future<List<Category>> getMenu() async {
    final snapshot =
        await _database.ref('menus/menu_principal/categories').get();
    if (snapshot.exists) {
      return _parseCategories(snapshot.value);
    } else {
      return [];
    }
  }

  @override
  Stream<List<Category>> getMenuStream() {
    return _database.ref('menus/menu_principal/categories').onValue.map((event) {
      if (event.snapshot.exists) {
        return _parseCategories(event.snapshot.value);
      } else {
        return [];
      }
    });
  }

  List<Category> _parseCategories(dynamic categoriesValue) {
    final categoriesList = categoriesValue as List<dynamic>;
    final categories = categoriesList.map((categoryData) {
      final categoryId = categoryData['id'];
      final itemsList = categoryData['items'] as List<dynamic>? ?? [];
      final items = itemsList.map((itemData) {
        final itemId = itemData['id'];
        final optionsMap = itemData['options'] as List<dynamic>? ?? [];

        List<MenuItemOption> parseOptions(List<dynamic> optionsData) {
          return optionsData.map((optionData) {
            final option = optionData as Map<dynamic, dynamic>;
            final subOptionsData = option['subOptions'] as List<dynamic>?;
            return MenuItemOption(
              name: option['name'] ?? '',
              priceModifier: (option['priceModifier'] ?? 0).toDouble(),
              subOptions: subOptionsData != null ? parseOptions(subOptionsData) : [],
            );
          }).toList();
        }

        final options = parseOptions(optionsMap);

        return MenuItem(
          id: itemId,
          name: itemData['name'] ?? '',
          description: itemData['description'] ?? '',
          price: (itemData['price'] ?? 0).toDouble(),
          tags: List<String>.from(itemData['tags'] ?? []),
          available: itemData['available'] ?? false,
          options: options,
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
