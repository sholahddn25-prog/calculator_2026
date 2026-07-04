import '../models/operator.dart';
import 'calc_result.dart';
import 'number_formatting.dart';

class CalculatorEngine {
  CalcResult calculate(double first, double second, Operator op) {
    switch (op) {
      case Operator.add:
        return CalcResult.ok(first + second);
      case Operator.subtract:
        return CalcResult.ok(first - second);
      case Operator.multiply:
        return CalcResult.ok(first * second);
      case Operator.divide:
        if (second == 0) {
          return CalcResult.error('Tidak dapat dibagi nol');
        }
        return CalcResult.ok(first / second);
    }
  }

  /// Pratinjau hasil sebelum menekan =.
  CalcResult? preview(double? first, double second, Operator? op) {
    if (first == null || op == null) return null;
    final r = calculate(first, second, op);
    return r.isOk ? r : null;
  }

  String opSymbol(Operator op) => op.symbol;

  String displayFormat(String raw) {
    if (raw == 'Error') return raw;
    return formatNumber(raw);
  }

  String displayFormatFromDouble(double value) {
    return formatDisplayFromNum(value);
  }

  double parseDisplay(String display) {
    if (display == 'Error') return 0;
    return double.tryParse(display.replaceAll(',', '')) ?? 0.0;
  }

  String formatResultValue(double value) {
    final s = value.toString();
    if (s.contains('e') || s.contains('E')) return s;
    return value == value.truncateToDouble() ? value.truncate().toString() : s;
  }
}
