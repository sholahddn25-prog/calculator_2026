import 'package:flutter/material.dart';

class AppTheme {
  static const Color _bg = Color(0xFF0E0F12);
  static const Color _surface = Color(0xFFF5F5F7);

  static ThemeData light() {
    const Color primary = Color(0xFF111827);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _surface,
      colorScheme: colorScheme.copyWith(
        primary: primary,
        onPrimary: Colors.white,
        surface: _surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: ThemeData.light().textTheme.copyWith(
        bodyMedium: const TextStyle(color: Color(0xFF111827)),
      ),
    );
  }

  static ThemeData dark() {
    const Color primary = Color(0xFFE9EAEE);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.white,
      brightness: Brightness.dark,
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      colorScheme: colorScheme.copyWith(
        primary: primary,
        onPrimary: const Color(0xFF0B0C10),
        surface: _bg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
        bodyMedium: const TextStyle(color: Color(0xFFE9EAEE)),
      ),
    );
  }
}
