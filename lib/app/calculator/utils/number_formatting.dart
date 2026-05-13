String formatNumber(String raw) {
  final num? parsed = num.tryParse(raw.replaceAll(',', ''));
  if (parsed == null) return raw;

  // Match the JS behavior: maximumFractionDigits: 8
  final formatter = NumberFormatter(maxFractionDigits: 8);
  return formatter.format(parsed);
}

String formatDisplayFromNum(num value) {
  final formatter = NumberFormatter(maxFractionDigits: 8);
  return formatter.format(value);
}

class NumberFormatter {
  final int maxFractionDigits;

  NumberFormatter({required this.maxFractionDigits});

  String format(num value) {
    // Avoid intl dependency: simple formatting with fixed decimals trimming.
    // This is "good enough" for calculator display.
    if (value is int) return value.toString();

    final s = value.toStringAsFixed(maxFractionDigits);
    // Trim trailing zeros
    final trimmed = s.contains('.')
        ? s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
        : s;
    return _addThousands(trimmed);
  }

  String _addThousands(String s) {
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    bool negative = intPart.startsWith('-');
    final absInt = negative ? intPart.substring(1) : intPart;

    for (int i = 0; i < absInt.length; i++) {
      final idxFromEnd = absInt.length - i;
      buf.write(absInt[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write(',');
      }
    }
    final out = buf.toString();
    if (negative) return '-$out${parts.length > 1 ? '.${parts[1]}' : ''}';
    return out + (parts.length > 1 ? '.${parts[1]}' : '');
  }
}
