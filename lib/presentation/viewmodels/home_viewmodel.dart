import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/menu_repository_impl.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../domain/usecases/get_categories.dart';

// 1. State Class
class HomeState {
  final List<MenuCategory> categories;
  final bool isLoading;

  HomeState({this.categories = const [], this.isLoading = true});

  HomeState copyWith({
    List<MenuCategory>? categories,
    bool? isLoading,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 2. Providers
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepositoryImpl();
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return GetCategories(repository);
});

// 3. ViewModel
class HomeViewModel extends StateNotifier<HomeState> {
  final GetCategories _getCategories;

  HomeViewModel(this._getCategories) : super(HomeState()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    state = state.copyWith(isLoading: true);
    try {
      final categories = await _getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      // Handle error appropriately
      state = state.copyWith(isLoading: false);
    }
  }
}

// 4. ViewModel Provider
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final getCategories = ref.watch(getCategoriesProvider);
  return HomeViewModel(getCategories);
});