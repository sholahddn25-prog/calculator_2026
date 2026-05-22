import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/calculator/screens/calculator_screen.dart';
import 'app/calculator/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const QuietLuxuryCalculatorApp());
}

class QuietLuxuryCalculatorApp extends StatelessWidget {
  const QuietLuxuryCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator 2026',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const CalculatorScreen(),
    );
  }
}
