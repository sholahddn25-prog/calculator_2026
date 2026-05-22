import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { system, light, dark }

/// Pengaturan kalkulator — disimpan lokal dan dipakai di seluruh app.
class CalculatorPreferences extends ChangeNotifier {
  CalculatorPreferences._();
  static final CalculatorPreferences instance = CalculatorPreferences._();

  static const _keyDecimal = 'decimal_places';
  static const _keyThousands = 'thousand_separator';
  static const _keyHaptic = 'haptic_enabled';
  static const _keyDegrees = 'use_degrees';
  static const _keySciStart = 'scientific_on_start';
  static const _keyTheme = 'theme_preference';
  static const _keyDisplaySize = 'display_font_size';
  static const _keySciNotation = 'scientific_notation';
  static const _keyHistoryMax = 'max_history_items';
  static const _keyConfirmClear = 'confirm_clear_history';
  static const _keyAutoCopy = 'auto_copy_result';

  int decimalPlaces = 2;
  bool thousandSeparator = true;
  bool hapticEnabled = true;
  bool useDegrees = true;
  bool scientificOnStart = false;
  AppThemePreference themePreference = AppThemePreference.system;
  double displayFontSize = 52;
  bool scientificNotation = false;
  int maxHistoryItems = 50;
  bool confirmClearHistory = true;
  bool autoCopyResult = false;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    decimalPlaces = prefs.getInt(_keyDecimal) ?? 2;
    thousandSeparator = prefs.getBool(_keyThousands) ?? true;
    hapticEnabled = prefs.getBool(_keyHaptic) ?? true;
    useDegrees = prefs.getBool(_keyDegrees) ?? true;
    scientificOnStart = prefs.getBool(_keySciStart) ?? false;
    themePreference = AppThemePreference
        .values[prefs.getInt(_keyTheme) ?? AppThemePreference.system.index];
    displayFontSize = prefs.getDouble(_keyDisplaySize) ?? 52;
    scientificNotation = prefs.getBool(_keySciNotation) ?? false;
    maxHistoryItems = prefs.getInt(_keyHistoryMax) ?? 50;
    confirmClearHistory = prefs.getBool(_keyConfirmClear) ?? true;
    autoCopyResult = prefs.getBool(_keyAutoCopy) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDecimal, decimalPlaces);
    await prefs.setBool(_keyThousands, thousandSeparator);
    await prefs.setBool(_keyHaptic, hapticEnabled);
    await prefs.setBool(_keyDegrees, useDegrees);
    await prefs.setBool(_keySciStart, scientificOnStart);
    await prefs.setInt(_keyTheme, themePreference.index);
    await prefs.setDouble(_keyDisplaySize, displayFontSize);
    await prefs.setBool(_keySciNotation, scientificNotation);
    await prefs.setInt(_keyHistoryMax, maxHistoryItems);
    await prefs.setBool(_keyConfirmClear, confirmClearHistory);
    await prefs.setBool(_keyAutoCopy, autoCopyResult);
    notifyListeners();
  }

  Future<void> setDecimalPlaces(int value) async {
    decimalPlaces = value.clamp(0, 8);
    await _save();
  }

  Future<void> setThousandSeparator(bool value) async {
    thousandSeparator = value;
    await _save();
  }

  Future<void> setHapticEnabled(bool value) async {
    hapticEnabled = value;
    await _save();
  }

  Future<void> setUseDegrees(bool value) async {
    useDegrees = value;
    await _save();
  }

  Future<void> setScientificOnStart(bool value) async {
    scientificOnStart = value;
    await _save();
  }

  Future<void> setThemePreference(AppThemePreference value) async {
    themePreference = value;
    await _save();
  }

  Future<void> setDisplayFontSize(double value) async {
    displayFontSize = value;
    await _save();
  }

  Future<void> setScientificNotation(bool value) async {
    scientificNotation = value;
    await _save();
  }

  Future<void> setMaxHistoryItems(int value) async {
    maxHistoryItems = value;
    await _save();
  }

  Future<void> setConfirmClearHistory(bool value) async {
    confirmClearHistory = value;
    await _save();
  }

  Future<void> setAutoCopyResult(bool value) async {
    autoCopyResult = value;
    await _save();
  }

  bool resolveDarkMode(Brightness platformBrightness) {
    switch (themePreference) {
      case AppThemePreference.light:
        return false;
      case AppThemePreference.dark:
        return true;
      case AppThemePreference.system:
        return platformBrightness == Brightness.dark;
    }
  }
}
