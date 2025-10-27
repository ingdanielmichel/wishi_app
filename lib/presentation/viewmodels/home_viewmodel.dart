import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../domain/usecases/get_categories.dart';

// 2. Providers
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl();
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return GetCategories(repository);
});

// 3. ViewModel
class HomeViewModel extends AsyncNotifier<List<MenuCategory>> {
  @override
  Future<List<MenuCategory>> build() async {
    // This method will be called automatically to fetch the initial state.
    // Riverpod handles the loading and error states.
    final getCategories = ref.watch(getCategoriesProvider);
    return getCategories();
  }
}

// 4. ViewModel Provider
final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, List<MenuCategory>>(HomeViewModel.new);