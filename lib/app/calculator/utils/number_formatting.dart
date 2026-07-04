import 'calculator_preferences.dart';

String formatNumber(String raw) {
  final prefs = CalculatorPreferences.instance;
  final num? parsed = num.tryParse(raw.replaceAll(',', ''));
  if (parsed == null) return raw;
  return _formatValue(parsed, prefs);
}

String formatDisplayFromNum(num value) {
  return _formatValue(value, CalculatorPreferences.instance);
}

String _formatValue(num value, CalculatorPreferences prefs) {
  if (prefs.scientificNotation && _shouldUseSciNotation(value)) {
    return _formatScientific(value, prefs);
  }

  final formatter = NumberFormatter(
    maxFractionDigits: prefs.decimalPlaces,
    useThousandsSeparator: prefs.thousandSeparator,
  );
  return formatter.format(value);
}

bool _shouldUseSciNotation(num value) {
  if (value == 0) return false;
  final abs = value.abs();
  return abs >= 1e10 || (abs > 0 && abs < 1e-6);
}

String _formatScientific(num value, CalculatorPreferences prefs) {
  final s = value.toStringAsExponential(prefs.decimalPlaces);
  if (!prefs.thousandSeparator) return s;
  final parts = s.split('e');
  if (parts.length != 2) return s;
  final mantissa = NumberFormatter(
    maxFractionDigits: prefs.decimalPlaces,
    useThousandsSeparator: true,
  ).format(num.tryParse(parts[0]) ?? 0);
  return '${mantissa}e${parts[1]}';
}

class NumberFormatter {
  final int maxFractionDigits;
  final bool useThousandsSeparator;

  NumberFormatter({
    required this.maxFractionDigits,
    this.useThousandsSeparator = true,
  });

  String format(num value) {
    if (value is int && maxFractionDigits == 0) {
      return useThousandsSeparator
          ? _addThousands(value.toString())
          : value.toString();
    }

    final s = value.toStringAsFixed(maxFractionDigits);
    final trimmed = s.contains('.')
        ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
        : s;
    return useThousandsSeparator ? _addThousands(trimmed) : trimmed;
  }

  String _addThousands(String s) {
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    final negative = intPart.startsWith('-');
    final absInt = negative ? intPart.substring(1) : intPart;

    for (int i = 0; i < absInt.length; i++) {
      final idxFromEnd = absInt.length - i;
      buf.write(absInt[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write(',');
      }
    }
    final out = buf.toString();
    if (negative) {
      return '-$out${parts.length > 1 ? '.${parts[1]}' : ''}';
    }
    return out + (parts.length > 1 ? '.${parts[1]}' : '');
  }
}
