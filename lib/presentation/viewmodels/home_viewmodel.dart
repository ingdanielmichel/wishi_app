import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/services/analytics_service.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/domain/usecases/get_menu.dart';
import 'package:wishi_app/application/providers.dart';

final getMenuProvider = Provider<GetMenu>((ref) {
  final repository = ref.watch(menuRepositoryProvider);
  return GetMenu(repository);
});

final menuStreamProvider = StreamProvider<List<Category>>((ref) {
  final getMenu = ref.watch(getMenuProvider);
  return getMenu();
});

final menuFutureProvider = FutureProvider<List<Category>>((ref) {
  final getMenu = ref.watch(getMenuProvider);
  final analytics = ref.watch(analyticsServiceProvider);

  // Log screen view when data loads
  analytics.logScreenView(screenName: 'HomeScreen');

  return getMenu().first;
});
