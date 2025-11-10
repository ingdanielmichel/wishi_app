import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wishi_app/application/providers.dart';
import 'package:wishi_app/presentation/views/main_screen.dart';

final authInitializerProvider = FutureProvider<void>((ref) async {
  await ref.read(signInAnonymouslyUseCaseProvider).call();
});

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authInitializer = ref.watch(authInitializerProvider);

    return authInitializer.when(
      data: (_) => const MainScreen(),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Could not sign in: $err')),
      ),
    );
  }
}