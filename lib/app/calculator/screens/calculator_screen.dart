import 'package:flutter/material.dart';

import '../models/history_item.dart';
import '../models/operator.dart';
import '../theme/app_theme.dart';
import '../utils/calculator_engine.dart';
import '../utils/number_formatting.dart';
import '../utils/animations/calc_transition.dart';
import '../widgets/calc_key_button.dart';
import '../widgets/history_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _engine = CalculatorEngine();

  String display = '0';
  String history = '';
  double? prevValue;
  Operator? operator;
  bool waitingForOperand = false;

  bool isDarkMode = false;
  bool showHistory = false;

  final List<HistoryItem> historyLog = [];

  ThemeData get _lightTheme => AppTheme.light();
  ThemeData get _darkTheme => AppTheme.dark();

  @override
  Widget build(BuildContext context) {
    final theme = isDarkMode ? _darkTheme : _lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  setState(() => showHistory = true),
                              icon: const Icon(
                                Icons.history_outlined,
                                size: 26,
                              ),
                            ),
                            const Text(
                              'Calculator',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => isDarkMode = !isDarkMode),
                              icon: Icon(
                                isDarkMode
                                    ? Icons.wb_sunny_outlined
                                    : Icons.nightlight_round_outlined,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Content area
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) {
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.05),
                                        end: Offset.zero,
                                      ).animate(anim),
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
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 260),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, anim) {
                                  return CalcTransition(
                                    animation: anim,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  _engine.displayFormat(display),
                                  key: ValueKey(display),
                                  style: TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w200,
                                    height: 1,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Keypad area (flexed so no overflow)
                              Flexible(
                                child: Column(
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
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 1.1,
                                            ),
                                        itemCount: 16,
                                        itemBuilder: (context, index) {
                                          switch (index) {
                                            case 0:
                                              return CalcKeyButton(
                                                variant: CalcKeyButtonVariant
                                                    .utility,
                                                label: 'AC',
                                                labelColor: Colors.redAccent,
                                                onTap: _handleClear,
                                              );
                                            case 1:
                                              return CalcKeyButton(
                                                variant: CalcKeyButtonVariant
                                                    .utility,
                                                label: '+/-',
                                                onTap: _handleToggleSign,
                                              );
                                            case 2:
                                              return CalcKeyButton(
                                                variant: CalcKeyButtonVariant
                                                    .utility,
                                                label: '%',
                                                onTap: _handlePercent,
                                              );
                                            case 3:
                                              return CalcKeyButton(
                                                variant: CalcKeyButtonVariant
                                                    .operator,
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 26,
                                                ),
                                                onTap: () => _handleOperator(
                                                  Operator.divide,
                                                ),
                                              );

                                            case 4:
                                              return CalcKeyButton(
                                                label: '7',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('7'),
                                              );
                                            case 5:
                                              return CalcKeyButton(
                                                label: '8',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('8'),
                                              );
                                            case 6:
                                              return CalcKeyButton(
                                                label: '9',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('9'),
                                              );
                                            case 7:
                                              return CalcKeyButton(
                                                variant: CalcKeyButtonVariant
                                                    .operator,
                                                icon: const Icon(
                                                  Icons.clear,
                                                  size: 26,
                                                ),
                                                onTap: () => _handleOperator(
                                                  Operator.multiply,
                                                ),
                                              );

                                            case 8:
                                              return CalcKeyButton(
                                                label: '4',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('4'),
                                              );
                                            case 9:
                                              return CalcKeyButton(
                                                label: '5',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('5'),
                                              );
                                            case 10:
                                              return CalcKeyButton(
                                                label: '6',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('6'),
                                              );
                                            case 11:
                                              return CalcKeyButton(
                                                variant: CalcKeyButtonVariant
                                                    .operator,
                                                icon: const Icon(
                                                  Icons.remove,
                                                  size: 26,
                                                ),
                                                onTap: () => _handleOperator(
                                                  Operator.subtract,
                                                ),
                                              );

                                            case 12:
                                              return CalcKeyButton(
                                                label: '1',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('1'),
                                              );
                                            case 13:
                                              return CalcKeyButton(
                                                label: '2',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('2'),
                                              );
                                            case 14:
                                              return CalcKeyButton(
                                                label: '3',
                                                variant:
                                                    CalcKeyButtonVariant.number,
                                                onTap: () => _handleDigit('3'),
                                              );
                                            case 15:
                                              return CalcKeyButton(
                                                variant: CalcKeyButtonVariant
                                                    .operator,
                                                icon: const Icon(
                                                  Icons.add,
                                                  size: 26,
                                                ),
                                                onTap: () => _handleOperator(
                                                  Operator.add,
                                                ),
                                              );
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Bottom row: 0, '.', '='
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: CalcKeyButton(
                                            label: '0',
                                            variant:
                                                CalcKeyButtonVariant.number,
                                            onTap: () => _handleDigit('0'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CalcKeyButton(
                                            label: '.',
                                            variant:
                                                CalcKeyButtonVariant.number,
                                            onTap: _handleDecimal,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: CalcKeyButton(
                                            variant:
                                                CalcKeyButtonVariant.primary,
                                            icon: const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 28,
                                              // matches the original React "=" (operator action) better than a thin checkmark
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
}
