import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/sound_manager.dart';

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
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    HapticFeedback.lightImpact();
    SoundManager().playTapSound();
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

    switch (widget.variant) {
      case CalcKeyButtonVariant.number:
        background = theme.colorScheme.surfaceContainerHighest;
        foreground = theme.colorScheme.onSurface;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ];
        border = Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        );
        break;
      case CalcKeyButtonVariant.utility:
        background = theme.colorScheme.surfaceContainer;
        foreground = theme.colorScheme.onSurfaceVariant;
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        border = null;
        break;
      case CalcKeyButtonVariant.operator:
        background = theme.colorScheme.primaryContainer;
        foreground = theme.colorScheme.onPrimaryContainer;
        shadows = [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        border = null;
        break;
      case CalcKeyButtonVariant.primary:
        background = theme.colorScheme.primary;
        foreground = theme.colorScheme.onPrimary;
        shadows = [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
        border = null;
        break;
    }

    final child = widget.icon ??
        Text(
          widget.label!,
          style: TextStyle(
            fontSize: widget.variant == CalcKeyButtonVariant.utility ? 18 : 24,
            fontWeight: FontWeight.w600,
            color: widget.labelColor ?? foreground,
            letterSpacing: widget.label == '0' ? 0 : -0.5,
          ),
        );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handlePress,
            borderRadius: BorderRadius.circular(18),
            splashColor: foreground.withValues(alpha: 0.12),
            highlightColor: foreground.withValues(alpha: 0.06),
            child: Ink(
              height: widget.height ?? 64,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(18),
                border: border,
                boxShadow: shadows,
                gradient: widget.variant == CalcKeyButtonVariant.primary
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          background,
                          Color.lerp(background, Colors.white, 0.12)!,
                        ],
                      )
                    : null,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
