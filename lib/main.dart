import 'package:flutter/material.dart';
import 'screens/checklists_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ChecklistsScreen(),
    );
  }
}
