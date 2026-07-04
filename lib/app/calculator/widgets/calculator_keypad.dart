import 'package:flutter/material.dart';

import '../models/operator.dart';
import 'calc_key_button.dart';

/// Keypad kalkulator standar dengan 5 baris tombol.
class CalculatorKeypad extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onToggleSign;
  final VoidCallback onPercent;
  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final ValueChanged<Operator> onOperator;
  final VoidCallback onEqual;

  const CalculatorKeypad({
    super.key,
    required this.onClear,
    required this.onBackspace,
    required this.onToggleSign,
    required this.onPercent,
    required this.onDigit,
    required this.onDecimal,
    required this.onOperator,
    required this.onEqual,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Column(
      children: [
        // Row 1: AC, ⌫, +/-, ÷
        Expanded(
          child: _KeyRow(children: [
            CalcKeyButton(
              variant: CalcKeyButtonVariant.utility,
              label: 'AC',
              labelColor: errorColor,
              onTap: onClear,
            ),
            CalcKeyButton(
              variant: CalcKeyButtonVariant.utility,
              icon: const Icon(Icons.backspace_outlined),
              onTap: onBackspace,
            ),
            CalcKeyButton(
              variant: CalcKeyButtonVariant.utility,
              label: '+/-',
              onTap: onToggleSign,
            ),
            CalcKeyButton(
              variant: CalcKeyButtonVariant.operator,
              label: '÷',
              onTap: () => onOperator(Operator.divide),
            ),
          ]),
        ),

        // Row 2: 7, 8, 9, ×
        Expanded(
          child: _KeyRow(children: [
            _digit('7'),
            _digit('8'),
            _digit('9'),
            CalcKeyButton(
              variant: CalcKeyButtonVariant.operator,
              label: '×',
              onTap: () => onOperator(Operator.multiply),
            ),
          ]),
        ),

        // Row 3: 4, 5, 6, -
        Expanded(
          child: _KeyRow(children: [
            _digit('4'),
            _digit('5'),
            _digit('6'),
            CalcKeyButton(
              variant: CalcKeyButtonVariant.operator,
              label: '−',
              onTap: () => onOperator(Operator.subtract),
            ),
          ]),
        ),

        // Row 4: 1, 2, 3, +
        Expanded(
          child: _KeyRow(children: [
            _digit('1'),
            _digit('2'),
            _digit('3'),
            CalcKeyButton(
              variant: CalcKeyButtonVariant.operator,
              label: '+',
              onTap: () => onOperator(Operator.add),
            ),
          ]),
        ),

        // Row 5: 0 (wide), ., =
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: CalcKeyButton(
                  label: '0',
                  variant: CalcKeyButtonVariant.number,
                  onTap: () => onDigit('0'),
                  isWide: true,
                ),
              ),
              Expanded(
                child: CalcKeyButton(
                  label: '.',
                  variant: CalcKeyButtonVariant.number,
                  onTap: onDecimal,
                ),
              ),
              Expanded(
                child: CalcKeyButton(
                  variant: CalcKeyButtonVariant.primary,
                  label: '=',
                  onTap: onEqual,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  CalcKeyButton _digit(String d) => CalcKeyButton(
        label: d,
        variant: CalcKeyButtonVariant.number,
        onTap: () => onDigit(d),
      );
}

class _KeyRow extends StatelessWidget {
  final List<Widget> children;
  const _KeyRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.map((w) => Expanded(child: w)).toList(),
    );
  }
}
