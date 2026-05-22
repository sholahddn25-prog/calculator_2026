import 'package:flutter/material.dart';
import '../utils/unit_converter.dart';
import 'sheet_header.dart';

class ConverterSheet extends StatefulWidget {
  final VoidCallback onClose;

  const ConverterSheet({super.key, required this.onClose});

  @override
  State<ConverterSheet> createState() => _ConverterSheetState();
}

class _ConverterSheetState extends State<ConverterSheet> {
  final converter = UnitConverter();
  int selectedCategory = 0;

  final inputController = TextEditingController();
  String outputValue = '0';
  String selectedFromUnit = 'm';
  String selectedToUnit = 'cm';

  final List<List<String>> categories = [
    ['mm', 'cm', 'm', 'km', 'in', 'ft', 'yd', 'mi'],
    ['mg', 'g', 'kg', 'lb', 'oz', 'ton'],
    ['ml', 'l', 'gal', 'pt', 'cup', 'floz'],
    ['°C', '°F', 'K'],
  ];

  final List<String> categoryNames = [
    'Panjang',
    'Berat',
    'Volume',
    'Suhu',
  ];

  final List<IconData> categoryIcons = [
    Icons.straighten_rounded,
    Icons.scale_rounded,
    Icons.water_drop_outlined,
    Icons.thermostat_rounded,
  ];

  @override
  void initState() {
    super.initState();
    inputController.addListener(_convert);
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = double.tryParse(inputController.text) ?? 0;
    double result = 0;

    switch (selectedCategory) {
      case 0:
        result = converter.convertLength(
          input,
          selectedFromUnit,
          selectedToUnit,
        );
      case 1:
        result = converter.convertWeight(
          input,
          selectedFromUnit,
          selectedToUnit,
        );
      case 2:
        result = converter.convertVolume(
          input,
          selectedFromUnit,
          selectedToUnit,
        );
      case 3:
        result = _convertTemperature(input);
    }

    setState(() {
      outputValue = result
          .toStringAsFixed(6)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    });
  }

  void _swapUnits() {
    setState(() {
      final temp = selectedFromUnit;
      selectedFromUnit = selectedToUnit;
      selectedToUnit = temp;
      _convert();
    });
  }

  double _convertTemperature(double value) {
    if (selectedFromUnit == selectedToUnit) return value;

    if (selectedFromUnit == '°C') {
      return selectedToUnit == '°F'
          ? converter.celsiusToFahrenheit(value)
          : converter.celsiusToKelvin(value);
    } else if (selectedFromUnit == '°F') {
      return selectedToUnit == '°C'
          ? converter.fahrenheitToCelsius(value)
          : converter.fahrenheitToKelvin(value);
    } else {
      return selectedToUnit == '°C'
          ? converter.kelvinToCelsius(value)
          : converter.kelvinToFahrenheit(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
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
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SheetHeader(
                title: 'Konverter',
                icon: Icons.swap_horiz_rounded,
                onClose: widget.onClose,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryNames.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedCategory == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: Icon(
                          categoryIcons[index],
                          size: 18,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        label: Text(categoryNames[index]),
                        selected: isSelected,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = index;
                            selectedFromUnit = categories[index][0];
                            selectedToUnit = categories[index].length > 1
                                ? categories[index][1]
                                : categories[index][0];
                            inputController.clear();
                            _convert();
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _ConverterField(
                label: 'Dari',
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: inputController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(hintText: '0'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _UnitDropdown(
                      value: selectedFromUnit,
                      units: categories[selectedCategory],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedFromUnit = value;
                            _convert();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: IconButton.filled(
                  onPressed: _swapUnits,
                  icon: const Icon(Icons.swap_vert_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ConverterField(
                label: 'Ke',
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          outputValue,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _UnitDropdown(
                      value: selectedToUnit,
                      units: categories[selectedCategory],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedToUnit = value;
                            _convert();
                          });
                        }
                      },
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
}

class _ConverterField extends StatelessWidget {
  final String label;
  final Widget child;

  const _ConverterField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final String value;
  final List<String> units;
  final ValueChanged<String?> onChanged;

  const _UnitDropdown({
    required this.value,
    required this.units,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        items: units
            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
