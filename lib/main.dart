import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ИИнвентаризация',
      theme: ThemeData(
        colorSchemeSeed: Colors.grey,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
