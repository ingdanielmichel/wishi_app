import '../models/category.dart';

abstract class MenuRepository {
  Future<List<Category>> getMenu();
  Stream<List<Category>> getMenuStream();
}
