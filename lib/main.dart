import 'package:flutter/material.dart';

import 'app/calculator/screens/calculator_screen.dart';

void main() {
  runApp(const QuietLuxuryCalculatorApp());
}

class QuietLuxuryCalculatorApp extends StatelessWidget {
  const QuietLuxuryCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiet Luxury Calculator',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}
