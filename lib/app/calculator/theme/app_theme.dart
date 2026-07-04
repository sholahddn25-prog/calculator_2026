import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system premium untuk Calculator 2026 Pro.
/// Palet: Deep Teal + Gold + Glassmorphism.
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color primaryTealDark = Color(0xFF5EEAD4);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFFFD700);

  // Dark Background Palette
  static const Color darkBg1 = Color(0xFF030712);
  static const Color darkBg2 = Color(0xFF060F1C);
  static const Color darkBg3 = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF0E1E32);
  static const Color darkSurfaceElevated = Color(0xFF132540);

  // Light Background Palette
  static const Color lightBg1 = Color(0xFFF0F9FF);
  static const Color lightBg2 = Color(0xFFE0F2FE);
  static const Color lightBg3 = Color(0xFFF8FAFF);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // ─── Themes ────────────────────────────────────────────────────────────────
  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryTeal,
      secondary: const Color(0xFF0E7490),
      tertiary: accentGold,
      surface: lightSurface,
      surfaceContainerLowest: const Color(0xFFF0F9FF),
      surfaceContainerLow: const Color(0xFFE0F2FE),
      surfaceContainer: const Color(0xFFCCE8F4),
      surfaceContainerHigh: const Color(0xFFBBDEF0),
      surfaceContainerHighest: const Color(0xFFADD4E8),
      onPrimary: Colors.white,
      onSurface: const Color(0xFF0B1220),
      onSurfaceVariant: const Color(0xFF374151),
      outline: const Color(0xFF94A3B8),
    );

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: lightBg1,
      textTheme: _buildTextTheme(Brightness.light),
      filledButtonTheme: _filledButtonTheme(cs),
      snackBarTheme: _snackBarTheme(cs, Brightness.light),
      dialogTheme: _dialogTheme(cs),
      dividerTheme: const DividerThemeData(space: 1, thickness: 0.5),
    );
  }

  static ThemeData dark() {
    final cs = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryTealDark,
      secondary: const Color(0xFF67E8F9),
      tertiary: accentGold,
      surface: darkBg1,
      surfaceContainerLowest: const Color(0xFF020609),
      surfaceContainerLow: darkBg2,
      surfaceContainer: darkBg3,
      surfaceContainerHigh: darkSurface,
      surfaceContainerHighest: darkSurfaceElevated,
      onPrimary: darkBg1,
      onSurface: const Color(0xFFE2E8F0),
      onSurfaceVariant: const Color(0xFF94A3B8),
      outline: const Color(0xFF1E3A5F),
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: darkBg1,
      textTheme: _buildTextTheme(Brightness.dark),
      filledButtonTheme: _filledButtonTheme(cs),
      snackBarTheme: _snackBarTheme(cs, Brightness.dark),
      dialogTheme: _dialogTheme(cs),
      dividerTheme: const DividerThemeData(space: 1, thickness: 0.5),
    );
  }

  // ─── Typography ────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF0B1220);
    final variant = brightness == Brightness.dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF374151);

    return GoogleFonts.plusJakartaSansTextTheme().copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: base,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: base,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: base,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: base,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: base,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: base,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: variant,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: variant,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: variant,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: variant,
      ),
    );
  }

  // ─── Component Themes ──────────────────────────────────────────────────────
  static FilledButtonThemeData _filledButtonTheme(ColorScheme cs) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  static SnackBarThemeData _snackBarTheme(ColorScheme cs, Brightness b) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: b == Brightness.dark
            ? const Color(0xFF1E3A5F)
            : const Color(0xFF0F172A),
        contentTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        elevation: 8,
      );

  static DialogThemeData _dialogTheme(ColorScheme cs) => DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
      );

  // ─── Decorations ───────────────────────────────────────────────────────────
  static BoxDecoration displayCardDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF0E1E32).withValues(alpha: 0.9),
                const Color(0xFF132540).withValues(alpha: 0.85),
              ]
            : [
                Colors.white.withValues(alpha: 0.9),
                const Color(0xFFE0F2FE).withValues(alpha: 0.8),
              ],
      ),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: isDark
            ? primaryTealDark.withValues(alpha: 0.2)
            : primaryTeal.withValues(alpha: 0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : primaryTeal.withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: isDark
              ? primaryTealDark.withValues(alpha: 0.04)
              : primaryTeal.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Color displayHistoryColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.onSurfaceVariant;
  }

  static Color displayResultColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.primary;
  }

  static LinearGradient primaryGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [primaryTealDark, accentGold]
          : [primaryTeal, const Color(0xFF0E7490)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static List<Color> backgroundGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return [darkBg1, darkBg2, darkBg3, darkBg1];
    }
    return [lightBg1, lightBg2, lightBg3, lightSurface];
  }
}
