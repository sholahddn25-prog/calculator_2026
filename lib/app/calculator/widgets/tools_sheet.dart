import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/number_formatting.dart';

enum ToolMode { tip, discount, percentage, programmer }

class ToolsSheet extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<double>? onApplyResult;

  const ToolsSheet({super.key, required this.onClose, this.onApplyResult});

  @override
  State<ToolsSheet> createState() => _ToolsSheetState();
}

class _ToolsSheetState extends State<ToolsSheet> {
  ToolMode mode = ToolMode.tip;
  final amountCtrl = TextEditingController(text: '100000');
  final percentCtrl = TextEditingController(text: '10');
  final peopleCtrl = TextEditingController(text: '1');
  final programmerCtrl = TextEditingController(text: '2026');
  String result = '-';
  int programmerValue = 2026;

  @override
  void initState() {
    super.initState();
    for (final c in [amountCtrl, percentCtrl, peopleCtrl, programmerCtrl]) {
      c.addListener(_calc);
    }
    _calc();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    percentCtrl.dispose();
    peopleCtrl.dispose();
    programmerCtrl.dispose();
    super.dispose();
  }

  void _calc() {
    final amount = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
    final pct = double.tryParse(percentCtrl.text.replaceAll(',', '')) ?? 0;
    final people = (int.tryParse(peopleCtrl.text) ?? 1).clamp(1, 99);

    setState(() {
      switch (mode) {
        case ToolMode.tip:
          final tip = amount * pct / 100;
          final total = amount + tip;
          final perPerson = total / people;
          result =
              'Tip: ${formatDisplayFromNum(tip)}\n'
              'Total: ${formatDisplayFromNum(total)}\n'
              'Per orang: ${formatDisplayFromNum(perPerson)}';
        case ToolMode.discount:
          final disc = amount * pct / 100;
          final finalPrice = amount - disc;
          result =
              'Diskon: ${formatDisplayFromNum(disc)}\n'
              'Harga akhir: ${formatDisplayFromNum(finalPrice)}';
        case ToolMode.percentage:
          final part = amount * pct / 100;
          result =
              '$pct% dari ${formatDisplayFromNum(amount)}\n'
              '= ${formatDisplayFromNum(part)}';
        case ToolMode.programmer:
          programmerValue = _parseProgrammer(programmerCtrl.text);
          result =
              'DEC: $programmerValue\n'
              'HEX: 0x${programmerValue.toRadixString(16).toUpperCase()}\n'
              'BIN: 0b${programmerValue.toRadixString(2)}\n'
              'OCT: 0o${programmerValue.toRadixString(8)}';
      }
    });
  }

