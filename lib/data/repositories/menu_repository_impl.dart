import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:wishi_app/data/models/category_dto.dart';

import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/models/menu_item.dart';
import 'package:wishi_app/domain/repositories/menu_repository.dart';

class MenuRepositoryImpl implements MenuRepository {
  final FirebaseDatabase _database;

  MenuRepositoryImpl(this._database);

  @override
  Future<List<Category>> getMenu() async {
    final snapshot = await _database.ref('menus').get();
    if (snapshot.exists && snapshot.value != null) {
      log(snapshot.value.toString());
      return _parseCategories(snapshot.value!);
    } else {
      return [];
    }
  }

  @override
  Stream<List<Category>> getMenuStream() {
    return _database.ref('menus').onValue.map((event) {
      if (event.snapshot.exists && event.snapshot.value != null) {
        return _parseCategories(event.snapshot.value!);
      } else {
        return [];
      }
    });
  }

  List<Category> _parseCategories(dynamic categoriesValue) {
    if (categoriesValue == null) return [];

    // Handle case where categoriesValue might be a Map (if indices are keys) or List
    final List<dynamic> rawMenu;
    if (categoriesValue is List) {
      rawMenu = categoriesValue;
    } else if (categoriesValue is Map) {
      rawMenu = categoriesValue.values.toList();
    } else {
      return [];
    }

    // DEBUG LOG: Print first item structure to check for keys
    if (rawMenu.isNotEmpty) {
      log('Raw Menu First Item: ${rawMenu.first}');
    }

    if (rawMenu.isEmpty) return [];

    final firstItem = rawMenu.first;
    if (firstItem == null) return [];

    final Map<Object?, Object?>? menuData = firstItem is Map<Object?, Object?>
        ? firstItem
        : null;
    if (menuData == null) return [];

    final rawCategories = menuData['categories'];
    if (rawCategories == null || rawCategories is! List) return [];

    final categories = rawCategories
        .map((categoryData) {
          if (categoryData is Map) {
            return CategoryDTO.fromJson(
              Map<String, dynamic>.from(categoryData),
            ).toDomain();
          }
          return null;
        })
        .whereType<Category>()
        // Flatten items based on displayed options (via OptionGroups)
        .map((category) {
          final flattenedItems = <MenuItem>[];
          for (final item in category.items) {
            bool hasDisplayedOptions = false;

            for (final group in item.optionGroups) {
              // Check if the GROUP is set to display
              if (group.display) {
                hasDisplayedOptions = true;
                for (final option in group.options) {
                  // Create a new MenuItem for each option in this displayed group
                  flattenedItems.add(
                    item.copyWith(
                      id: '${item.id}_${group.id}_${option.name.replaceAll(RegExp(r'\s+'), '_')}',
                      name: option.name, // Use option name
                      price: item.price + option.priceModifier, // Add modifier
                      // Remove the group that this option belongs to, as it's now selected
                      optionGroups: item.optionGroups
                          .where((g) => g.id != group.id)
                          .toList(),
                    ),
                  );
                }
              }
            }

            // If no option GROUPS are set to display, assume original item behavior.
            // (Or if the item has no displayed groups, maybe we show the original item)
            // Logic: If we generated cards from options, we probably don't want the original generic item.
            // If we generated 0 cards, we MUST show the original item.
            if (!hasDisplayedOptions) {
              flattenedItems.add(item);
            }
          }
          return category.copyWith(items: flattenedItems);
        })
        .toList();

    return categories..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
  }
}
