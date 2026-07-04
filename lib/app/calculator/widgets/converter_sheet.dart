import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/unit_converter.dart';

/// Converter sheet premium dengan desain card-based dan animasi swap.
class ConverterSheet extends StatefulWidget {
  final VoidCallback onClose;

  const ConverterSheet({super.key, required this.onClose});

  @override
  State<ConverterSheet> createState() => _ConverterSheetState();
}

class _ConverterSheetState extends State<ConverterSheet>
    with SingleTickerProviderStateMixin {
  static const _celsius = '°C';
  static const _fahrenheit = '°F';

  final _converter = UnitConverter();
  final _inputController = TextEditingController();
  late AnimationController _swapController;
  late Animation<double> _swapAnim;

  int _selectedCategory = 0;
  String _outputValue = '0';
  String _fromUnit = 'm';
  String _toUnit = 'cm';

  final List<List<String>> _categories = const [
    ['mm', 'cm', 'm', 'km', 'in', 'ft', 'yd', 'mi'],
    ['mg', 'g', 'kg', 'lb', 'oz', 'ton'],
    ['ml', 'l', 'gal', 'pt', 'cup', 'fl oz'],
    [_celsius, _fahrenheit, 'K'],
  ];

  final _categoryNames = const ['Panjang', 'Berat', 'Volume', 'Suhu'];
  final _categoryIcons = const [
    Icons.straighten_rounded,
    Icons.scale_rounded,
    Icons.water_drop_outlined,
    Icons.thermostat_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _swapAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeOutBack),
    );
    _inputController.addListener(_convert);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = double.tryParse(_inputController.text) ?? 0;
    final result = switch (_selectedCategory) {
      0 => _converter.convertLength(input, _fromUnit, _toUnit),
      1 => _converter.convertWeight(input, _fromUnit, _toUnit),
      2 => _converter.convertVolume(input, _fromUnit, _toUnit),
      3 => _convertTemperature(input),
      _ => input,
    };

    final s = result
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');

    setState(() => _outputValue = s.isEmpty ? '0' : s);
  }

  Future<void> _swapUnits() async {
    await _swapController.forward(from: 0);
    setState(() {
      final tmp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tmp;
    });
    _convert();
    _swapController.reverse();
  }

  double _convertTemperature(double v) {
    if (_fromUnit == _toUnit) return v;
    if (_fromUnit == _celsius) {
      return _toUnit == _fahrenheit
          ? _converter.celsiusToFahrenheit(v)
          : _converter.celsiusToKelvin(v);
    }
    if (_fromUnit == _fahrenheit) {
      return _toUnit == _celsius
          ? _converter.fahrenheitToCelsius(v)
          : _converter.fahrenheitToKelvin(v);
    }
    return _toUnit == _celsius
        ? _converter.kelvinToCelsius(v)
        : _converter.kelvinToFahrenheit(v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
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
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                blurRadius: 32,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
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
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryTeal, Color(0xFF0E7490)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Konverter Satuan',
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
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    // Category chips
                    SizedBox(
                      height: 46,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categoryNames.length,
                        itemBuilder: (context, i) {
                          final selected = _selectedCategory == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? LinearGradient(
                                        colors: isDark
                                            ? [
                                                AppTheme.primaryTeal,
                                                const Color(0xFF0E7490),
                                              ]
                                            : [
                                                AppTheme.primaryTeal,
                                                const Color(0xFF065F56),
                                              ],
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
                                          ? AppTheme.primaryTealDark
                                              .withValues(alpha: 0.1)
                                          : AppTheme.primaryTeal
                                              .withValues(alpha: 0.15),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = i;
                                      _fromUnit = _categories[i][0];
                                      _toUnit = _categories[i][1];
                                      _inputController.clear();
                                      _outputValue = '0';
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _categoryIcons[i],
                                          size: 16,
                                          color: selected
                                              ? Colors.white
                                              : isDark
                                                  ? AppTheme.primaryTealDark
                                                  : AppTheme.primaryTeal,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _categoryNames[i],
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
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Input card
                    _ConverterCard(
                      label: 'Dari',
                      isDark: isDark,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                                fontFamily: 'PlusJakartaSans',
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _UnitDropdown(
                            value: _fromUnit,
                            units: _categories[_selectedCategory],
                            isDark: isDark,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _fromUnit = v);
                              _convert();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Swap button
                    Center(
                      child: AnimatedBuilder(
                        animation: _swapAnim,
                        builder: (_, child) => Transform.rotate(
                          angle: _swapAnim.value * 3.14159,
                          child: child,
                        ),
                        child: GestureDetector(
                          onTap: _swapUnits,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        AppTheme.primaryTeal,
                                        const Color(0xFF0E7490),
                                      ]
                                    : [
                                        AppTheme.primaryTeal,
                                        const Color(0xFF065F56),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryTeal
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.swap_vert_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Output card
                    _ConverterCard(
                      label: 'Ke',
                      isDark: isDark,
                      isOutput: true,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _outputValue,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppTheme.primaryTealDark
                                    : AppTheme.primaryTeal,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _UnitDropdown(
                            value: _toUnit,
                            units: _categories[_selectedCategory],
                            isDark: isDark,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _toUnit = v);
                              _convert();
                            },
                          ),
                        ],
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
}

// ─── Converter Card ────────────────────────────────────────────────────────────
class _ConverterCard extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isDark;
  final bool isOutput;

  const _ConverterCard({
    required this.label,
    required this.child,
    required this.isDark,
    this.isOutput = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: isOutput
                ? (isDark
                    ? AppTheme.primaryTeal.withValues(alpha: 0.08)
                    : AppTheme.primaryTeal.withValues(alpha: 0.06))
                : (isDark ? AppTheme.darkSurfaceElevated : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppTheme.primaryTealDark
                      .withValues(alpha: isOutput ? 0.2 : 0.1)
                  : AppTheme.primaryTeal
                      .withValues(alpha: isOutput ? 0.25 : 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

// ─── Unit Dropdown ────────────────────────────────────────────────────────────
class _UnitDropdown extends StatelessWidget {
  final String value;
  final List<String> units;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _UnitDropdown({
    required this.value,
    required this.units,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryTeal.withValues(alpha: 0.12)
            : AppTheme.primaryTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppTheme.primaryTealDark.withValues(alpha: 0.2)
              : AppTheme.primaryTeal.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          borderRadius: BorderRadius.circular(14),
          dropdownColor: isDark ? AppTheme.darkBg2 : AppTheme.lightSurface,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal,
            fontFamily: 'PlusJakartaSans',
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: isDark ? AppTheme.primaryTealDark : AppTheme.primaryTeal,
          ),
          items: units
              .map(
                (u) => DropdownMenuItem(
                  value: u,
                  child: Text(u),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
