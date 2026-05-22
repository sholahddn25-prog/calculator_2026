import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the calculator UI.
class CalcColors {
  // Light
  static const lightBg = Color(0xFFF0F4F8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightDisplay = Color(0xFFE8EEF4);
  static const lightKey = Color(0xFFFFFFFF);
  static const lightKeyMuted = Color(0xFFE2E8F0);
  static const lightAccent = Color(0xFF0F766E);
  static const lightAccentSoft = Color(0xFFCCFBF1);
  static const lightOperator = Color(0xFF0F766E);
  static const lightText = Color(0xFF0F172A);
  static const lightTextMuted = Color(0xFF64748B);

  // Dark
  static const darkBg = Color(0xFF070B14);
  static const darkSurface = Color(0xFF111827);
  static const darkDisplay = Color(0xFF1A2332);
  static const darkKey = Color(0xFF1E293B);
  static const darkKeyMuted = Color(0xFF334155);
  static const darkAccent = Color(0xFF5EEAD4);
  static const darkAccentSoft = Color(0xFF134E4A);
  static const darkOperator = Color(0xFF5EEAD4);
  static const darkText = Color(0xFFF1F5F9);
  static const darkTextMuted = Color(0xFF94A3B8);
}

class AppTheme {
  static const accentGold = Color(0xFFD4AF37);
  static const accentGoldLight = Color(0xFFF5E6B8);

  static TextTheme _textTheme(Brightness brightness) {
    final base = GoogleFonts.plusJakartaSansTextTheme(
      brightness == Brightness.light
          ? ThemeData.light().textTheme
          : ThemeData.dark().textTheme,
    );
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w300,
        letterSpacing: -2,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static ThemeData light() {
    const primary = CalcColors.lightAccent;
    const onSurface = CalcColors.lightText;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CalcColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: CalcColors.lightAccentSoft,
        onPrimaryContainer: CalcColors.lightOperator,
        secondary: CalcColors.lightOperator,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFD1FAE5),
        onSecondaryContainer: CalcColors.lightOperator,
        surface: CalcColors.lightSurface,
        onSurface: onSurface,
        onSurfaceVariant: CalcColors.lightTextMuted,
        surfaceContainerHighest: CalcColors.lightKey,
        surfaceContainer: CalcColors.lightKeyMuted,
        outline: Color(0xFFCBD5E1),
        outlineVariant: Color(0xFFE2E8F0),
        error: Color(0xFFDC2626),
      ),
      textTheme: _textTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CalcColors.lightDisplay,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        selectedColor: CalcColors.lightAccentSoft,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        overlayColor: Color(0x330D9488),
      ),
    );
  }

  static ThemeData dark() {
    const primary = CalcColors.darkAccent;
    const onSurface = CalcColors.darkText;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CalcColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: CalcColors.darkBg,
        primaryContainer: CalcColors.darkAccentSoft,
        onPrimaryContainer: CalcColors.darkOperator,
        secondary: CalcColors.darkOperator,
        onSecondary: CalcColors.darkBg,
        secondaryContainer: Color(0xFF1E3A34),
        onSecondaryContainer: CalcColors.darkOperator,
        surface: CalcColors.darkSurface,
        onSurface: onSurface,
        onSurfaceVariant: CalcColors.darkTextMuted,
        surfaceContainerHighest: CalcColors.darkKey,
        surfaceContainer: CalcColors.darkKeyMuted,
        outline: Color(0xFF334155),
        outlineVariant: Color(0xFF1E293B),
        error: Color(0xFFF87171),
      ),
      textTheme: _textTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E293B),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CalcColors.darkDisplay,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFF334155)),
        selectedColor: CalcColors.darkAccentSoft,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        overlayColor: Color(0x332DD4BF),
      ),
    );
  }

  static List<Color> backgroundGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const [
        Color(0xFF030712),
        Color(0xFF0F172A),
        Color(0xFF1E1B4B),
        Color(0xFF030712),
      ];
    }
    return const [
      Color(0xFFFAFAF9),
      Color(0xFFF5F5F4),
      Color(0xFFE7E5E4),
      Color(0xFFD6D3D1),
    ];
  }

  /// Warna hasil — kontras tinggi di mode terang.
  static Color displayResultColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0B1220);
  }

  static Color displayHistoryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
  }

  static BoxDecoration displayCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF1A2332),
                const Color(0xFF111827),
              ]
            : [
                const Color(0xFFFFFFFF),
                const Color(0xFFE2E8F0),
              ],
      ),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFCBD5E1),
        width: isDark ? 1 : 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : const Color(0xFF0D9488).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
