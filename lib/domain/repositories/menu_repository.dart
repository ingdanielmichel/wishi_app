import '../models/category.dart';
import '../models/menu_item.dart';

abstract class MenuRepository {
  Future<List<MenuCategory>> getCategories();
  Future<List<MenuItem>> getItems(String categoryId);
}
