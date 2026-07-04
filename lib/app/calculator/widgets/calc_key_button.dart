import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../utils/calculator_preferences.dart';

enum CalcKeyButtonVariant { number, utility, operator, primary }

/// Tombol kalkulator premium dengan efek tekan 3D, gradient, dan haptic.
class CalcKeyButton extends StatefulWidget {
  final String? label;
  final Widget? icon;
  final VoidCallback onTap;
  final CalcKeyButtonVariant variant;
  final Color? labelColor;
  final EdgeInsets? padding;
  final double? height;
  final bool isWide;

  const CalcKeyButton({
    super.key,
    this.label,
    this.icon,
    required this.onTap,
    this.variant = CalcKeyButtonVariant.number,
    this.labelColor,
    this.padding,
    this.height,
    this.isWide = false,
  }) : assert(label != null || icon != null);

  @override
  State<CalcKeyButton> createState() => _CalcKeyButtonState();
}

class _CalcKeyButtonState extends State<CalcKeyButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => setState(() => _isPressed = true);
  void _handleTapUp(TapUpDetails _) => setState(() => _isPressed = false);
  void _handleTapCancel() => setState(() => _isPressed = false);

  void _handleTap() {
    if (CalculatorPreferences.instance.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    _shimmerController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _ButtonColors.resolve(context, widget.variant, isDark);
    final foreground = widget.labelColor ?? colors.foreground;

    Widget content;
    if (widget.icon != null) {
      content = IconTheme(
        data: IconThemeData(color: foreground, size: 24),
        child: widget.icon!,
      );
    } else {
      final isUtility = widget.variant == CalcKeyButtonVariant.utility;
      content = FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          widget.label!,
          style: TextStyle(
            fontSize: isUtility ? 22 : 28,
            fontWeight: isUtility ? FontWeight.w600 : FontWeight.w500,
            color: foreground,
            letterSpacing: 0,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      );
    }

    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(4),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          height: widget.height,
          transform: Matrix4.translationValues(
            0,
            _isPressed ? 3.0 : 0.0,
            0,
          ),
          decoration: BoxDecoration(
            gradient: colors.gradient,
            color: colors.gradient == null ? colors.background : null,
            borderRadius: BorderRadius.circular(22),
            border: colors.borderColor != null
                ? Border.all(
                    color: colors.borderColor!.withValues(
                      alpha: _isPressed ? 0.1 : 0.18,
                    ),
                    width: 1.0,
                  )
                : null,
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: colors.shadow.withValues(
                        alpha: isDark ? 0.35 : 0.15,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}

// ─── Button Colors ────────────────────────────────────────────────────────────
class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color shadow;
  final Gradient? gradient;
  final Color? borderColor;

  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.shadow,
    this.gradient,
    this.borderColor,
  });

  static _ButtonColors resolve(
    BuildContext context,
    CalcKeyButtonVariant variant,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    switch (variant) {
      case CalcKeyButtonVariant.number:
        return _ButtonColors(
          background: isDark
              ? AppTheme.darkSurfaceElevated
              : Colors.white,
          foreground: theme.colorScheme.onSurface,
          shadow: isDark ? Colors.black : const Color(0xFF334155),
          borderColor: isDark
              ? AppTheme.primaryTealDark.withValues(alpha: 0.08)
              : const Color(0xFFCBD5E1),
        );

      case CalcKeyButtonVariant.utility:
        return _ButtonColors(
          background: isDark
              ? AppTheme.darkSurface
              : const Color(0xFFE2F4FF),
          foreground: isDark
              ? AppTheme.primaryTealDark
              : AppTheme.primaryTeal,
          shadow: isDark ? Colors.black : const Color(0xFF0E7490),
          borderColor: isDark
              ? AppTheme.primaryTealDark.withValues(alpha: 0.12)
              : AppTheme.primaryTeal.withValues(alpha: 0.2),
        );

      case CalcKeyButtonVariant.operator:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: isDark
              ? AppTheme.primaryTealDark
              : AppTheme.primaryTeal,
          shadow: AppTheme.primaryTeal,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.darkSurface,
                    const Color(0xFF0A1E35),
                  ]
                : [
                    const Color(0xFFE0F7F4),
                    const Color(0xFFCCF5F0),
                  ],
          ),
          borderColor: isDark
              ? AppTheme.primaryTealDark.withValues(alpha: 0.25)
              : AppTheme.primaryTeal.withValues(alpha: 0.3),
        );

      case CalcKeyButtonVariant.primary:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: Colors.white,
          shadow: AppTheme.primaryTeal,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.primaryTeal,
                    const Color(0xFF0E7490),
                  ]
                : [
                    AppTheme.primaryTeal,
                    const Color(0xFF065F56),
                  ],
          ),
        );
    }
  }
}
