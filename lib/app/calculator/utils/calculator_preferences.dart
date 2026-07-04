import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferensi aplikasi dengan persistensi nyata menggunakan SharedPreferences.
/// Semua pengaturan tersimpan permanen di perangkat.
class CalculatorPreferences extends ChangeNotifier {
  static final CalculatorPreferences instance = CalculatorPreferences._();
  CalculatorPreferences._();

  // ─── Keys ───────────────────────────────────────────────────────────────────
  static const _kScientificOnStart = 'scientific_on_start';
  static const _kUseDegrees = 'use_degrees';
  static const _kScientificNotation = 'scientific_notation';
  static const _kHapticEnabled = 'haptic_enabled';
  static const _kAutoCopyResult = 'auto_copy_result';
  static const _kConfirmClearHistory = 'confirm_clear_history';
  static const _kThemePreference = 'theme_preference';
  static const _kDisplayFontSize = 'display_font_size';
  static const _kThousandSeparator = 'thousand_separator';
  static const _kDecimalPlaces = 'decimal_places';
  static const _kMaxHistoryItems = 'max_history_items';

  // ─── State ─────────────────────────────────────────────────────────────────
  bool _scientificOnStart = false;
  bool _useDegrees = true;
  bool _scientificNotation = false;
  bool _hapticEnabled = true;
  bool _autoCopyResult = false;
  bool _confirmClearHistory = true;
  AppThemePreference _themePreference = AppThemePreference.system;
  double _displayFontSize = 54;
  bool _thousandSeparator = true;
  int _decimalPlaces = 6;
  int _maxHistoryItems = 50;

  SharedPreferences? _prefs;

  // ─── Getters ────────────────────────────────────────────────────────────────
  bool get scientificOnStart => _scientificOnStart;
  bool get useDegrees => _useDegrees;
  bool get scientificNotation => _scientificNotation;
  bool get hapticEnabled => _hapticEnabled;
  bool get autoCopyResult => _autoCopyResult;
  bool get confirmClearHistory => _confirmClearHistory;
  AppThemePreference get themePreference => _themePreference;
  double get displayFontSize => _displayFontSize;
  bool get thousandSeparator => _thousandSeparator;
  int get decimalPlaces => _decimalPlaces;
  int get maxHistoryItems => _maxHistoryItems;

  // ─── Load ────────────────────────────────────────────────────────────────────
  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final sp = _prefs!;

    _scientificOnStart = sp.getBool(_kScientificOnStart) ?? false;
    _useDegrees = sp.getBool(_kUseDegrees) ?? true;
    _scientificNotation = sp.getBool(_kScientificNotation) ?? false;
    _hapticEnabled = sp.getBool(_kHapticEnabled) ?? true;
    _autoCopyResult = sp.getBool(_kAutoCopyResult) ?? false;
    _confirmClearHistory = sp.getBool(_kConfirmClearHistory) ?? true;
    _themePreference = AppThemePreference.values[
        (sp.getInt(_kThemePreference) ?? 0).clamp(
          0,
          AppThemePreference.values.length - 1,
        )];
    _displayFontSize = (sp.getDouble(_kDisplayFontSize) ?? 54).clamp(40, 72);
    _thousandSeparator = sp.getBool(_kThousandSeparator) ?? true;
    _decimalPlaces = (sp.getInt(_kDecimalPlaces) ?? 6).clamp(0, 8);
    _maxHistoryItems = (sp.getInt(_kMaxHistoryItems) ?? 50).clamp(10, 200);

    notifyListeners();
  }

  // ─── Resolve ─────────────────────────────────────────────────────────────────
  bool resolveDarkMode(Brightness brightness) {
    switch (_themePreference) {
      case AppThemePreference.system:
        return brightness == Brightness.dark;
      case AppThemePreference.light:
        return false;
      case AppThemePreference.dark:
        return true;
    }
  }

  // ─── Setters ─────────────────────────────────────────────────────────────────
  Future<void> setScientificOnStart(bool v) async {
    if (_scientificOnStart == v) return;
    _scientificOnStart = v;
    await _prefs?.setBool(_kScientificOnStart, v);
    notifyListeners();
  }

  Future<void> setUseDegrees(bool v) async {
    if (_useDegrees == v) return;
    _useDegrees = v;
    await _prefs?.setBool(_kUseDegrees, v);
    notifyListeners();
  }

  Future<void> setScientificNotation(bool v) async {
    if (_scientificNotation == v) return;
    _scientificNotation = v;
    await _prefs?.setBool(_kScientificNotation, v);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool v) async {
    if (_hapticEnabled == v) return;
    _hapticEnabled = v;
    await _prefs?.setBool(_kHapticEnabled, v);
    notifyListeners();
  }

  Future<void> setAutoCopyResult(bool v) async {
    if (_autoCopyResult == v) return;
    _autoCopyResult = v;
    await _prefs?.setBool(_kAutoCopyResult, v);
    notifyListeners();
  }

  Future<void> setConfirmClearHistory(bool v) async {
    if (_confirmClearHistory == v) return;
    _confirmClearHistory = v;
    await _prefs?.setBool(_kConfirmClearHistory, v);
    notifyListeners();
  }

  Future<void> setThemePreference(AppThemePreference v) async {
    if (_themePreference == v) return;
    _themePreference = v;
    await _prefs?.setInt(_kThemePreference, v.index);
    notifyListeners();
  }

  Future<void> setDisplayFontSize(double v) async {
    final nv = v.clamp(40.0, 72.0);
    if (_displayFontSize == nv) return;
    _displayFontSize = nv;
    await _prefs?.setDouble(_kDisplayFontSize, nv);
    notifyListeners();
  }

  Future<void> setThousandSeparator(bool v) async {
    if (_thousandSeparator == v) return;
    _thousandSeparator = v;
    await _prefs?.setBool(_kThousandSeparator, v);
    notifyListeners();
  }

  Future<void> setDecimalPlaces(int v) async {
    final nv = v.clamp(0, 8);
    if (_decimalPlaces == nv) return;
    _decimalPlaces = nv;
    await _prefs?.setInt(_kDecimalPlaces, nv);
    notifyListeners();
  }

  Future<void> setMaxHistoryItems(int v) async {
    final nv = v.clamp(10, 200);
    if (_maxHistoryItems == nv) return;
    _maxHistoryItems = nv;
    await _prefs?.setInt(_kMaxHistoryItems, nv);
    notifyListeners();
  }

  /// Reset semua pengaturan ke default.
  Future<void> resetToDefaults() async {
    await _prefs?.clear();
    await load();
  }
}

enum AppThemePreference { system, light, dark }
