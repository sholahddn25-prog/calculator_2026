import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database_helper.dart';
import '../models/history_item.dart';
import '../theme/app_theme.dart';

/// History sheet dengan data persistent dari SQLite.
/// Mendukung swipe-to-delete per item.
class HistorySheet extends StatefulWidget {
  final List<HistoryItem> items;
  final VoidCallback onClose;
  final ValueChanged<HistoryItem> onPick;
  final VoidCallback onClear;

  const HistorySheet({
    super.key,
    required this.items,
    required this.onClose,
    required this.onPick,
    required this.onClear,
  });

  @override
  State<HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<HistorySheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;
  late List<HistoryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _deleteItem(HistoryItem item) async {
    await DatabaseHelper.instance.deleteHistoryById(item.id);
    if (mounted) {
      setState(() => _items.removeWhere((e) => e.id == item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),

        // Side panel
        SlideTransition(
          position: _slideAnim,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppTheme.darkBg2, AppTheme.darkBg3]
                        : [AppTheme.lightSurface, AppTheme.lightBg2],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                      blurRadius: 32,
                      offset: const Offset(8, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(context, theme, isDark),

                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withValues(alpha: 0.15),
                      ),

                      // List
                      Expanded(
                        child: _items.isEmpty
                            ? _EmptyState(isDark: isDark)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  12, 12, 12, 16,
                                ),
                                itemCount: _items.length,
                                itemBuilder: (context, i) {
                                  final item = _items[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _HistoryTile(
                                      item: item,
                                      index: i,
                                      isDark: isDark,
                                      onTap: () => widget.onPick(item),
                                      onDelete: () => _deleteItem(item),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Clear all button
                      if (_items.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await DatabaseHelper.instance.deleteAllHistory();
                                if (mounted) {
                                  setState(() => _items.clear());
                                  widget.onClear();
                                }
                              },
                              icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                              label: const Text('Hapus semua riwayat'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.error,
                                side: BorderSide(
                                  color: theme.colorScheme.error.withValues(alpha: 0.4),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppTheme.primaryTeal, const Color(0xFF0E7490)]
                    : [AppTheme.primaryTeal, const Color(0xFF065F56)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riwayat',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${_items.length} perhitungan tersimpan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close_rounded),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── History Tile ─────────────────────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final HistoryItem item;
  final int index;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.item,
    required this.index,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} mnt lalu';
    if (diff.inDays < 1) return DateFormat('HH:mm').format(dt);
    if (diff.inDays < 7) return DateFormat('EEE HH:mm', 'id').format(dt);
    return DateFormat('dd MMM', 'id').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: theme.colorScheme.error,
          size: 22,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkSurfaceElevated
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppTheme.primaryTealDark.withValues(alpha: 0.1)
                    : AppTheme.primaryTeal.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                          : AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppTheme.primaryTealDark
                              : AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Calculation info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.calculation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '= ${item.result}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppTheme.primaryTealDark
                                : AppTheme.primaryTeal,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time + arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(item.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryTeal.withValues(alpha: 0.12),
                    AppTheme.accentGold.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? AppTheme.primaryTealDark.withValues(alpha: 0.2)
                      : AppTheme.primaryTeal.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.calculate_outlined,
                size: 36,
                color: isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum ada riwayat',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hasil perhitungan Anda akan\nmuncul di sini secara otomatis.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
