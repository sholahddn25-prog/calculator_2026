import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/calculator_preferences.dart';

enum CalcKeyButtonVariant { number, utility, operator, primary }

class CalcKeyButton extends StatefulWidget {
  final String? label;
  final Widget? icon;
  final VoidCallback onTap;
  final CalcKeyButtonVariant variant;
  final Color? labelColor;
  final EdgeInsets? padding;
  final double? height;

  const CalcKeyButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.variant = CalcKeyButtonVariant.number,
    this.labelColor,
    this.padding,
    this.height,
  }) : assert(label != null || icon != null);

  @override
  State<CalcKeyButton> createState() => _CalcKeyButtonState();
}

class _CalcKeyButtonState extends State<CalcKeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _press;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 140),
      vsync: this,
    );
    _press = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (CalculatorPreferences.instance.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color background;
    Color foreground;
    List<BoxShadow> shadows;
    Border? border;
    Gradient? gradient;

    switch (widget.variant) {
      case CalcKeyButtonVariant.number:
        background = isDark
            ? const Color(0xFF1E293B)
            : Colors.white;
        foreground = theme.colorScheme.onSurface;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ];
        border = Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE2E8F0),
        );
        break;
      case CalcKeyButtonVariant.utility:
        background = theme.colorScheme.surfaceContainer;
        foreground = theme.colorScheme.onSurfaceVariant;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case CalcKeyButtonVariant.operator:
        background = theme.colorScheme.primaryContainer;
        foreground = theme.colorScheme.onPrimaryContainer;
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            Color.lerp(
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primary,
              0.15,
            )!,
          ],
        );
        shadows = [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ];
        break;
      case CalcKeyButtonVariant.primary:
        background = theme.colorScheme.primary;
        foreground = theme.colorScheme.onPrimary;
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            Color.lerp(theme.colorScheme.primary, AppTheme.accentGold, 0.25)!,
          ],
        );
        shadows = [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          if (isDark)
            BoxShadow(
              color: AppTheme.accentGold.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
        ];
        break;
    }

    final child = widget.icon ??
        Text(
          widget.label!,
          style: TextStyle(
            fontSize: widget.variant == CalcKeyButtonVariant.utility ? 18 : 26,
            fontWeight: FontWeight.w600,
            color: widget.labelColor ?? foreground,
            letterSpacing: -0.5,
          ),
        );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          final p = _press.value;
          final tiltX = p * 0.12;
          final scale = 1.0 - p * 0.06;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateX(tiltX)
              ..scale(scale, scale, 1.0),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handlePress,
            borderRadius: BorderRadius.circular(20),
            splashColor: foreground.withValues(alpha: 0.15),
            child: Ink(
              height: widget.height ?? 62,
              decoration: BoxDecoration(
                color: gradient == null ? background : null,
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                border: border,
                boxShadow: shadows,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
