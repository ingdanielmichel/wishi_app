import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/repositories/menu_repository.dart';

class GetMenu {
  final MenuRepository repository;

  GetMenu(this.repository);

  Stream<List<Category>> call() {
    return repository.getMenuStream();
  }
}
