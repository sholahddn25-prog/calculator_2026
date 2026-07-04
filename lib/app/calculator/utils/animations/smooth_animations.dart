import 'package:flutter/material.dart';

class SmoothAnimations {
  static Widget smoothFadeScale({
    required Widget child,
    required Animation<double> anim,
  }) {
    return FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim),
        child: child,
      ),
    );
  }
}
