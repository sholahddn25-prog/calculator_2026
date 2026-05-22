import 'package:flutter/material.dart';

class MemoryBar extends StatelessWidget {
  final bool hasMemory;
  final VoidCallback onClear;
  final VoidCallback onRecall;
  final VoidCallback onAdd;
  final VoidCallback onSubtract;

  const MemoryBar({
    super.key,
    required this.hasMemory,
    required this.onClear,
    required this.onRecall,
    required this.onAdd,
    required this.onSubtract,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          _MemKey(
            label: 'MC',
            enabled: hasMemory,
            onTap: onClear,
            theme: theme,
          ),
          _MemKey(
            label: 'MR',
            enabled: hasMemory,
            onTap: onRecall,
            theme: theme,
          ),
          _MemKey(label: 'M+', enabled: true, onTap: onAdd, theme: theme),
          _MemKey(label: 'M−', enabled: true, onTap: onSubtract, theme: theme),
          const Spacer(),
          if (hasMemory)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'M',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemKey extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final ThemeData theme;

  const _MemKey({
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: enabled
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
