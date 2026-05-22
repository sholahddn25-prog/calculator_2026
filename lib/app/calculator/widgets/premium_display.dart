import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Panel display kaca (glass) dengan pratinjau & aksi cepat.
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E293B).withValues(alpha: 0.85),
                    const Color(0xFF0F172A).withValues(alpha: 0.92),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.92),
                    const Color(0xFFF1F5F9).withValues(alpha: 0.88),
                  ],
          ),
          border: Border.all(
            color: isDark
                ? AppTheme.accentGold.withValues(alpha: 0.22)
                : const Color(0xFFCBD5E1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : const Color(0xFF0D9488).withValues(alpha: 0.1),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            if (!isDark)
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.08),
                blurRadius: 0,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (onUndo != null)
                    _ActionChip(
                      icon: Icons.undo_rounded,
                      label: 'Undo',
                      enabled: canUndo,
                      onTap: canUndo ? onUndo! : null,
                    ),
                  const Spacer(),
                  _IconAction(
                    icon: Icons.content_paste_rounded,
                    tooltip: 'Tempel',
                    onTap: () => onPaste(),
                  ),
                  _IconAction(
                    icon: Icons.copy_rounded,
                    tooltip: 'Salin',
                    onTap: onCopy,
                  ),
                ],
              ),
              if (history != null && history!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    history!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.displayHistoryColor(context),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
              if (livePreview != null && livePreview!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '≈ $livePreview',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  formatted,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -2,
                    height: 1.02,
                    color: hasError
                        ? theme.colorScheme.error
                        : AppTheme.displayResultColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: enabled
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
          : theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: enabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
