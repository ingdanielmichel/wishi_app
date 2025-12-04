import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/domain/models/category.dart';
import 'package:wishi_app/presentation/widgets/category_tab_view.dart';
import 'package:wishi_app/application/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(menuFutureProvider);

    return asyncCategories.when(
      data: (categories) {
        if (_tabController == null ||
            _tabController!.length != categories.length) {
          _tabController?.dispose();
          _tabController = TabController(
            length: categories.length,
            vsync: this,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Wishi Menu'),
            bottom: TabBar(
              controller: _tabController,
              tabs: categories.map((Category category) {
                return Tab(text: category.name);
              }).toList(),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: categories.map((Category category) {
              return CategoryTabView(category: category);
            }).toList(),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
