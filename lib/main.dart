import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wishi_app/presentation/views/auth_wrapper.dart';

import 'package:wishi_app/firebase_options.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Stripe (only for mobile platforms)
    // Stripe payment sheet is not supported on web
    if (!kIsWeb) {
      // TODO: Replace with your actual Stripe publishable key
      // Get this from: https://dashboard.stripe.com/test/apikeys
      Stripe.publishableKey =
          'pk_test_51SaYrfEalf8uoBjmwpbwxUiF9Gm4mYubXWBPsGjsKDKUfVNoWw6lcuqFqyQbc9sbFmewDPHTARdcdn86rQTQ0Bl900lVAh1EbS';
    }

    runApp(const ProviderScope(child: MyApp()));
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize Firebase: $e');
    debugPrintStack(stackTrace: stackTrace);
    // You might want to run a simple error app here if initialization fails
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to initialize app: $e')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishi',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthWrapper(),
    );
  }
}
