import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import the home screen view
// import 'package:wishi_app/presentation/views/home_screen.dart';

void main() {
  // TODO: Initialize Firebase
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // TODO: Set home to HomeScreen
      home: const Scaffold(
        body: Center(
          child: Text('Wishi App'),
        ),
      ),
    );
  }
}