import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Define a state class for the home screen
// class HomeState {
//   final bool isDayMenu;
//   final List<MenuCategory> categories;
//   HomeState({required this.isDayMenu, required this.categories});
// }

class HomeViewModel extends StateNotifier<AsyncValue<void>> {
  HomeViewModel() : super() {
    state = const AsyncValue.data(null);
  }

  // final FirestoreService _firestoreService;
  // final AnalyticsService _analyticsService;

  // HomeViewModel(this._firestoreService, this._analyticsService) : super(const AsyncValue.loading()) {
  //   _loadMenu();
  // }

  // Future<void> _loadMenu() async {
  //   // TODO: Implement logic to determine if it's day or night
  //   // and fetch the appropriate menu from Firestore.
  //   // state = const AsyncValue.loading();
  //   // try {
  //   //   final categories = await _firestoreService.getCategories('night_menu');
  //   //   state = AsyncValue.data(...);
  //   // } catch (e, s) {
  //   //   state = AsyncValue.error(e, s);
  //   // }
  // }
}

// TODO: Create the provider for the HomeViewModel
// final homeViewModelProvider = StateNotifierProvider<HomeViewModel, AsyncValue<void>>((ref) {
//   final firestoreService = ref.watch(firestoreServiceProvider);
//   final analyticsService = ref.watch(analyticsServiceProvider);
//   return HomeViewModel(firestoreService, analyticsService);
// });
