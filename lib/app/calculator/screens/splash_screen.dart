import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'calculator_screen.dart';

/// Intro 3D premium saat aplikasi dibuka.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _scale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutBack),
    );

    _spinController.forward();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const CalculatorScreen(),
            transitionsBuilder: (_, anim, _, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(anim),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 550),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF030712),
                        Color(0xFF0F172A),
                        Color(0xFF1E1B4B),
                      ]
                    : const [
                        Color(0xFFF8FAFC),
                        Color(0xFFE0E7FF),
                        Color(0xFFCCFBF1),
                      ],
              ),
            ),
          ),
          ...List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _floatController,
              builder: (_, _) {
                final t = _floatController.value;
                return Positioned(
                  top: 80 + i * 120 + math.sin(t * math.pi * 2 + i) * 18,
                  left: 40 + i * 90,
                  child: Container(
                    width: 140 + i * 30,
                    height: 140 + i * 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentGold.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_spinController, _fadeController]),
              builder: (context, child) {
                final spin = _spinController.value;
                final rotY = spin * math.pi * 2;
                final rotX = math.sin(spin * math.pi) * 0.45;

                return Opacity(
                  opacity: 1.0 - _fade.value * 0.85,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateY(rotY)
                        ..rotateX(rotX),
                      child: child,
                    ),
                  ),
                );
              },
              child: _CalculatorCube3D(isDark: isDark),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 72,
            child: AnimatedBuilder(
              animation: _spinController,
              builder: (_, child) => Opacity(
                opacity: Curves.easeOut.transform(
                  ((_spinController.value - 0.35) / 0.65).clamp(0.0, 1.0),
                ),
                child: child,
              ),
              child: Column(
                children: [
                  Text(
                    'CALCULATOR',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      color: isDark
                          ? AppTheme.accentGold
                          : const Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '2026 PRO',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                      color: isDark ? Colors.white : const Color(0xFF0B1220),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 32,
                    height: 3,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(
                        isDark ? AppTheme.accentGold : const Color(0xFF0D9488),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalculatorCube3D extends StatelessWidget {
  final bool isDark;

  const _CalculatorCube3D({required this.isDark});

  @override
  Widget build(BuildContext context) {
    const size = 148.0;
    return SizedBox(
      width: size * 1.6,
      height: size * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _Face(
            size: size,
            depth: -40,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            child: const Text(
              '÷\n×\n−\n+',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                height: 1.4,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          _Face(
            size: size,
            depth: 0,
            color: isDark ? const Color(0xFF111827) : Colors.white,
            border: Border.all(
              color: AppTheme.accentGold.withValues(alpha: 0.45),
              width: 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calculate_rounded,
                  size: 52,
                  color: isDark ? AppTheme.accentGold : const Color(0xFF0D9488),
                ),
                const SizedBox(height: 8),
                Text(
                  '2026',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0B1220),
                  ),
                ),
              ],
            ),
          ),
          _Face(
            size: size * 0.85,
            depth: 36,
            color: isDark
                ? const Color(0xFF134E4A)
                : const Color(0xFFCCFBF1),
            child: Text(
              '123\n456\n789',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Face extends StatelessWidget {
  final double size;
  final double depth;
  final Color color;
  final Widget child;
  final BoxBorder? border;

  const _Face({
    required this.size,
    required this.depth,
    required this.color,
    required this.child,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(0.0, 0.0, depth),
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 28,
              offset: Offset(0, depth.abs() * 0.15 + 8),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
