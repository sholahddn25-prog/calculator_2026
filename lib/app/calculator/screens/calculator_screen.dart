import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/history_item.dart';
import '../models/operator.dart';
import '../models/scientific_operator.dart';
import '../theme/app_theme.dart';
import '../models/calc_snapshot.dart';
import '../utils/calc_result.dart';
import '../utils/calculator_engine.dart';
import '../utils/number_formatting.dart';
import '../utils/animations/calc_transition.dart';
import '../utils/scientific_calculator.dart';
import '../utils/calculator_preferences.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/memory_bar.dart';
import '../widgets/history_sheet.dart';
import '../widgets/converter_sheet.dart';
import '../widgets/scientific_panel.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_display.dart';
import '../widgets/tools_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _engine = CalculatorEngine();
  final _scientificEngine = ScientificCalculator();

  String display = '0';
  String history = '';
  double? prevValue;
  Operator? operator;
  bool waitingForOperand = false;

  bool showHistory = false;
  bool showScientific = false;
  bool showConverter = false;
  bool showSettings = false;
  bool showTools = false;
  bool hasError = false;
  ScientificOperator? pendingScientificOp;
  double? memoryValue;

  final List<HistoryItem> historyLog = [];
  final List<CalcSnapshot> _undoStack = [];
  final _prefs = CalculatorPreferences.instance;
  late AnimationController _headerAnimationController;

  ThemeData get _lightTheme => AppTheme.light();
  ThemeData get _darkTheme => AppTheme.dark();

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _headerAnimationController.forward();
    _prefs.addListener(_onPreferencesChanged);
    _prefs.load().then((_) {
      if (!mounted) return;
      setState(() => showScientific = _prefs.scientificOnStart);
    });
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPreferencesChanged);
    _headerAnimationController.dispose();
    super.dispose();
  }

  bool _isDarkMode(BuildContext context) =>
      _prefs.resolveDarkMode(MediaQuery.platformBrightnessOf(context));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _prefs,
      builder: (context, _) {
        final theme = _isDarkMode(context) ? _darkTheme : _lightTheme;
        return _buildThemedApp(context, theme);
      },
    );
  }

  Widget _buildThemedApp(BuildContext context, ThemeData theme) {
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: PremiumBackground(
          brightness: theme.brightness,
          child: Stack(
            children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      // Animated header
                      SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, -0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _headerAnimationController,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                            parent: _headerAnimationController,
                            curve: Curves.easeOutCubic,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                            child: Row(
                              children: [
                                _HeaderIconButton(
                                  icon: Icons.history_rounded,
                                  tooltip: 'Riwayat',
                                  isActive: showHistory,
                                  onPressed: () =>
                                      setState(() => showHistory = true),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                          colors: [
                                            theme.colorScheme.primary,
                                            AppTheme.accentGold,
                                          ],
                                        ).createShader(bounds),
                                        child: Text(
                                          'Calculator 2026',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _ModeChip(
                                        label: showScientific
                                            ? 'Scientific'
                                            : 'Standard',
                                        isScientific: showScientific,
                                      ),
                                    ],
                                  ),
                                ),
                                _HeaderIconButton(
                                  icon: Icons.calculate_rounded,
                                  tooltip: 'Scientific',
                                  isActive: showScientific,
                                  onPressed: () => setState(
                                    () => showScientific = !showScientific,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_horiz_rounded,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
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
                                        _cycleThemePreference();
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'copy',
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.copy_rounded,
                                        ),
                                        title: const Text('Salin hasil'),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'percent',
                                      child: ListTile(
                                        leading: Icon(Icons.percent_rounded),
                                        title: Text('Persen (%)'),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'tools',
                                      child: ListTile(
                                        leading: Icon(Icons.handyman_rounded),
                                        title: Text('Alat praktis'),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'converter',
                                      child: ListTile(
                                        leading: Icon(Icons.swap_horiz_rounded),
                                        title: Text('Konverter'),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'settings',
                                      child: ListTile(
                                        leading:
                                            Icon(Icons.settings_outlined),
                                        title: Text('Pengaturan'),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'theme',
                                      child: ListTile(
                                        leading: Icon(
                                          _isDarkMode(context)
                                              ? Icons.wb_sunny_outlined
                                              : Icons.dark_mode_outlined,
                                        ),
                                        title: Text(
                                          'Tema: ${_themeMenuLabel()}',
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Content area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, anim) {
                                  return CalcTransition(
                                    animation: anim,
                                    child: child,
                                  );
                                },
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
                              const SizedBox(height: 12),

                              // Keypad area
                              Flexible(
                                child: showScientific
                                    ? ScientificPanel(
                                        onScientificTap:
                                            _handleScientificFunction,
                                      )
                                    : Column(
                                        children: [
                                          MemoryBar(
                                            hasMemory: memoryValue != null,
                                            onClear: _memoryClear,
                                            onRecall: _memoryRecall,
                                            onAdd: _memoryAdd,
                                            onSubtract: _memorySubtract,
                                          ),
                                          Expanded(
                                            child: CalculatorKeypad(
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
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (showHistory)
              HistorySheet(
                items: List.unmodifiable(historyLog),
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
      ),
    );
  }

  String? _livePreviewText() {
    if (hasError || waitingForOperand || operator == null || prevValue == null) {
      return null;
    }
    final input = _engine.parseDisplay(display);
    final r = _engine.preview(prevValue, input, operator);
    if (r == null || !r.isOk) return null;
    return _engine.displayFormatFromDouble(r.value!);
  }

  void _pushUndo() {
    _undoStack.add(
      CalcSnapshot(
        display: display,
        history: history,
        prevValue: prevValue,
        operator: operator,
        waitingForOperand: waitingForOperand,
        hasError: hasError,
      ),
    );
    if (_undoStack.length > 24) {
      _undoStack.removeAt(0);
    }
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
    _showSnack('Dibatalkan');
  }


  String _themeMenuLabel() {
    switch (_prefs.themePreference) {
      case AppThemePreference.system:
        return 'Sistem';
      case AppThemePreference.light:
        return 'Terang';
      case AppThemePreference.dark:
        return 'Gelap';
    }
  }

  Future<void> _cycleThemePreference() async {
    final next = switch (_prefs.themePreference) {
      AppThemePreference.system => AppThemePreference.light,
      AppThemePreference.light => AppThemePreference.dark,
      AppThemePreference.dark => AppThemePreference.system,
    };
    await _prefs.setThemePreference(next);
    setState(() {});
  }

  Future<void> _clearHistory() async {
    if (_prefs.confirmClearHistory) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus riwayat?'),
          content: const Text(
            'Semua perhitungan tersimpan akan dihapus permanen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => historyLog.clear());
    _showSnack('Riwayat dihapus');
  }

  void _addHistoryItem(HistoryItem item) {
    historyLog.insert(0, item);
    final max = _prefs.maxHistoryItems;
    if (historyLog.length > max) {
      historyLog.removeRange(max, historyLog.length);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _copyResult() async {
    final text = _engine.displayFormat(display);
    await Clipboard.setData(ClipboardData(text: text));
    _showSnack('Disalin: $text');
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
      display = value.toString();
      waitingForOperand = false;
    });
    _showSnack('Ditempel');
  }

  void _handleBackspace() {
    setState(() {
      if (waitingForOperand) return;
      if (display.length <= 1 || display == '-0') {
        display = '0';
      } else {
        display = display.substring(0, display.length - 1);
        if (display.isEmpty || display == '-') display = '0';
      }
    });
  }

  void _memoryClear() {
    setState(() => memoryValue = null);
    _showSnack('Memori dihapus');
  }

  void _memoryRecall() {
    if (memoryValue == null) return;
    setState(() {
      display = memoryValue!.toString();
      waitingForOperand = true;
    });
  }

  void _memoryAdd() {
    final v = _engine.parseDisplay(display);
    setState(() => memoryValue = (memoryValue ?? 0) + v);
    _showSnack('Disimpan ke memori (M+)');
  }

  void _memorySubtract() {
    final v = _engine.parseDisplay(display);
    setState(() => memoryValue = (memoryValue ?? 0) - v);
    _showSnack('Disimpan ke memori (M−)');
  }

  void _handleClear() {
    _pushUndo();
    setState(() {
      display = '0';
      history = '';
      prevValue = null;
      operator = null;
      waitingForOperand = false;
      hasError = false;
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
      display = v.toString();
    });
  }

  void _handleOperator(Operator nextOperator) {
    if (hasError) return;
    _pushUndo();
    final inputValue = _engine.parseDisplay(display);

    setState(() {
      if (prevValue == null) {
        prevValue = inputValue;
        history = '${_engine.displayFormatFromDouble(inputValue)} ${nextOperator.symbol}';
      } else if (operator != null) {
        final result = _engine.calculate(prevValue!, inputValue, operator!);
        if (!_applyResultInPlace(result)) return;
        prevValue = result.value;
        history =
            '${_engine.displayFormatFromDouble(result.value!)} ${nextOperator.symbol}';
      }

      waitingForOperand = true;
      operator = nextOperator;
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

  void _handleEqual() {
    if (hasError) return;
    _pushUndo();
    final inputValue = _engine.parseDisplay(display);

    setState(() {
      // Handle pending scientific operation (like xʸ)
      if (pendingScientificOp == ScientificOperator.power &&
          prevValue != null) {
        final result = _scientificEngine.power(prevValue!, inputValue);
        final calcString = '$prevValue xʸ $inputValue';

        display = result.toString();
        history = calcString;

        final now = DateTime.now();
        final newItem = HistoryItem(
          id: now.microsecondsSinceEpoch.toString(),
          calculation: calcString,
          result: formatDisplayFromNum(result),
          timestamp: now,
        );

        _addHistoryItem(newItem);

        prevValue = null;
        operator = null;
        pendingScientificOp = null;
        waitingForOperand = true;
        if (_prefs.autoCopyResult) _copyResult();
        return;
      }

      // Handle regular operation
      if (operator != null && prevValue != null) {
        final result = _engine.calculate(prevValue!, inputValue, operator!);
        if (!_applyResultInPlace(result)) return;
        final calcString =
            '${_engine.displayFormatFromDouble(prevValue!)} ${operator!.symbol} ${_engine.displayFormatFromDouble(inputValue)}';

        history = calcString;

        final now = DateTime.now();
        final newItem = HistoryItem(
          id: now.microsecondsSinceEpoch.toString(),
          calculation: calcString,
          result: formatDisplayFromNum(result.value!),
          timestamp: now,
        );

        _addHistoryItem(newItem);

        prevValue = null;
        operator = null;
        waitingForOperand = true;
        if (_prefs.autoCopyResult) _copyResult();
      }
    });
  }

  void _handlePercent() {
    setState(() {
      final v = _engine.parseDisplay(display);
      display = (v / 100).toString();
    });
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

  void _handleScientificFunction(ScientificOperator op) {
    final inputValue = _scientificEngine.parseDisplay(display);
    double result = 0;

    final useDeg = _prefs.useDegrees;

    switch (op) {
      case ScientificOperator.sine:
        result = _scientificEngine.sine(
          useDeg
              ? _scientificEngine.degreesToRadians(inputValue)
              : inputValue,
        );
        break;
      case ScientificOperator.cosine:
        result = _scientificEngine.cosine(
          useDeg
              ? _scientificEngine.degreesToRadians(inputValue)
              : inputValue,
        );
        break;
      case ScientificOperator.tangent:
        result = _scientificEngine.tangent(
          useDeg
              ? _scientificEngine.degreesToRadians(inputValue)
              : inputValue,
        );
        break;
      case ScientificOperator.arcsin:
        result = useDeg
            ? _scientificEngine.radiansToDegrees(
                _scientificEngine.arcsine(inputValue),
              )
            : _scientificEngine.arcsine(inputValue);
        break;
      case ScientificOperator.arccos:
        result = useDeg
            ? _scientificEngine.radiansToDegrees(
                _scientificEngine.arccosine(inputValue),
              )
            : _scientificEngine.arccosine(inputValue);
        break;
      case ScientificOperator.arctan:
        result = useDeg
            ? _scientificEngine.radiansToDegrees(
                _scientificEngine.arctangent(inputValue),
              )
            : _scientificEngine.arctangent(inputValue);
        break;
      case ScientificOperator.log:
        result = _scientificEngine.naturalLog(inputValue);
        break;
      case ScientificOperator.log10:
        result = _scientificEngine.log10(inputValue);
        break;
      case ScientificOperator.log2:
        result = _scientificEngine.log2(inputValue);
        break;
      case ScientificOperator.sqrt:
        result = _scientificEngine.squareRoot(inputValue);
        break;
      case ScientificOperator.cbrt:
        result = _scientificEngine.cubeRoot(inputValue);
        break;
      case ScientificOperator.factorial:
        result = _scientificEngine.factorial(inputValue);
        break;
      case ScientificOperator.reciprocal:
        result = _scientificEngine.reciprocal(inputValue);
        break;
      case ScientificOperator.pi:
        result = _scientificEngine.pi;
        break;
      case ScientificOperator.e:
        result = _scientificEngine.e;
        break;
      case ScientificOperator.power:
        // For power operation, we'll wait for second operand
        prevValue = inputValue;
        pendingScientificOp = op;
        history = '$inputValue xʸ ';
        waitingForOperand = true;
        setState(() => display = '0');
        return;
      case ScientificOperator.exp:
        result = _scientificEngine.exponential(inputValue);
        break;
    }

    setState(() {
      display = result.toString();
      history = '${op.displayName}($inputValue)';
      waitingForOperand = true;
    });
  }

  double parseDisplay(String s) => _engine.parseDisplay(s);
}

extension _ScientificCalculatorExtension on ScientificCalculator {
  double parseDisplay(String s) =>
      double.tryParse(s.replaceAll(',', '')) ?? 0.0;
}

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
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isActive;

  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            if (CalculatorPreferences.instance.hapticEnabled) {
              HapticFeedback.lightImpact();
            }
            onPressed();
          },
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isScientific;

  const _ModeChip({required this.label, required this.isScientific});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isScientific
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isScientific
              ? theme.colorScheme.primary.withValues(alpha: 0.35)
              : theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isScientific
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
