import '../models/menu_item.dart';
import '../repositories/menu_repository.dart';

class GetMenuItems {
  final MenuRepository repository;

  GetMenuItems(this.repository);

  Future<List<MenuItem>> call(String categoryId) async {
    return await repository.getItems(categoryId);
  }
}
