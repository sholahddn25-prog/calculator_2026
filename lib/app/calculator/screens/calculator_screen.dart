import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../models/operator.dart';
import '../models/scientific_operator.dart';
import '../theme/app_theme.dart';
import '../utils/calculator_engine.dart';
import '../utils/number_formatting.dart';
import '../utils/animations/calc_transition.dart';
import '../utils/scientific_calculator.dart';
import '../utils/sound_manager.dart';
import '../widgets/calc_key_button.dart';
import '../widgets/history_sheet.dart';
import '../widgets/converter_sheet.dart';
import '../widgets/scientific_panel.dart';
import '../widgets/settings_sheet.dart';

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

  bool isDarkMode = false;
  bool showHistory = false;
  bool showScientific = false;
  bool showConverter = false;
  bool showSettings = false;
  ScientificOperator? pendingScientificOp;

  final List<HistoryItem> historyLog = [];
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
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = isDarkMode ? _darkTheme : _lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppTheme.backgroundGradient(theme.brightness),
                  stops: const [0.0, 0.35, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -60,
              child: _GlowOrb(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                size: 220,
              ),
            ),
            Positioned(
              bottom: 120,
              left: -40,
              child: _GlowOrb(
                color: theme.colorScheme.secondary.withValues(alpha: 0.08),
                size: 160,
              ),
            ),
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
                                      Text(
                                        'Calculator',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
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
                                      case 'converter':
                                        setState(() => showConverter = true);
                                      case 'settings':
                                        setState(() => showSettings = true);
                                      case 'theme':
                                        setState(
                                          () => isDarkMode = !isDarkMode,
                                        );
                                    }
                                  },
                                  itemBuilder: (context) => [
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
                                          isDarkMode
                                              ? Icons.wb_sunny_outlined
                                              : Icons.dark_mode_outlined,
                                        ),
                                        title: Text(
                                          isDarkMode
                                              ? 'Mode terang'
                                              : 'Mode gelap',
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
                              // History display
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, anim) {
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(0.1, 0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: anim,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: history.isEmpty
                                    ? const SizedBox.shrink()
                                    : Text(
                                        history,
                                        key: ValueKey(history),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              // Main display
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
                                child: Container(
                                  key: ValueKey(display),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  decoration: AppTheme.displayCardDecoration(
                                    context,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _engine.displayFormat(display),
                                      textAlign: TextAlign.right,
                                      style: theme.textTheme.displayLarge
                                          ?.copyWith(
                                        fontSize: 52,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: -1.5,
                                        height: 1.05,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
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
                                          // Keypad 4x4 (dibuat lebih rapi via mapping index)
                                          Expanded(
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    mainAxisSpacing: 8,
                                                    crossAxisSpacing: 8,
                                                    childAspectRatio: 1.05,
                                                  ),
                                              itemCount: 16,
                                              itemBuilder: (context, index) {
                                                final keyMap = <int, Widget>{
                                                  0: CalcKeyButton(
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .utility,
                                                    label: 'AC',
                                                    labelColor:
                                                        Colors.redAccent,
                                                    onTap: _handleClear,
                                                  ),
                                                  1: CalcKeyButton(
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .utility,
                                                    label: '+/-',
                                                    onTap: _handleToggleSign,
                                                  ),
                                                  2: CalcKeyButton(
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .utility,
                                                    label: '%',
                                                    onTap: _handlePercent,
                                                  ),
                                                  3: CalcKeyButton(
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .operator,
                                                    label: '÷',
                                                    onTap: () =>
                                                        _handleOperator(
                                                          Operator.divide,
                                                        ),
                                                  ),
                                                  4: CalcKeyButton(
                                                    label: '7',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('7'),
                                                  ),
                                                  5: CalcKeyButton(
                                                    label: '8',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('8'),
                                                  ),
                                                  6: CalcKeyButton(
                                                    label: '9',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('9'),
                                                  ),
                                                  7: CalcKeyButton(
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .operator,
                                                    label: '×',
                                                    onTap: () =>
                                                        _handleOperator(
                                                          Operator.multiply,
                                                        ),
                                                  ),
                                                  8: CalcKeyButton(
                                                    label: '4',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('4'),
                                                  ),
                                                  9: CalcKeyButton(
                                                    label: '5',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('5'),
                                                  ),
                                                  10: CalcKeyButton(
                                                    label: '6',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('6'),
                                                  ),
                                                  11: CalcKeyButton(
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .operator,
                                                    icon: const Icon(
                                                      Icons.remove,
                                                      size: 26,
                                                    ),
                                                    onTap: () =>
                                                        _handleOperator(
                                                          Operator.subtract,
                                                        ),
                                                  ),
                                                  12: CalcKeyButton(
                                                    label: '1',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('1'),
                                                  ),
                                                  13: CalcKeyButton(
                                                    label: '2',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('2'),
                                                  ),
                                                  14: CalcKeyButton(
                                                    label: '3',
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .number,
                                                    onTap: () =>
                                                        _handleDigit('3'),
                                                  ),
                                                  15: CalcKeyButton(
                                                    variant:
                                                        CalcKeyButtonVariant
                                                            .operator,
                                                    icon: const Icon(
                                                      Icons.add,
                                                      size: 26,
                                                    ),
                                                    onTap: () =>
                                                        _handleOperator(
                                                          Operator.add,
                                                        ),
                                                  ),
                                                };

                                                return keyMap[index] ??
                                                    const SizedBox.shrink();
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: CalcKeyButton(
                                                  label: '0',
                                                  variant: CalcKeyButtonVariant
                                                      .number,
                                                  onTap: () =>
                                                      _handleDigit('0'),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: CalcKeyButton(
                                                  label: '.',
                                                  variant: CalcKeyButtonVariant
                                                      .number,
                                                  onTap: _handleDecimal,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: CalcKeyButton(
                                                  variant: CalcKeyButtonVariant
                                                      .primary,
                                                  label: '=',
                                                  onTap: _handleEqual,
                                                ),
                                              ),
                                            ],
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
                onClear: () => setState(() => historyLog.clear()),
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
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleClear() {
    setState(() {
      display = '0';
      history = '';
      prevValue = null;
      operator = null;
      waitingForOperand = false;
    });
  }

  void _handleDigit(String digit) {
    setState(() {
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
    final inputValue = _engine.parseDisplay(display);

    setState(() {
      if (prevValue == null) {
        prevValue = inputValue;
        history = '$inputValue ${nextOperator.symbol}';
      } else if (operator != null) {
        final result = _engine.calculate(prevValue!, inputValue, operator!);
        prevValue = result;
        display = result.toString();
        history = '$result ${nextOperator.symbol}';
      }

      waitingForOperand = true;
      operator = nextOperator;
    });
  }

  void _handleEqual() {
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

        historyLog.insert(0, newItem);
        if (historyLog.length > 50) {
          historyLog.removeRange(50, historyLog.length);
        }

        prevValue = null;
        operator = null;
        pendingScientificOp = null;
        waitingForOperand = true;
        return;
      }

      // Handle regular operation
      if (operator != null && prevValue != null) {
        final result = _engine.calculate(prevValue!, inputValue, operator!);
        final calcString = '$prevValue ${operator!.symbol} $inputValue';

        display = result.toString();
        history = calcString;

        final now = DateTime.now();
        final newItem = HistoryItem(
          id: now.microsecondsSinceEpoch.toString(),
          calculation: calcString,
          result: formatDisplayFromNum(result),
          timestamp: now,
        );

        historyLog.insert(0, newItem);
        if (historyLog.length > 50) {
          historyLog.removeRange(50, historyLog.length);
        }

        prevValue = null;
        operator = null;
        waitingForOperand = true;
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

    switch (op) {
      case ScientificOperator.sine:
        result = _scientificEngine.sine(
          _scientificEngine.degreesToRadians(inputValue),
        );
        break;
      case ScientificOperator.cosine:
        result = _scientificEngine.cosine(
          _scientificEngine.degreesToRadians(inputValue),
        );
        break;
      case ScientificOperator.tangent:
        result = _scientificEngine.tangent(
          _scientificEngine.degreesToRadians(inputValue),
        );
        break;
      case ScientificOperator.arcsin:
        result = _scientificEngine.radiansToDegrees(
          _scientificEngine.arcsine(inputValue),
        );
        break;
      case ScientificOperator.arccos:
        result = _scientificEngine.radiansToDegrees(
          _scientificEngine.arccosine(inputValue),
        );
        break;
      case ScientificOperator.arctan:
        result = _scientificEngine.radiansToDegrees(
          _scientificEngine.arctangent(inputValue),
        );
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

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
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
            SoundManager().playTapSound();
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
