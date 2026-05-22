import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/scientific_operator.dart';
import '../utils/calculator_preferences.dart';

class ScientificPanel extends StatelessWidget {
  final Function(ScientificOperator) onScientificTap;

  const ScientificPanel({super.key, required this.onScientificTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const buttons = [
      ['sin', 'cos', 'tan', '('],
      ['sin⁻¹', 'cos⁻¹', 'tan⁻¹', ')'],
      ['ln', 'log', 'log₂', 'π'],
      ['e', 'eˣ', '√', '∛'],
      ['xʸ', 'n!', '1/x', 'mod'],
    ];

    const operatorMap = {
      'sin': ScientificOperator.sine,
      'cos': ScientificOperator.cosine,
      'tan': ScientificOperator.tangent,
      'sin⁻¹': ScientificOperator.arcsin,
      'cos⁻¹': ScientificOperator.arccos,
      'tan⁻¹': ScientificOperator.arctan,
      'ln': ScientificOperator.log,
      'log': ScientificOperator.log10,
      'log₂': ScientificOperator.log2,
      'π': ScientificOperator.pi,
      'e': ScientificOperator.e,
      'eˣ': ScientificOperator.exp,
      '√': ScientificOperator.sqrt,
      '∛': ScientificOperator.cbrt,
      'xʸ': ScientificOperator.power,
      'n!': ScientificOperator.factorial,
      '1/x': ScientificOperator.reciprocal,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: buttons.map((row) {
          return Expanded(
            child: Row(
              children: row.map((label) {
                final isDisabled = ['(', ')', 'mod'].contains(label);
                final isPrimary = ['π', 'e', 'xʸ'].contains(label);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _SciKey(
                      label: label,
                      isDisabled: isDisabled,
                      isPrimary: isPrimary,
                      onTap: isDisabled
                          ? null
                          : () {
                              if (CalculatorPreferences.instance.hapticEnabled) {
                                HapticFeedback.lightImpact();
                              }
                              final operator = operatorMap[label];
                              if (operator != null) {
                                onScientificTap(operator);
                              }
                            },
                      theme: theme,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SciKey extends StatelessWidget {
  final String label;
  final bool isDisabled;
  final bool isPrimary;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _SciKey({
    required this.label,
    required this.isDisabled,
    required this.isPrimary,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDisabled
        ? theme.colorScheme.surfaceContainer
        : isPrimary
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer;
    final fg = isDisabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
        : isPrimary
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSecondaryContainer;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