  int _parseProgrammer(String raw) {
    final s = raw.trim().replaceAll('_', '').replaceAll(' ', '');
    if (s.isEmpty) return 0;
    if (s.startsWith('0x') || s.startsWith('0X')) {
      return int.tryParse(s.substring(2), radix: 16) ?? 0;
    }
    if (s.startsWith('0b') || s.startsWith('0B')) {
      return int.tryParse(s.substring(2), radix: 2) ?? 0;
    }
    if (s.startsWith('0o') || s.startsWith('0O')) {
      return int.tryParse(s.substring(2), radix: 8) ?? 0;
    }
    return int.tryParse(s) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, scroll) {
        final isDark = theme.brightness == Brightness.dark;
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
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                blurRadius: 32,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryTeal, Color(0xFF0E7490)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.handyman_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Alat Praktis',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
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
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
              const SizedBox(height: 0),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ModeChip(
                      label: 'Tip',
                      icon: Icons.restaurant_rounded,
                      selected: mode == ToolMode.tip,
                      onTap: () => _setMode(ToolMode.tip),
                    ),
                    _ModeChip(
                      label: 'Diskon',
                      icon: Icons.sell_rounded,
                      selected: mode == ToolMode.discount,
                      onTap: () => _setMode(ToolMode.discount),
                    ),
                    _ModeChip(
                      label: '% dari',
                      icon: Icons.percent_rounded,
                      selected: mode == ToolMode.percentage,
                      onTap: () => _setMode(ToolMode.percentage),
                    ),
                    _ModeChip(
                      label: 'Programmer',
                      icon: Icons.code_rounded,
                      selected: mode == ToolMode.programmer,
                      onTap: () => _setMode(ToolMode.programmer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: mode == ToolMode.programmer
                    ? _ProgrammerInputs(
                        key: const ValueKey('programmer'),
                        controller: programmerCtrl,
                        value: programmerValue,
                      )
                    : _FinanceInputs(
                        key: ValueKey(mode),
                        mode: mode,
                        amountCtrl: amountCtrl,
                        percentCtrl: percentCtrl,
                        peopleCtrl: peopleCtrl,
                      ),
              ),
              const SizedBox(height: 20),
              _ResultPanel(result: result),
              if (mode == ToolMode.programmer) ...[
                const SizedBox(height: 16),
                _LanguageLiteralGrid(value: programmerValue),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    final v = mode == ToolMode.programmer
                        ? programmerValue.toDouble()
                        : _lastNumberFromResult();
                    widget.onApplyResult?.call(v);
                    widget.onClose();
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Gunakan hasil di kalkulator'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _setMode(ToolMode next) {
    setState(() => mode = next);
    _calc();
  }

  double _lastNumberFromResult() {
    final line = result.split('\n').last;
    final numStr = line.replaceAll(RegExp(r'[^0-9.,-]'), '');
    return double.tryParse(numStr.replaceAll(',', '')) ?? 0;
  }
}

class _FinanceInputs extends StatelessWidget {
  final ToolMode mode;
  final TextEditingController amountCtrl;
  final TextEditingController percentCtrl;
  final TextEditingController peopleCtrl;

  const _FinanceInputs({
    super.key,
    required this.mode,
    required this.amountCtrl,
    required this.percentCtrl,
    required this.peopleCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: mode == ToolMode.percentage ? 'Nilai dasar' : 'Jumlah',
            prefixIcon: const Icon(Icons.payments_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: percentCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: mode == ToolMode.discount ? 'Diskon (%)' : 'Persen (%)',
            prefixIcon: const Icon(Icons.percent_rounded),
          ),
        ),
        if (mode == ToolMode.tip) ...[
          const SizedBox(height: 12),
          TextField(
            controller: peopleCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah orang',
              prefixIcon: Icon(Icons.group_rounded),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProgrammerInputs extends StatelessWidget {
  final TextEditingController controller;
  final int value;

  const _ProgrammerInputs({
    super.key,
    required this.controller,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Angka, 0xHEX, 0bBIN, atau 0oOCT',
            prefixIcon: Icon(Icons.terminal_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MiniStat(label: 'byte', value: '${value.bitLength} bit'),
            _MiniStat(label: 'signed', value: value.isNegative ? 'neg' : 'pos'),
            _MiniStat(label: 'parity', value: value.isEven ? 'even' : 'odd'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Format input mendukung style yang biasa dipakai di banyak bahasa pemrograman.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LanguageLiteralGrid extends StatelessWidget {
  final int value;

  const _LanguageLiteralGrid({required this.value});

  @override
  Widget build(BuildContext context) {
    final hex = '0x${value.toRadixString(16).toUpperCase()}';
    final bin = '0b${value.toRadixString(2)}';
    final rows = <(String, String)>[
      ('Dart', 'final n = $hex;'),
      ('JavaScript', 'const n = $bin;'),
      ('Python', 'n = $hex'),
      ('Kotlin', 'val n = $hex'),
      ('Swift', 'let n = $hex'),
      ('Rust', 'let n = $hex;'),
      ('C#', 'var n = $hex;'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Literal lintas bahasa',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        ...rows.map((row) => _LiteralTile(language: row.$1, code: row.$2)),
      ],
    );
  }
}

class _LiteralTile extends StatelessWidget {
  final String language;
  final String code;

  const _LiteralTile({required this.language, required this.code});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.78,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              language,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              code,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String result;

  const _ResultPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.95),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.54),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        result,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.5,
          letterSpacing: 0,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: isDark
                        ? [AppTheme.primaryTeal, const Color(0xFF0E7490)]
                        : [AppTheme.primaryTeal, const Color(0xFF065F56)],
                  )
                : null,
            color: selected
                ? null
                : isDark
                    ? AppTheme.darkSurfaceElevated
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : isDark
                      ? AppTheme.primaryTealDark.withValues(alpha: 0.1)
                      : AppTheme.primaryTeal.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? Colors.white
                    : isDark
                        ? AppTheme.primaryTealDark
                        : AppTheme.primaryTeal,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : isDark
                          ? AppTheme.primaryTealDark
                          : AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
