import 'package:flutter/material.dart';
import '../utils/unit_converter.dart';

class ConverterSheet extends StatefulWidget {
  final VoidCallback onClose;

  const ConverterSheet({super.key, required this.onClose});

  @override
  State<ConverterSheet> createState() => _ConverterSheetState();
}

class _ConverterSheetState extends State<ConverterSheet> {
  final converter = UnitConverter();
  int selectedCategory = 0; // 0: Length, 1: Weight, 2: Volume, 3: Temperature

  final inputController = TextEditingController();
  String outputValue = '0';
  String selectedFromUnit = 'm';
  String selectedToUnit = 'cm';

  final List<List<String>> categories = [
    ['mm', 'cm', 'm', 'km', 'in', 'ft', 'yd', 'mi'], // Length
    ['mg', 'g', 'kg', 'lb', 'oz', 'ton'], // Weight
    ['ml', 'l', 'gal', 'pt', 'cup', 'floz'], // Volume
    ['°C', '°F', 'K'], // Temperature
  ];

  final List<String> categoryNames = [
    'Length',
    'Weight',
    'Volume',
    'Temperature',
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
      case 0: // Length
        result = converter.convertLength(
          input,
          selectedFromUnit,
          selectedToUnit,
        );
        break;
      case 1: // Weight
        result = converter.convertWeight(
          input,
          selectedFromUnit,
          selectedToUnit,
        );
        break;
      case 2: // Volume
        result = converter.convertVolume(
          input,
          selectedFromUnit,
          selectedToUnit,
        );
        break;
      case 3: // Temperature
        result = _convertTemperature(input);
        break;
    }

    setState(() {
      outputValue = result
          .toStringAsFixed(6)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');
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
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Unit Converter',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category selector
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryNames.length,
                  itemBuilder: (context, index) {
                    final isSelected = selectedCategory == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(categoryNames[index]),
                        selected: isSelected,
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

              // Input section
              const Text(
                'From',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: selectedFromUnit,
                    items: categories[selectedCategory]
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
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
              const SizedBox(height: 24),

              // Output section
              const Text(
                'To',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        outputValue,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: selectedToUnit,
                    items: categories[selectedCategory]
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
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
            ],
          ),
        );
      },
    );
  }
}
