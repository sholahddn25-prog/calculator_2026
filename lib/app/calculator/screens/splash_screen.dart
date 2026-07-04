import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'calculator_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Cube rotation
  late AnimationController _cubeController;
  late Animation<double> _cubeRotX;
  late Animation<double> _cubeRotY;
  late Animation<double> _cubeScale;

  // Orb pulse
  late AnimationController _orbController;

  // Text reveal
  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Logo glow
  late AnimationController _glowController;
  late Animation<double> _glowOpacity;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // ── Cube ──────────────────────────────────────────────────────────────────
    _cubeController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    _cubeRotX = Tween<double>(begin: -0.6, end: 0.3).animate(
      CurvedAnimation(
        parent: _cubeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _cubeRotY = Tween<double>(begin: -0.8, end: 0.4).animate(
      CurvedAnimation(
        parent: _cubeController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _cubeScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _cubeController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // ── Orbs ─────────────────────────────────────────────────────────────────
    _orbController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    // ── Text ─────────────────────────────────────────────────────────────────
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // ── Glow ─────────────────────────────────────────────────────────────────
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowOpacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // ── Sequence ─────────────────────────────────────────────────────────────
    _cubeController.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _textController.forward();
    });

    _navTimer = Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CalculatorScreen(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.97, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOut),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 550),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _cubeController.dispose();
    _orbController.dispose();
    _textController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final primary = isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg1 : AppTheme.lightBg1,
      body: Stack(
        children: [
          // ── Animated orbs background ─────────────────────────────────────
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) {
              final t = _orbController.value;
              return Stack(
                children: [
                  _Orb(
                    left: -60 + t * 40,
                    top: -40 + t * 30,
                    size: 280,
                    color: primary,
                    opacity: 0.08 + t * 0.04,
                  ),
                  _Orb(
                    right: -80 + t * 50,
                    bottom: 100 + t * 60,
                    size: 240,
                    color: AppTheme.accentGold,
                    opacity: 0.05 + t * 0.03,
                  ),
                  _Orb(
                    left: 80 + t * 30,
                    bottom: -60 + t * 20,
                    size: 200,
                    color: primary,
                    opacity: 0.06 + t * 0.02,
                  ),
                ],
              );
            },
          ),

          // ── Main content ─────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3D Cube
                AnimatedBuilder(
                  animation: _cubeController,
                  builder: (_, __) => Transform.scale(
                    scale: _cubeScale.value,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_cubeRotX.value)
                        ..rotateY(_cubeRotY.value),
                      child: _GlowingCube(
                        isDark: isDark,
                        glowAnim: _glowOpacity,
                        primary: primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Brand text
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [primary, AppTheme.accentGold],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'CALCULATOR',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: Colors.white,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '2 0 2 6   P R O',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 6,
                            color: isDark
                                ? Colors.white38
                                : Colors.black38,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Loading dots
                        _LoadingDots(color: primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Version watermark
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Text(
                'v2.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white24 : Colors.black26,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Orb Widget ──────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double? left, top, right, bottom;
  final double size;
  final Color color;
  final double opacity;

  const _Orb({
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
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
      ),
    );
  }
}

// ─── 3D Glowing Cube ─────────────────────────────────────────────────────────
class _GlowingCube extends StatelessWidget {
  final bool isDark;
  final Animation<double> glowAnim;
  final Color primary;

  const _GlowingCube({
    required this.isDark,
    required this.glowAnim,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withValues(alpha: 0.9),
                AppTheme.accentGold.withValues(alpha: 0.7),
                primary.withValues(alpha: 0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: glowAnim.value * 0.6),
                blurRadius: 40,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: AppTheme.accentGold.withValues(
                  alpha: glowAnim.value * 0.3,
                ),
                blurRadius: 60,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(70, 70),
              painter: _CalcIconPainter(isDark: isDark),
            ),
          ),
        );
      },
    );
  }
}

// ─── Calc Icon Painter ────────────────────────────────────────────────────────
class _CalcIconPainter extends CustomPainter {
  final bool isDark;
  const _CalcIconPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Calc body rounded rect
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    canvas.drawRRect(rrect, Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill);
    canvas.drawRRect(rrect, strokePaint..color = Colors.white.withValues(alpha: 0.4));

    // Display area
    final displayRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, 18),
      const Radius.circular(4),
    );
    canvas.drawRRect(displayRect, paint..color = Colors.white.withValues(alpha: 0.3));

    // Buttons grid
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final dotSize = 4.0;
    final startX = 12.0;
    final startY = 34.0;
    final gapX = (size.width - 24) / 3;
    final gapY = 10.0;
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        canvas.drawCircle(
          Offset(startX + col * gapX, startY + row * gapY),
          dotSize / 2,
          dotPaint,
        );
      }
    }

    // Plus sign in last button
    final cx = startX + 3 * gapX;
    final cy = startY + 2 * gapY;
    final plusPaint = Paint()
      ..color = AppTheme.accentGold.withValues(alpha: 0.9)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 3, cy), Offset(cx + 3, cy), plusPaint);
    canvas.drawLine(Offset(cx, cy - 3), Offset(cx, cy + 3), plusPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Loading Dots ─────────────────────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  final Color color;
  const _LoadingDots({required this.color});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final t = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
            final opacity = sin(t * pi).clamp(0.2, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: opacity),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
