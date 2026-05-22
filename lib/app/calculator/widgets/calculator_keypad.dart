import 'package:flutter/material.dart';
import 'calc_key_button.dart';
import '../models/operator.dart';

/// Keypad 5 baris — semua tombol selalu terlihat (tanpa GridView yang terpotong).
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
    return Column(
      children: [
        Expanded(
          child: _KeyRow(
            children: [
              CalcKeyButton(
                variant: CalcKeyButtonVariant.utility,
                label: 'AC',
                labelColor: Colors.redAccent,
                onTap: onClear,
              ),
              CalcKeyButton(
                variant: CalcKeyButtonVariant.utility,
                label: '⌫',
                onTap: onBackspace,
              ),
              CalcKeyButton(
                variant: CalcKeyButtonVariant.utility,
                label: '+/−',
                onTap: onToggleSign,
              ),
              CalcKeyButton(
                variant: CalcKeyButtonVariant.operator,
                label: '÷',
                onTap: () => onOperator(Operator.divide),
              ),
            ],
          ),
        ),
        Expanded(
          child: _KeyRow(
            children: [
              _num('7'),
              _num('8'),
              _num('9'),
              CalcKeyButton(
                variant: CalcKeyButtonVariant.operator,
                label: '×',
                onTap: () => onOperator(Operator.multiply),
              ),
            ],
          ),
        ),
        Expanded(
          child: _KeyRow(
            children: [
              _num('4'),
              _num('5'),
              _num('6'),
              CalcKeyButton(
                variant: CalcKeyButtonVariant.operator,
                label: '−',
                onTap: () => onOperator(Operator.subtract),
              ),
            ],
          ),
        ),
        Expanded(
          child: _KeyRow(
            children: [
              _num('1'),
              _num('2'),
              _num('3'),
              CalcKeyButton(
                variant: CalcKeyButtonVariant.operator,
                label: '+',
                onTap: () => onOperator(Operator.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CalcKeyButton(
                    label: '0',
                    variant: CalcKeyButtonVariant.number,
                    onTap: () => onDigit('0'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CalcKeyButton(
                    label: '.',
                    variant: CalcKeyButtonVariant.number,
                    onTap: onDecimal,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CalcKeyButton(
                    variant: CalcKeyButtonVariant.primary,
                    label: '=',
                    onTap: onEqual,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  CalcKeyButton _num(String d) => CalcKeyButton(
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
      children: children
          .map(
            (w) => Expanded(
              child: Padding(padding: const EdgeInsets.all(4), child: w),
            ),
          )
          .toList(),
    );
  }
}
