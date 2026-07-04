import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database_helper.dart';
import '../models/calc_snapshot.dart';
import '../models/history_item.dart';
import '../models/operator.dart';
import '../models/scientific_operator.dart';
import '../theme/app_theme.dart';
import '../utils/calc_result.dart';
import '../utils/calculator_engine.dart';
import '../utils/calculator_preferences.dart';
import '../utils/number_formatting.dart';
import '../utils/scientific_calculator.dart';
import '../utils/animations/calc_transition.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/converter_sheet.dart';
import '../widgets/history_sheet.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_display.dart';
import '../widgets/scientific_keypad.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/tools_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _engine = CalculatorEngine();
  final _sciEngine = ScientificCalculator();

  // ── Calculator State ─────────────────────────────────────────────────────────
  String display = '0';
  String history = '';
  double? prevValue;
  Operator? operator;
  bool waitingForOperand = false;
  bool hasError = false;
  ScientificOperator? pendingScientificOp;
  double? memoryValue;
  int _parenDepth = 0; // for parentheses tracking

  // ── UI State ──────────────────────────────────────────────────────────────────
  bool showHistory = false;
  bool showScientific = false;
  bool showConverter = false;
  bool showSettings = false;
  bool showTools = false;

  final List<HistoryItem> _historyLog = [];
  final List<CalcSnapshot> _undoStack = [];
  final _prefs = CalculatorPreferences.instance;
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerOpacity = CurvedAnimation(
      parent: _headerAnimCtrl,
      curve: Curves.easeOut,
    );
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _headerAnimCtrl,
        curve: Curves.easeOutCubic,
      ),
    );
    _headerAnimCtrl.forward();

    _prefs.addListener(_onPrefsChanged);
    _prefs.load().then((_) {
      if (!mounted) return;
      setState(() => showScientific = _prefs.scientificOnStart);
    });

    // Load persistent history from SQLite
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await DatabaseHelper.instance.fetchAllHistory(
      limit: _prefs.maxHistoryItems,
    );
    if (mounted) {
      setState(() {
        _historyLog.clear();
        _historyLog.addAll(items);
      });
    }
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPrefsChanged);
    _headerAnimCtrl.dispose();
    super.dispose();
  }

  bool _isDark(BuildContext context) =>
      _prefs.resolveDarkMode(MediaQuery.platformBrightnessOf(context));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _prefs,
      builder: (context, _) {
        final isDark = _isDark(context);
        final theme = isDark ? AppTheme.dark() : AppTheme.light();
        return Theme(
          data: theme,
          child: _buildScaffold(context, theme, isDark),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, ThemeData theme, bool isDark) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PremiumBackground(
        brightness: isDark ? Brightness.dark : Brightness.light,
        child: Stack(
          children: [
            _buildMainContent(context, theme, isDark),
            if (showHistory)
              HistorySheet(
                items: List.unmodifiable(_historyLog),
                onClose: () => setState(() => showHistory = false),
                onPick: _useHistoryItem,
                onClear: _clearHistory,
              ),
            if (showConverter)
              _ModalOverlay(
                onDismiss: () => setState(() => showConverter = false),
                child: ConverterSheet(
                  onClose: () => setState(() => showConverter = false),
                ),
              ),
            if (showSettings)
              _ModalOverlay(
                onDismiss: () => setState(() => showSettings = false),
                child: SettingsSheet(
                  onClose: () => setState(() => showSettings = false),
                  onThemeChanged: (_) => setState(() {}),
                  onScientificModeChanged: (v) =>
                      setState(() => showScientific = v),
                ),
              ),
            if (showTools)
              _ModalOverlay(
                onDismiss: () => setState(() => showTools = false),
                child: ToolsSheet(
                  onClose: () => setState(() => showTools = false),
                  onApplyResult: (v) {
                    setState(() {
                      display = _engine.formatResultValue(v);
                      hasError = false;
                      waitingForOperand = true;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme, bool isDark) {
    return SafeArea(
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 550;
            final double maxWidth = (showScientific && isWide) ? 800.0 : 460.0;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _headerOpacity,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _buildHeader(context, theme, isDark),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, anim) =>
                                CalcTransition(animation: anim, child: child),
                            child: PremiumDisplay(
                              key: ValueKey('$display-$hasError'),
                              formatted: hasError
                                  ? display
                                  : _engine.displayFormat(display),
                              history: history.isEmpty ? null : history,
                              livePreview: _livePreviewText(),
                              fontSize: _prefs.displayFontSize,
                              hasError: hasError,
                              canUndo: _undoStack.isNotEmpty,
                              onUndo: _handleUndo,
                              onCopy: _copyResult,
                              onPaste: _pasteFromClipboard,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: LayoutBuilder(
                              builder: (context, kConstraints) {
                                return Column(
                                  children: [
                                    Expanded(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 280),
                                        child: showScientific
                                            ? ScientificKeypad(
                                                key: const ValueKey('layout-scientific'),
                                                onClear: _handleClear,
                                                onBackspace: _handleBackspace,
                                                onToggleSign: _handleToggleSign,
                                                onPercent: _handlePercent,
                                                onDigit: _handleDigit,
                                                onDecimal: _handleDecimal,
                                                onOperator: _handleOperator,
                                                onEqual: _handleEqual,
                                                onScientificTap: _handleScientificFunction,
                                                onOpenParen: _handleOpenParen,
                                                onCloseParen: _handleCloseParen,
                                                onMod: _handleMod,
                                              )
                                            : CalculatorKeypad(
                                                key: const ValueKey('layout-standard'),
                                                onClear: _handleClear,
                                                onBackspace: _handleBackspace,
                                                onToggleSign: _handleToggleSign,
                                                onPercent: _handlePercent,
                                                onDigit: _handleDigit,
                                                onDecimal: _handleDecimal,
                                                onOperator: _handleOperator,
                                                onEqual: _handleEqual,
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          // History button
          _HeaderButton(
            icon: Icons.history_rounded,
            tooltip: 'Riwayat',
            isActive: showHistory,
            badge: _historyLog.isNotEmpty ? '${_historyLog.length}' : null,
            isDark: isDark,
            onTap: () => setState(() => showHistory = true),
          ),

          const SizedBox(width: 8),

          // Title & mode chip
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal,
                      AppTheme.accentGold,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Calculator 2026',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                _ModeChip(
                  label: showScientific ? 'Scientific' : 'Standard',
                  isScientific: showScientific,
                  isDark: isDark,
                  onTap: () => setState(() => showScientific = !showScientific),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Menu
          _buildMenuButton(context, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, ThemeData theme, bool isDark) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.primaryTealDark.withValues(alpha: 0.1)
                : AppTheme.primaryTeal.withValues(alpha: 0.12),
          ),
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          size: 20,
          color: theme.colorScheme.onSurface,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppTheme.darkBg2 : AppTheme.lightSurface,
      elevation: 8,
      onSelected: (value) {
        switch (value) {
          case 'copy':
            _copyResult();
          case 'percent':
            _handlePercent();
          case 'tools':
            setState(() => showTools = true);
          case 'converter':
            setState(() => showConverter = true);
          case 'settings':
            setState(() => showSettings = true);
          case 'theme':
            _cycleTheme();
        }
      },
      itemBuilder: (context) => [
        _menuItem('copy', Icons.copy_rounded, 'Salin hasil'),
        _menuItem('percent', Icons.percent_rounded, 'Persen (%)'),
        const PopupMenuDivider(),
        _menuItem('tools', Icons.handyman_rounded, 'Alat praktis'),
        _menuItem('converter', Icons.swap_horiz_rounded, 'Konverter satuan'),
        const PopupMenuDivider(),
        _menuItem('settings', Icons.settings_outlined, 'Pengaturan'),
        _menuItem(
          'theme',
          _isDark(context) ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
          'Tema: ${_themeLabel()}',
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  // ── Live Preview ─────────────────────────────────────────────────────────────
  String? _livePreviewText() {
    if (hasError || waitingForOperand || operator == null || prevValue == null) {
      return null;
    }
    final input = _engine.parseDisplay(display);
    final r = _engine.preview(prevValue, input, operator);
    if (r == null || !r.isOk) return null;
    return _engine.displayFormatFromDouble(r.value!);
  }

  // ── Undo ─────────────────────────────────────────────────────────────────────
  void _pushUndo() {
    _undoStack.add(CalcSnapshot(
      display: display,
      history: history,
      prevValue: prevValue,
      operator: operator,
      waitingForOperand: waitingForOperand,
      hasError: hasError,
    ));
    if (_undoStack.length > 30) _undoStack.removeAt(0);
  }

  void _handleUndo() {
    if (_undoStack.isEmpty) return;
    final s = _undoStack.removeLast();
    setState(() {
      display = s.display;
      history = s.history;
      prevValue = s.prevValue;
      operator = s.operator;
      waitingForOperand = s.waitingForOperand;
      hasError = s.hasError;
    });
    _showSnack('↩ Dibatalkan');
  }

  // ── History ───────────────────────────────────────────────────────────────────
  Future<void> _addHistoryItem(HistoryItem item) async {
    await DatabaseHelper.instance.insertHistory(item);
    _historyLog.insert(0, item);
    final max = _prefs.maxHistoryItems;
    if (_historyLog.length > max) {
      _historyLog.removeRange(max, _historyLog.length);
    }
  }

  void _useHistoryItem(HistoryItem item) {
    setState(() {
      display = item.result.replaceAll(',', '');
      history = item.calculation;
      waitingForOperand = true;
      showHistory = false;
      prevValue = null;
      operator = null;
    });
  }

  Future<void> _clearHistory() async {
    if (_prefs.confirmClearHistory) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus riwayat?'),
          content: const Text(
            'Semua riwayat perhitungan akan dihapus permanen dari database.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await DatabaseHelper.instance.deleteAllHistory();
    setState(() => _historyLog.clear());
    _showSnack('🗑️ Riwayat dihapus');
  }

  // ── Clipboard ─────────────────────────────────────────────────────────────────
  Future<void> _copyResult() async {
    final text = _engine.displayFormat(display);
    await Clipboard.setData(ClipboardData(text: text));
    _showSnack('📋 Disalin: $text');
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final raw = data?.text?.replaceAll(',', '').trim();
    if (raw == null || raw.isEmpty) {
      _showSnack('Clipboard kosong');
      return;
    }
    final value = double.tryParse(raw);
    if (value == null) {
      _showSnack('Angka tidak valid');
      return;
    }
    setState(() {
      display = raw;
      waitingForOperand = false;
    });
    _showSnack('📌 Ditempel: $raw');
  }

  // ── Theme ─────────────────────────────────────────────────────────────────────
  String _themeLabel() => switch (_prefs.themePreference) {
        AppThemePreference.system => 'Sistem',
        AppThemePreference.light => 'Terang',
        AppThemePreference.dark => 'Gelap',
      };

  Future<void> _cycleTheme() async {
    final next = switch (_prefs.themePreference) {
      AppThemePreference.system => AppThemePreference.light,
      AppThemePreference.light => AppThemePreference.dark,
      AppThemePreference.dark => AppThemePreference.system,
    };
    await _prefs.setThemePreference(next);
    setState(() {});
  }


  // ── Calculator Operations ─────────────────────────────────────────────────────
  void _handleClear() {
    _pushUndo();
    setState(() {
      display = '0';
      history = '';
      prevValue = null;
      operator = null;
      waitingForOperand = false;
      hasError = false;
      pendingScientificOp = null;
      _parenDepth = 0;
    });
  }

  void _handleBackspace() {
    if (waitingForOperand || hasError) return;
    setState(() {
      if (display.length <= 1 || display == '-0') {
        display = '0';
      } else {
        display = display.substring(0, display.length - 1);
        if (display.isEmpty || display == '-') display = '0';
      }
    });
  }

  void _handleDigit(String digit) {
    _pushUndo();
    setState(() {
      if (hasError) {
        hasError = false;
        display = digit;
        waitingForOperand = false;
        return;
      }
      if (waitingForOperand) {
        display = digit;
        waitingForOperand = false;
      } else {
        if (display.length >= 15) return; // max digits guard
        display = display == '0' ? digit : '$display$digit';
      }
    });
  }

  void _handleDecimal() {
    setState(() {
      if (waitingForOperand) {
        display = '0.';
        waitingForOperand = false;
        return;
      }
      if (!display.contains('.')) {
        display = '$display.';
      }
    });
  }

  void _handleToggleSign() {
    setState(() {
      final v = _engine.parseDisplay(display) * -1;
      display = _engine.formatResultValue(v);
    });
  }

  void _handlePercent() {
    setState(() {
      final v = _engine.parseDisplay(display);
      display = _engine.formatResultValue(v / 100);
    });
  }

  void _handleOpenParen() {
    setState(() {
      _parenDepth++;
      history = '$history(';
      _showSnack('( Buka kurung');
    });
  }

  void _handleCloseParen() {
    if (_parenDepth <= 0) return;
    setState(() {
      _parenDepth--;
      history = '$history)';
      _showSnack(') Tutup kurung');
    });
  }

  void _handleMod() {
    if (hasError) return;
    _pushUndo();
    final inputValue = _engine.parseDisplay(display);
    setState(() {
      if (prevValue == null) {
        prevValue = inputValue;
        history = '${_engine.displayFormatFromDouble(inputValue)} mod';
      } else if (operator != null) {
        final result = _engine.calculate(prevValue!, inputValue, operator!);
        if (!_applyResultInPlace(result)) return;
        prevValue = result.value;
        history = '${_engine.displayFormatFromDouble(result.value!)} mod';
      } else {
        prevValue = inputValue;
        history = '${_engine.displayFormatFromDouble(inputValue)} mod';
      }
      // mod is like special operator
      waitingForOperand = true;
      // Apply modulo immediately if we have prevValue
      if (prevValue != null) {
        final pv = prevValue!;
        final modResult = pv % inputValue;
        display = _engine.formatResultValue(modResult);
        prevValue = null;
        history = '${_engine.displayFormatFromDouble(pv)} mod ${_engine.displayFormatFromDouble(inputValue)} = ${_engine.formatResultValue(modResult)}';
        waitingForOperand = true;
      }
    });
  }

  void _handleOperator(Operator nextOp) {
    if (hasError) return;
    _pushUndo();
    final inputValue = _engine.parseDisplay(display);

    setState(() {
      if (prevValue == null) {
        prevValue = inputValue;
        history =
            '${_engine.displayFormatFromDouble(inputValue)} ${nextOp.symbol}';
      } else if (operator != null) {
        final result = _engine.calculate(prevValue!, inputValue, operator!);
        if (!_applyResultInPlace(result)) return;
        prevValue = result.value;
        history =
            '${_engine.displayFormatFromDouble(result.value!)} ${nextOp.symbol}';
      }
      waitingForOperand = true;
      operator = nextOp;
    });
  }

  bool _applyResultInPlace(CalcResult result) {
    if (result.isError) {
      display = result.errorMessage!;
      hasError = true;
      waitingForOperand = true;
      return false;
    }
    display = _engine.formatResultValue(result.value!);
    hasError = false;
    return true;
  }

  Future<void> _handleEqual() async {
    if (hasError) return;
    _pushUndo();
    final inputValue = _engine.parseDisplay(display);

    // Scientific power operation
    if (pendingScientificOp == ScientificOperator.power && prevValue != null) {
      final result = _sciEngine.power(prevValue!, inputValue);
      final calcStr = '${prevValue!} xʸ $inputValue';
      final now = DateTime.now();
      final item = HistoryItem(
        id: now.microsecondsSinceEpoch.toString(),
        calculation: calcStr,
        result: formatDisplayFromNum(result),
        timestamp: now,
      );
      setState(() {
        display = _engine.formatResultValue(result);
        history = calcStr;
        prevValue = null;
        operator = null;
        pendingScientificOp = null;
        waitingForOperand = true;
      });
      await _addHistoryItem(item);
      if (_prefs.autoCopyResult) await _copyResult();
      return;
    }

    // Regular operation
    if (operator != null && prevValue != null) {
      final result = _engine.calculate(prevValue!, inputValue, operator!);
      if (!_applyResultInPlace(result)) {
        setState(() {});
        return;
      }
      final calcStr =
          '${_engine.displayFormatFromDouble(prevValue!)} ${operator!.symbol} ${_engine.displayFormatFromDouble(inputValue)}';

      final now = DateTime.now();
      final item = HistoryItem(
        id: now.microsecondsSinceEpoch.toString(),
        calculation: calcStr,
        result: formatDisplayFromNum(result.value!),
        timestamp: now,
      );

      setState(() {
        history = calcStr;
        prevValue = null;
        operator = null;
        waitingForOperand = true;
      });
      await _addHistoryItem(item);
      if (_prefs.autoCopyResult) await _copyResult();
    }
  }

  // ── Scientific Functions ──────────────────────────────────────────────────────
  void _handleScientificFunction(ScientificOperator op) {
    final input = _engine.parseDisplay(display);
    final useDeg = _prefs.useDegrees;

    if (op == ScientificOperator.power) {
      setState(() {
        prevValue = input;
        pendingScientificOp = op;
        history = '$input xʸ ';
        waitingForOperand = true;
        display = '0';
      });
      return;
    }

    double result;
    try {
      result = switch (op) {
        ScientificOperator.sine => _sciEngine.sine(
            useDeg ? _sciEngine.degreesToRadians(input) : input),
        ScientificOperator.cosine => _sciEngine.cosine(
            useDeg ? _sciEngine.degreesToRadians(input) : input),
        ScientificOperator.tangent => _sciEngine.tangent(
            useDeg ? _sciEngine.degreesToRadians(input) : input),
        ScientificOperator.arcsin => useDeg
            ? _sciEngine.radiansToDegrees(_sciEngine.arcsine(input))
            : _sciEngine.arcsine(input),
        ScientificOperator.arccos => useDeg
            ? _sciEngine.radiansToDegrees(_sciEngine.arccosine(input))
            : _sciEngine.arccosine(input),
        ScientificOperator.arctan => useDeg
            ? _sciEngine.radiansToDegrees(_sciEngine.arctangent(input))
            : _sciEngine.arctangent(input),
        ScientificOperator.log => _sciEngine.naturalLog(input),
        ScientificOperator.log10 => _sciEngine.log10(input),
        ScientificOperator.log2 => _sciEngine.log2(input),
        ScientificOperator.sqrt => _sciEngine.squareRoot(input),
        ScientificOperator.cbrt => _sciEngine.cubeRoot(input),
        ScientificOperator.factorial => _sciEngine.factorial(input),
        ScientificOperator.reciprocal => _sciEngine.reciprocal(input),
        ScientificOperator.pi => _sciEngine.pi,
        ScientificOperator.e => _sciEngine.e,
        ScientificOperator.exp => _sciEngine.exponential(input),
        ScientificOperator.power => input, // handled above
      };
    } catch (_) {
      setState(() {
        display = 'Error';
        hasError = true;
      });
      return;
    }

    if (result.isNaN || result.isInfinite) {
      setState(() {
        display = result.isNaN ? 'Tidak valid' : 'Tidak terbatas';
        hasError = true;
      });
      return;
    }

    setState(() {
      display = _engine.formatResultValue(result);
      history = '${op.displayName}($input)';
      waitingForOperand = true;
    });
  }

  // ── Snackbar ──────────────────────────────────────────────────────────────────
  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// ─── Modal Overlay ────────────────────────────────────────────────────────────
class _ModalOverlay extends StatelessWidget {
  final VoidCallback onDismiss;
  final Widget child;

  const _ModalOverlay({required this.onDismiss, required this.child});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ─── Header Button ────────────────────────────────────────────────────────────
class _HeaderButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isActive;
  final bool isDark;
  final String? badge;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    required this.isDark,
    this.isActive = false,
    this.badge,
  });

  @override
  State<_HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<_HeaderButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isActive = widget.isActive;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (CalculatorPreferences.instance.hapticEnabled) {
            HapticFeedback.lightImpact();
          }
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 42,
          height: 42,
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryTeal,
                      const Color(0xFF0E7490),
                    ],
                  )
                : null,
            color: isActive
                ? null
                : isDark
                    ? Colors.white.withValues(alpha: _pressed ? 0.12 : 0.06)
                    : Colors.black.withValues(alpha: _pressed ? 0.1 : 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? Colors.transparent
                  : isDark
                      ? AppTheme.primaryTealDark.withValues(alpha: 0.1)
                      : AppTheme.primaryTeal.withValues(alpha: 0.12),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: isActive
                    ? Colors.white
                    : isDark
                        ? AppTheme.primaryTealDark
                        : AppTheme.primaryTeal,
              ),
              if (widget.badge != null)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      widget.badge!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mode Chip ────────────────────────────────────────────────────────────────
class _ModeChip extends StatelessWidget {
  final String label;
  final bool isScientific;
  final bool isDark;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.isScientific,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: isScientific
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryTeal.withValues(alpha: 0.25),
                        AppTheme.accentGold.withValues(alpha: 0.15),
                      ],
                    )
                  : null,
              color: isScientific
                  ? null
                  : isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isScientific
                    ? (isDark
                        ? AppTheme.primaryTealDark.withValues(alpha: 0.45)
                        : AppTheme.primaryTeal.withValues(alpha: 0.4))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.12)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isScientific ? Icons.science_outlined : Icons.calculate_outlined,
                  size: 11,
                  color: isScientific
                      ? (isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.black.withValues(alpha: 0.5)),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isScientific
                        ? (isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.5)),
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
