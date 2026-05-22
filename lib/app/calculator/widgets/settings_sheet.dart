import 'package:flutter/material.dart';
import '../utils/calculator_preferences.dart';
import 'sheet_header.dart';

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

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListenableBuilder(
            listenable: _prefs,
            builder: (context, _) {
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  SheetHeader(
                    title: 'Pengaturan',
                    icon: Icons.settings_rounded,
                    onClose: widget.onClose,
                  ),
                  const SizedBox(height: 20),

                  _SettingsSection(
                    title: 'Tampilan',
                    children: [
                      _SettingsTile(
                        icon: Icons.brightness_6_rounded,
                        title: 'Tema aplikasi',
                        subtitle: _themeLabel(_prefs.themePreference),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _pickTheme(context),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.text_fields_rounded,
                        title: 'Ukuran angka hasil',
                        subtitle: _displaySizeLabel(_prefs.displayFontSize),
                        trailing: SizedBox(
                          width: 160,
                          child: Slider(
                            value: _prefs.displayFontSize,
                            min: 40,
                            max: 72,
                            divisions: 4,
                            label: _displaySizeLabel(_prefs.displayFontSize),
                            onChanged: (v) => _prefs.setDisplayFontSize(v),
                          ),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.grid_3x3_rounded,
                        title: 'Pemisah ribuan',
                        subtitle: '1.000.000 vs 1000000',
                        trailing: Switch.adaptive(
                          value: _prefs.thousandSeparator,
                          onChanged: _prefs.setThousandSeparator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _SettingsSection(
                    title: 'Perhitungan',
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Angka desimal',
                                  style: theme.textTheme.titleSmall,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_prefs.decimalPlaces}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Slider(
                              value: _prefs.decimalPlaces.toDouble(),
                              min: 0,
                              max: 8,
                              divisions: 8,
                              onChanged: (v) =>
                                  _prefs.setDecimalPlaces(v.toInt()),
                            ),
                            Text(
                              'Contoh: 1.${List.filled(_prefs.decimalPlaces, '2').join()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 16),
                      _SettingsTile(
                        icon: Icons.functions_rounded,
                        title: 'Trigonometri',
                        subtitle: _prefs.useDegrees
                            ? 'Derajat (°)'
                            : 'Radian (rad)',
                        trailing: SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: true, label: Text('°')),
                            ButtonSegment(value: false, label: Text('rad')),
                          ],
                          selected: {_prefs.useDegrees},
                          onSelectionChanged: (s) =>
                              _prefs.setUseDegrees(s.first),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.superscript_rounded,
                        title: 'Notasi ilmiah',
                        subtitle: 'Angka sangat besar/kecil (1e10)',
                        trailing: Switch.adaptive(
                          value: _prefs.scientificNotation,
                          onChanged: _prefs.setScientificNotation,
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.calculate_rounded,
                        title: 'Buka mode scientific',
                        subtitle: 'Saat aplikasi dibuka',
                        trailing: Switch.adaptive(
                          value: _prefs.scientificOnStart,
                          onChanged: (v) async {
                            await _prefs.setScientificOnStart(v);
                            widget.onScientificModeChanged?.call(v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _SettingsSection(
                    title: 'Interaksi',
                    children: [
                      _SettingsTile(
                        icon: Icons.vibration_rounded,
                        title: 'Getaran haptik',
                        subtitle: 'Saat menekan tombol',
                        trailing: Switch.adaptive(
                          value: _prefs.hapticEnabled,
                          onChanged: _prefs.setHapticEnabled,
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.content_copy_rounded,
                        title: 'Salin hasil otomatis',
                        subtitle: 'Setelah menekan =',
                        trailing: Switch.adaptive(
                          value: _prefs.autoCopyResult,
                          onChanged: _prefs.setAutoCopyResult,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _SettingsSection(
                    title: 'Riwayat',
                    children: [
                      _SettingsTile(
                        icon: Icons.history_rounded,
                        title: 'Maks. item riwayat',
                        subtitle: '${_prefs.maxHistoryItems} perhitungan',
                        trailing: DropdownButton<int>(
                          value: _prefs.maxHistoryItems,
                          underline: const SizedBox.shrink(),
                          items: const [10, 25, 50, 100]
                              .map(
                                (n) => DropdownMenuItem(
                                  value: n,
                                  child: Text('$n'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) _prefs.setMaxHistoryItems(v);
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Konfirmasi hapus riwayat',
                        subtitle: 'Tanya sebelum menghapus semua',
                        trailing: Switch.adaptive(
                          value: _prefs.confirmClearHistory,
                          onChanged: _prefs.setConfirmClearHistory,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'Pengaturan disimpan otomatis di perangkat Anda.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
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

  String _themeLabel(AppThemePreference p) {
    switch (p) {
      case AppThemePreference.system:
        return 'Ikuti sistem';
      case AppThemePreference.light:
        return 'Terang';
      case AppThemePreference.dark:
        return 'Gelap';
    }
  }

  String _displaySizeLabel(double size) {
    if (size <= 44) return 'Kecil';
    if (size <= 56) return 'Sedang';
    if (size <= 64) return 'Besar';
    return 'Sangat besar';
  }

  Future<void> _pickTheme(BuildContext context) async {
    final picked = await showModalBottomSheet<AppThemePreference>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto_rounded),
              title: const Text('Ikuti sistem'),
              onTap: () => Navigator.pop(ctx, AppThemePreference.system),
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Terang'),
              onTap: () => Navigator.pop(ctx, AppThemePreference.light),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Gelap'),
              onTap: () => Navigator.pop(ctx, AppThemePreference.dark),
            ),
          ],
        ),
      ),
    );
    if (picked != null) {
      await _prefs.setThemePreference(picked);
      widget.onThemeChanged?.call(picked);
    }
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}
