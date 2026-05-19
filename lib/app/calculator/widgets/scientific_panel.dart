import 'package:flutter/material.dart';
import '../models/scientific_operator.dart';

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

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: buttons.map((row) {
            return Expanded(
              child: Row(
                children: row.map((label) {
                  final isSpecialChar = ['(', ')', 'mod'].contains(label);

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Material(
                        color: isSpecialChar
                            ? theme.colorScheme.tertiaryContainer
                            : theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () {
                            if (!isSpecialChar) {
                              final operator = operatorMap[label];
                              if (operator != null) {
                                onScientificTap(operator);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSpecialChar
                                    ? theme.colorScheme.onTertiaryContainer
                                    : theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
