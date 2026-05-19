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
    final isDark = theme.brightness == Brightness.dark;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Animated background gradient
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0E0F12),
                          const Color(0xFF1A1B22),
                          const Color(0xFF0E0F12),
                        ]
                      : [
                          const Color(0xFFF5F5F7),
                          const Color(0xFFFFFFFF),
                          const Color(0xFFF0F0F2),
                        ],
                ),
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
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildHeaderButton(
                                  icon: Icons.history_outlined,
                                  onPressed: () =>
                                      setState(() => showHistory = true),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        theme.colorScheme.onSurface,
                                        Colors.transparent,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'Calculator',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildHeaderButton(
                                      icon: Icons.functions,
                                      onPressed: () => setState(
                                        () => showScientific = !showScientific,
                                      ),
                                    ),
                                    _buildHeaderButton(
                                      icon: Icons.swap_horiz,
                                      onPressed: () =>
                                          setState(() => showConverter = true),
                                    ),
                                    _buildHeaderButton(
                                      icon: isDarkMode
                                          ? Icons.wb_sunny_outlined
                                          : Icons.nightlight_round_outlined,
                                      onPressed: () => setState(
                                        () => isDarkMode = !isDarkMode,
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? [
                                              Colors.white.withValues(
                                                alpha: 0.05,
                                              ),
                                              Colors.white.withValues(
                                                alpha: 0.02,
                                              ),
                                            ]
                                          : [
                                              Colors.black.withValues(
                                                alpha: 0.02,
                                              ),
                                              Colors.black.withValues(
                                                alpha: 0.01,
                                              ),
                                            ],
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.black.withValues(
                                                alpha: 0.3,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _engine.displayFormat(display),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w200,
                                      letterSpacing: -1,
                                      height: 1,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Keypad area
                              Flexible(
                                child: showScientific
                                    ? ScientificPanel(
                                        onScientificTap:
                                            _handleScientificFunction,
                                      )
                                    : Column(
                                        children: [
                                          // 4x4 keypad using GridView
                                          Expanded(
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    mainAxisSpacing: 14,
                                                    crossAxisSpacing: 14,
                                                    childAspectRatio: 1.0,
                                                  ),
                                              itemCount: 16,
                                              itemBuilder: (context, index) {
                                                switch (index) {
                                                  case 0:
                                                    return CalcKeyButton(
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .utility,
                                                      label: 'AC',
                                                      labelColor:
                                                          Colors.redAccent,
                                                      onTap: _handleClear,
                                                    );
                                                  case 1:
                                                    return CalcKeyButton(
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .utility,
                                                      label: '+/-',
                                                      onTap: _handleToggleSign,
                                                    );
                                                  case 2:
                                                    return CalcKeyButton(
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .utility,
                                                      label: '%',
                                                      onTap: _handlePercent,
                                                    );
                                                  case 3:
                                                    return CalcKeyButton(
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .operator,
                                                      icon: const Icon(
                                                        Icons.close,
                                                        size: 26,
                                                      ),
                                                      onTap: () =>
                                                          _handleOperator(
                                                            Operator.divide,
                                                          ),
                                                    );

                                                  case 4:
                                                    return CalcKeyButton(
                                                      label: '7',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('7'),
                                                    );
                                                  case 5:
                                                    return CalcKeyButton(
                                                      label: '8',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('8'),
                                                    );
                                                  case 6:
                                                    return CalcKeyButton(
                                                      label: '9',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('9'),
                                                    );
                                                  case 7:
                                                    return CalcKeyButton(
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .operator,
                                                      icon: const Icon(
                                                        Icons.clear,
                                                        size: 26,
                                                      ),
                                                      onTap: () =>
                                                          _handleOperator(
                                                            Operator.multiply,
                                                          ),
                                                    );

                                                  case 8:
                                                    return CalcKeyButton(
                                                      label: '4',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('4'),
                                                    );
                                                  case 9:
                                                    return CalcKeyButton(
                                                      label: '5',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('5'),
                                                    );
                                                  case 10:
                                                    return CalcKeyButton(
                                                      label: '6',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('6'),
                                                    );
                                                  case 11:
                                                    return CalcKeyButton(
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
                                                    );

                                                  case 12:
                                                    return CalcKeyButton(
                                                      label: '1',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('1'),
                                                    );
                                                  case 13:
                                                    return CalcKeyButton(
                                                      label: '2',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('2'),
                                                    );
                                                  case 14:
                                                    return CalcKeyButton(
                                                      label: '3',
                                                      variant:
                                                          CalcKeyButtonVariant
                                                              .number,
                                                      onTap: () =>
                                                          _handleDigit('3'),
                                                    );
                                                  case 15:
                                                    return CalcKeyButton(
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
                                                    );
                                                }
                                                return null;
                                              },
                                            ),
                                          ),

                                          const SizedBox(height: 14),

                                          // Bottom row: 0, '.', '='
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
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: CalcKeyButton(
                                                  label: '.',
                                                  variant: CalcKeyButtonVariant
                                                      .number,
                                                  onTap: _handleDecimal,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: CalcKeyButton(
                                                  variant: CalcKeyButtonVariant
                                                      .primary,
                                                  icon: const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 28,
                                                  ),
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
              ConverterSheet(
                onClose: () => setState(() => showConverter = false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          SoundManager().playTapSound();
          onPressed();
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 26),
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
