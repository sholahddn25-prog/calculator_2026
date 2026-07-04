import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Display premium dengan efek glassmorphism, blur, dan animasi angka.
class PremiumDisplay extends StatelessWidget {
  final String formatted;
  final String? history;
  final String? livePreview;
  final double fontSize;
  final bool hasError;
  final VoidCallback onCopy;
  final Future<void> Function() onPaste;
  final VoidCallback? onUndo;
  final bool canUndo;

  const PremiumDisplay({
    super.key,
    required this.formatted,
    this.history,
    this.livePreview,
    required this.fontSize,
    this.hasError = false,
    required this.onCopy,
    required this.onPaste,
    this.onUndo,
    this.canUndo = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;
    final accentColor = hasError ? errorColor : primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        decoration: AppTheme.displayCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
              // ── Top action bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    // Undo button
                    _ActionButton(
                      icon: Icons.undo_rounded,
                      tooltip: 'Undo',
                      enabled: canUndo,
                      onTap: canUndo ? onUndo! : () {},
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                    // Paste button
                    _ActionButton(
                      icon: Icons.content_paste_rounded,
                      tooltip: 'Tempel dari clipboard',
                      enabled: true,
                      onTap: onPaste,
                      isDark: isDark,
                    ),
                    const Spacer(),
                    // Copy button
                    _ActionButton(
                      icon: Icons.copy_rounded,
                      tooltip: 'Salin hasil',
                      enabled: true,
                      onTap: onCopy,
                      isDark: isDark,
                      accent: accentColor,
                    ),
                  ],
                ),
              ),

              // ── History expression ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    key: ValueKey(history ?? ''),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        history ?? ' ',
                        maxLines: 1,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.displayHistoryColor(context),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Live preview ──────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: livePreview != null && livePreview!.isNotEmpty
                    ? Padding(
                        key: const ValueKey('preview-visible'),
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                '≈ $livePreview',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(key: ValueKey('preview-hidden'), height: 2),
              ),

              // ── Main result display ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: fontSize * 1.2,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -2.0,
                      color: hasError ? errorColor : accentColor,
                      shadows: hasError
                          ? null
                          : [
                              Shadow(
                                color: accentColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                              ),
                            ],
                    ),
                    child: Text(formatted),
                  ),
                ),
              ),

              // ── Error indicator ────────────────────────────────────────────
              if (hasError)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: errorColor.withValues(alpha: 0.08),
                    border: Border(
                      top: BorderSide(
                        color: errorColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: errorColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tekan AC untuk reset',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final dynamic Function() onTap; // VoidCallback or Future<void> Function()
  final bool isDark;
  final Color? accent;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
    required this.isDark,
    this.accent,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark
        ? Colors.white.withValues(alpha: widget.enabled ? 0.7 : 0.2)
        : Colors.black.withValues(alpha: widget.enabled ? 0.5 : 0.15);
    final iconColor = widget.accent ?? baseColor;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (widget.enabled) widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: _pressed ? 0.12 : 0.06)
                  : Colors.black.withValues(alpha: _pressed ? 0.1 : 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
