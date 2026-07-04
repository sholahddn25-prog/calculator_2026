import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/calculator_preferences.dart';

/// Settings sheet premium dengan penyimpanan real ke SharedPreferences.
class SettingsSheet extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<AppThemePreference>? onThemeChanged;
  final ValueChanged<bool>? onScientificModeChanged;

  const SettingsSheet({
    super.key,
    required this.onClose,
    this.onThemeChanged,
    this.onScientificModeChanged,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  final _prefs = CalculatorPreferences.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppTheme.darkBg2, AppTheme.darkBg3]
                  : [AppTheme.lightSurface, AppTheme.lightBg1],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 32,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListenableBuilder(
            listenable: _prefs,
            builder: (context, _) {
              return Column(
                children: [
                  // Drag handle
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryTeal,
                                const Color(0xFF0E7490),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengaturan',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Tersimpan otomatis di perangkat',
                                style: theme.textTheme.bodySmall,
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
                  ),

                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  ),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                      children: [
                        // ── Tampilan ────────────────────────────────────────
                        _SectionHeader(title: 'Tampilan', isDark: isDark),
                        const SizedBox(height: 8),
                        _SettingsCard(
                          isDark: isDark,
                          children: [
                            _ThemeTile(
                              pref: _prefs.themePreference,
                              onTap: () => _pickTheme(context),
                            ),
                            _Divider(),
                            _FontSizeTile(prefs: _prefs),
                            _Divider(),
                            _SwitchTile(
                              icon: Icons.grid_3x3_rounded,
                              title: 'Pemisah ribuan',
                              subtitle: '1.000.000 vs 1000000',
                              value: _prefs.thousandSeparator,
                              onChanged: (v) => _prefs.setThousandSeparator(v),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Perhitungan ─────────────────────────────────────
                        _SectionHeader(title: 'Perhitungan', isDark: isDark),
                        const SizedBox(height: 8),
                        _SettingsCard(
                          isDark: isDark,
                          children: [
                            _DecimalSliderTile(prefs: _prefs),
                            _Divider(),
                            _TrigModeTile(prefs: _prefs),
                            _Divider(),
                            _SwitchTile(
                              icon: Icons.superscript_rounded,
                              title: 'Notasi ilmiah',
                              subtitle: 'Angka besar otomatis (1.5×10⁶)',
                              value: _prefs.scientificNotation,
                              onChanged: (v) => _prefs.setScientificNotation(v),
                            ),
                            _Divider(),
                            _SwitchTile(
                              icon: Icons.calculate_rounded,
                              title: 'Buka mode scientific',
                              subtitle: 'Default saat app dibuka',
                              value: _prefs.scientificOnStart,
                              onChanged: (v) {
                                _prefs.setScientificOnStart(v);
                                widget.onScientificModeChanged?.call(v);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Interaksi ───────────────────────────────────────
                        _SectionHeader(title: 'Interaksi', isDark: isDark),
                        const SizedBox(height: 8),
                        _SettingsCard(
                          isDark: isDark,
                          children: [
                            _SwitchTile(
                              icon: Icons.vibration_rounded,
                              title: 'Getaran haptik',
                              subtitle: 'Feedback saat menekan tombol',
                              value: _prefs.hapticEnabled,
                              onChanged: (v) => _prefs.setHapticEnabled(v),
                            ),
                            _Divider(),
                            _SwitchTile(
                              icon: Icons.content_copy_rounded,
                              title: 'Salin hasil otomatis',
                              subtitle: 'Setelah menekan tombol =',
                              value: _prefs.autoCopyResult,
                              onChanged: (v) => _prefs.setAutoCopyResult(v),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Riwayat ─────────────────────────────────────────
                        _SectionHeader(title: 'Riwayat', isDark: isDark),
                        const SizedBox(height: 8),
                        _SettingsCard(
                          isDark: isDark,
                          children: [
                            _MaxHistoryTile(prefs: _prefs),
                            _Divider(),
                            _SwitchTile(
                              icon: Icons.delete_outline_rounded,
                              title: 'Konfirmasi hapus',
                              subtitle: 'Tanya sebelum hapus semua riwayat',
                              value: _prefs.confirmClearHistory,
                              onChanged: (v) => _prefs.setConfirmClearHistory(v),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Reset button
                        OutlinedButton.icon(
                          onPressed: () => _confirmReset(context),
                          icon: const Icon(Icons.restore_rounded, size: 18),
                          label: const Text('Reset semua pengaturan'),
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
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickTheme(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final picked = await showModalBottomSheet<AppThemePreference>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor:
          isDark ? AppTheme.darkBg2 : AppTheme.lightSurface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Pilih Tema',
                style: theme.textTheme.titleMedium,
              ),
            ),
            for (final p in AppThemePreference.values)
              ListTile(
                leading: Icon(_themeIcon(p)),
                title: Text(_themeLabel(p)),
                selected: _prefs.themePreference == p,
                selectedColor: isDark
                    ? AppTheme.primaryTealDark
                    : AppTheme.primaryTeal,
                onTap: () => Navigator.pop(ctx, p),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) {
      await _prefs.setThemePreference(picked);
      widget.onThemeChanged?.call(picked);
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset pengaturan?'),
        content: const Text(
          'Semua pengaturan akan dikembalikan ke default. Riwayat tidak terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _prefs.resetToDefaults();
    }
  }

  String _themeLabel(AppThemePreference p) => switch (p) {
        AppThemePreference.system => 'Ikuti sistem',
        AppThemePreference.light => 'Terang',
        AppThemePreference.dark => 'Gelap',
      };

  IconData _themeIcon(AppThemePreference p) => switch (p) {
        AppThemePreference.system => Icons.brightness_auto_rounded,
        AppThemePreference.light => Icons.wb_sunny_rounded,
        AppThemePreference.dark => Icons.dark_mode_rounded,
      };
}

// ─── Reusable Tiles ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurfaceElevated
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppTheme.primaryTealDark.withValues(alpha: 0.08)
              : AppTheme.primaryTeal.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                  : AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal;
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return (isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal)
                    .withValues(alpha: 0.4);
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final AppThemePreference pref;
  final VoidCallback onTap;

  const _ThemeTile({required this.pref, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final label = switch (pref) {
      AppThemePreference.system => 'Ikuti sistem',
      AppThemePreference.light => 'Terang',
      AppThemePreference.dark => 'Gelap',
    };
    final icon = switch (pref) {
      AppThemePreference.system => Icons.brightness_auto_rounded,
      AppThemePreference.light => Icons.wb_sunny_rounded,
      AppThemePreference.dark => Icons.dark_mode_rounded,
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                    : AppTheme.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.brightness_6_rounded,
                  size: 18, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema aplikasi', style: theme.textTheme.titleSmall),
                  Text(label, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _FontSizeTile extends StatelessWidget {
  final CalculatorPreferences prefs;
  const _FontSizeTile({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final label = prefs.displayFontSize <= 44
        ? 'Kecil'
        : prefs.displayFontSize <= 56
            ? 'Sedang'
            : prefs.displayFontSize <= 64
                ? 'Besar'
                : 'Sangat besar';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                      : AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.text_fields_rounded,
                    size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ukuran angka', style: theme.textTheme.titleSmall),
                    Text(label, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${prefs.displayFontSize.round()}px',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: prefs.displayFontSize,
            min: 40,
            max: 72,
            divisions: 8,
            activeColor: isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal,
            onChanged: (v) => prefs.setDisplayFontSize(v),
          ),
        ],
      ),
    );
  }
}

class _DecimalSliderTile extends StatelessWidget {
  final CalculatorPreferences prefs;
  const _DecimalSliderTile({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                      : AppTheme.primaryTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pin_rounded,
                    size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Angka desimal', style: theme.textTheme.titleSmall),
                    Text(
                      'Contoh: 1.${'2' * prefs.decimalPlaces}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${prefs.decimalPlaces}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: prefs.decimalPlaces.toDouble(),
            min: 0,
            max: 8,
            divisions: 8,
            activeColor: isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal,
            onChanged: (v) => prefs.setDecimalPlaces(v.round()),
          ),
        ],
      ),
    );
  }
}

class _TrigModeTile extends StatelessWidget {
  final CalculatorPreferences prefs;
  const _TrigModeTile({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                  : AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.functions_rounded,
                size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trigonometri', style: theme.textTheme.titleSmall),
                Text(
                  prefs.useDegrees ? 'Derajat (°)' : 'Radian (rad)',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('°')),
              ButtonSegment(value: false, label: Text('rad')),
            ],
            selected: {prefs.useDegrees},
            onSelectionChanged: (s) => prefs.setUseDegrees(s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: isDark
                  ? AppTheme.primaryTeal.withValues(alpha: 0.3)
                  : AppTheme.primaryTeal,
              selectedForegroundColor:
                  isDark ? AppTheme.primaryTealDark : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MaxHistoryTile extends StatelessWidget {
  final CalculatorPreferences prefs;
  const _MaxHistoryTile({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryTeal.withValues(alpha: 0.12)
                  : AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.history_rounded,
                size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maks. riwayat', style: theme.textTheme.titleSmall),
                Text(
                  '${prefs.maxHistoryItems} perhitungan',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          DropdownButton<int>(
            value: prefs.maxHistoryItems,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(14),
            items: const [25, 50, 100, 200]
                .map(
                  (n) => DropdownMenuItem(
                    value: n,
                    child: Text('$n'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) prefs.setMaxHistoryItems(v);
            },
          ),
        ],
      ),
    );
  }
}
