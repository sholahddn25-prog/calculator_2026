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
  State<CalcKeyButton> createState() => _CalcKeyButtonState();
}

class _CalcKeyButtonState extends State<CalcKeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePress() {
    HapticFeedback.lightImpact();
    SoundManager().playTapSound();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color background;
    Color foreground;
    Color shadowColor;

    switch (widget.variant) {
      case CalcKeyButtonVariant.number:
        background = theme.colorScheme.surfaceContainerHighest;
        foreground = theme.colorScheme.onSurface;
        shadowColor = Colors.black.withValues(alpha: 0.1);
        break;
      case CalcKeyButtonVariant.utility:
        background = theme.colorScheme.surfaceContainer;
        foreground = theme.colorScheme.onSurfaceVariant;
        shadowColor = Colors.black.withValues(alpha: 0.08);
        break;
      case CalcKeyButtonVariant.operator:
        background = theme.colorScheme.primaryContainer;
        foreground = theme.colorScheme.onPrimaryContainer;
        shadowColor = theme.colorScheme.primary.withValues(alpha: 0.3);
        break;
      case CalcKeyButtonVariant.primary:
        background = theme.colorScheme.primary;
        foreground = theme.colorScheme.onPrimary;
        shadowColor = theme.colorScheme.primary.withValues(alpha: 0.4);
        break;
    }

    final child =
        widget.icon ??
        Text(
          widget.label!,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: widget.labelColor ?? foreground,
          ),
        );

    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(0),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: background,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: _handlePress,
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.black.withValues(alpha: 0.1),
                highlightColor: Colors.black.withValues(alpha: 0.05),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        background.withValues(alpha: 0.2),
                        background.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
