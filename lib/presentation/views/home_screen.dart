import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Use a provider to get the current menu (day/night)
    // final menuAsyncValue = ref.watch(menuProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishi Menu'),
      ),
      body: Center(
        child: Text('Home Screen - Menu will be displayed here.'),
        // TODO: Use AsyncValue.when to handle loading, data, and error states
        // menuAsyncValue.when(
        //   loading: () => const CircularProgressIndicator(),
        //   error: (err, stack) => Text('Error: $err'),
        //   data: (menu) {
        //     return ListView.builder(
        //       itemCount: menu.categories.length,
        //       itemBuilder: (context, index) {
        //         final category = menu.categories[index];
        //         return Text(category.name);
        //       },
        //     );
        //   },
        // ),
      ),
    );
  }
}
