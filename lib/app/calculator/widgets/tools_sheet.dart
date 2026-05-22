import 'package:flutter/material.dart';
import '../utils/number_formatting.dart';
import 'sheet_header.dart';

enum ToolMode { tip, discount, percentage }

/// Alat praktis: tip, diskon, persentase.
class ToolsSheet extends StatefulWidget {
  final VoidCallback onClose;
  final ValueChanged<double>? onApplyResult;

  const ToolsSheet({
    super.key,
    required this.onClose,
    this.onApplyResult,
  });

  @override
  State<ToolsSheet> createState() => _ToolsSheetState();
}

class _ToolsSheetState extends State<ToolsSheet> {
  ToolMode mode = ToolMode.tip;
  final amountCtrl = TextEditingController(text: '100000');
  final percentCtrl = TextEditingController(text: '10');
  final peopleCtrl = TextEditingController(text: '1');
  String result = '—';

  @override
  void initState() {
    super.initState();
    for (final c in [amountCtrl, percentCtrl, peopleCtrl]) {
      c.addListener(_calc);
    }
    _calc();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    percentCtrl.dispose();
    peopleCtrl.dispose();
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SheetHeader(
                title: 'Alat Praktis',
                icon: Icons.handyman_rounded,
                onClose: widget.onClose,
              ),
              const SizedBox(height: 16),
              SegmentedButton<ToolMode>(
                segments: const [
                  ButtonSegment(
                    value: ToolMode.tip,
                    label: Text('Tip'),
                    icon: Icon(Icons.restaurant_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: ToolMode.discount,
                    label: Text('Diskon'),
                    icon: Icon(Icons.sell_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: ToolMode.percentage,
                    label: Text('% dari'),
                    icon: Icon(Icons.percent_rounded, size: 18),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (s) {
                  setState(() => mode = s.first);
                  _calc();
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: mode == ToolMode.percentage
                      ? 'Nilai dasar'
                      : 'Jumlah (Rp)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: percentCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: mode == ToolMode.discount
                      ? 'Diskon (%)'
                      : 'Persen (%)',
                ),
              ),
              if (mode == ToolMode.tip) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: peopleCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah orang',
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  result,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  final line = result.split('\n').last;
                  final numStr = line.replaceAll(RegExp(r'[^0-9.,-]'), '');
                  final v = double.tryParse(numStr.replaceAll(',', ''));
                  if (v != null) widget.onApplyResult?.call(v);
                  widget.onClose();
                },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Gunakan hasil di kalkulator'),
              ),
            ],
          ),
        );
      },
    );
  }
}
