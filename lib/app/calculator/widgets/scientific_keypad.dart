import 'package:flutter/material.dart';

import '../models/operator.dart';
import '../models/scientific_operator.dart';
import 'calc_key_button.dart';

/// Keypad kalkulator scientific premium yang menggabungkan digit dan operator.
class ScientificKeypad extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onToggleSign;
  final VoidCallback onPercent;
  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final ValueChanged<Operator> onOperator;
  final VoidCallback onEqual;
  
  final ValueChanged<ScientificOperator> onScientificTap;
  final VoidCallback onOpenParen;
  final VoidCallback onCloseParen;
  final VoidCallback onMod;

  const ScientificKeypad({
    super.key,
    required this.onClear,
    required this.onBackspace,
    required this.onToggleSign,
    required this.onPercent,
    required this.onDigit,
    required this.onDecimal,
    required this.onOperator,
    required this.onEqual,
    required this.onScientificTap,
    required this.onOpenParen,
    required this.onCloseParen,
    required this.onMod,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Column(
      children: [
        // Row 1
        Expanded(
          child: _KeyRow(children: [
            _sci('√', ScientificOperator.sqrt),
            _sci('xʸ', ScientificOperator.power),
            _sci('π', ScientificOperator.pi),
            _util('(', onOpenParen),
            _util(')', onCloseParen),
          ]),
        ),
        // Row 2
        Expanded(
          child: _KeyRow(children: [
            _sci('inv', ScientificOperator.reciprocal, highlight: true),
            _sci('x!', ScientificOperator.factorial),
            _sci('e', ScientificOperator.e),
            _util('mod', onMod),
            _sci('eˣ', ScientificOperator.exp),
          ]),
        ),
        // Row 3
        Expanded(
          child: _KeyRow(children: [
            _sci('sin', ScientificOperator.sine),
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
        // Row 4
        Expanded(
          child: _KeyRow(children: [
            _sci('cos', ScientificOperator.cosine),
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
        // Row 5
        Expanded(
          child: _KeyRow(children: [
            _sci('tan', ScientificOperator.tangent),
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
        // Row 6
        Expanded(
          child: _KeyRow(children: [
            _sci('ln', ScientificOperator.log),
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
        // Row 7
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: _sci('log', ScientificOperator.log10),
              ),
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
                flex: 1,
                child: CalcKeyButton(
                  label: '.',
                  variant: CalcKeyButtonVariant.number,
                  onTap: onDecimal,
                ),
              ),
              Expanded(
                flex: 1,
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

  CalcKeyButton _sci(String label, ScientificOperator op, {bool highlight = false}) => CalcKeyButton(
        label: label,
        variant: highlight ? CalcKeyButtonVariant.primary : CalcKeyButtonVariant.utility,
        onTap: () => onScientificTap(op),
      );

  CalcKeyButton _util(String label, VoidCallback onTap) => CalcKeyButton(
        label: label,
        variant: CalcKeyButtonVariant.utility,
        onTap: onTap,
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
