import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Background premium dengan gradient animated dan orbs halus.
class PremiumBackground extends StatelessWidget {
  final Brightness brightness;
  final Widget child;

  const PremiumBackground({
    super.key,
    required this.brightness,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    
    // Gunakan nilai static (misal t = 0.5) untuk background
    final t = 0.5;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.darkBg1,
                  Color.lerp(AppTheme.darkBg2, AppTheme.darkBg3, t)!,
                  AppTheme.darkBg1,
                ]
              : [
                  AppTheme.lightBg1,
                  Color.lerp(AppTheme.lightBg2, const Color(0xFFF0F4FF), t)!,
                  AppTheme.lightSurface,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Orb 1: top-right
          Positioned(
            top: -100 + sin(t * pi) * 30,
            right: -80 + cos(t * pi * 0.7) * 20,
            child: _BackgroundOrb(
              size: 320,
              color: isDark
                  ? AppTheme.primaryTealDark
                  : AppTheme.primaryTeal,
              opacity: isDark ? 0.04 + t * 0.02 : 0.05 + t * 0.02,
            ),
          ),
          // Orb 2: bottom-left
          Positioned(
            bottom: -60 + cos(t * pi * 0.5) * 25,
            left: -100 + sin(t * pi * 0.8) * 20,
            child: _BackgroundOrb(
              size: 280,
              color: AppTheme.accentGold,
              opacity: isDark ? 0.03 + t * 0.015 : 0.04 + t * 0.015,
            ),
          ),
          // Main content
          child,
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _BackgroundOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
