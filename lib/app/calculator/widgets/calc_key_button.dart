import 'package:flutter/material.dart';

enum CalcKeyButtonVariant { number, utility, operator, primary }

class CalcKeyButton extends StatelessWidget {
  final String? label;
  final Widget? icon;
  final VoidCallback onTap;
  final CalcKeyButtonVariant variant;
  final Color? labelColor;
  final EdgeInsets? padding;

  const CalcKeyButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.variant = CalcKeyButtonVariant.number,
    this.labelColor,
    this.padding,
  }) : assert(label != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color background;
    Color foreground;

    switch (variant) {
      case CalcKeyButtonVariant.number:
        background = theme.colorScheme.surfaceContainerHighest;
        foreground = theme.colorScheme.onSurface;
        break;
      case CalcKeyButtonVariant.utility:
        background = theme.colorScheme.surfaceContainer;
        foreground = theme.colorScheme.onSurfaceVariant;
        break;
      case CalcKeyButtonVariant.operator:
        background = theme.colorScheme.primaryContainer;
        foreground = theme.colorScheme.onPrimaryContainer;
        break;
      case CalcKeyButtonVariant.primary:
        background = theme.colorScheme.primary;
        foreground = theme.colorScheme.onPrimary;
        break;
    }

    final child =
        icon ??
        Text(
          label!,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: labelColor ?? foreground,
          ),
        );

    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.black.withValues(alpha: 0.08),
          highlightColor: Colors.black.withValues(alpha: 0.04),

          child: SizedBox(height: 72, child: Center(child: child)),
        ),
      ),
    );
  }
}
