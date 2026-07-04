import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app/calculator/screens/splash_screen.dart';
import 'app/calculator/theme/app_theme.dart';
import 'app/calculator/utils/calculator_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for Web and Desktop platforms
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar + navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Load persistent preferences
  await CalculatorPreferences.instance.load();

  runApp(const Calculator2026App());
}

class Calculator2026App extends StatelessWidget {
  const Calculator2026App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CalculatorPreferences.instance,
      builder: (context, _) {
        final prefs = CalculatorPreferences.instance;

        return MaterialApp(
          title: 'Calculator 2026 Pro',
          debugShowCheckedModeBanner: false,
          themeMode: switch (prefs.themePreference) {
            AppThemePreference.system => ThemeMode.system,
            AppThemePreference.light => ThemeMode.light,
            AppThemePreference.dark => ThemeMode.dark,
          },
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const SplashScreen(),
          builder: (context, child) {
            // Ensure text scale doesn't break layout
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
                ),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
