import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Latar animasi premium dengan orbs mengambang.
class PremiumBackground extends StatefulWidget {
  final Brightness brightness;
  final Widget child;

  const PremiumBackground({
    super.key,
    required this.brightness,
    required this.child,
  });

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppTheme.backgroundGradient(widget.brightness),
              stops: const [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (_, _) {
            final t = _controller.value * 2 * math.pi;
            return Stack(
              children: [
                Positioned(
                  top: -60 + math.sin(t) * 20,
                  right: -40 + math.cos(t * 0.7) * 15,
                  child: _Orb(
                    size: 240,
                    color: (isDark ? AppTheme.accentGold : const Color(0xFF0D9488))
                        .withValues(alpha: 0.14),
                  ),
                ),
                Positioned(
                  bottom: 80 + math.cos(t * 0.8) * 25,
                  left: -50,
                  child: _Orb(
                    size: 200,
                    color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8))
                        .withValues(alpha: 0.1),
                  ),
                ),
                Positioned(
                  top: MediaQuery.sizeOf(context).height * 0.35,
                  left: MediaQuery.sizeOf(context).width * 0.5 - 80,
                  child: _Orb(
                    size: 160,
                    color: AppTheme.accentGold.withValues(alpha: isDark ? 0.06 : 0.08),
                  ),
                ),
              ],
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
