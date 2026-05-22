import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/calculator/screens/splash_screen.dart';
import 'app/calculator/theme/app_theme.dart';
import 'app/calculator/utils/calculator_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await CalculatorPreferences.instance.load();
  runApp(const Calculator2026App());
}

class Calculator2026App extends StatelessWidget {
  const Calculator2026App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator 2026 Pro',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
