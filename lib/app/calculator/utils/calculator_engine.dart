import '../models/operator.dart';
import 'number_formatting.dart';

class CalculatorEngine {
  double calculate(double first, double second, Operator op) {
    switch (op) {
      case Operator.add:
        return first + second;
      case Operator.subtract:
        return first - second;
      case Operator.multiply:
        return first * second;
      case Operator.divide:
        // Keep behavior similar to original: second !== 0 ? first / second : 0
        return second != 0 ? first / second : 0;
    }
  }

  String opSymbol(Operator op) => op.symbol;

  String displayFormat(String raw) {
    return formatNumber(raw);
  }

  String displayFormatFromDouble(double value) {
    return formatDisplayFromNum(value);
  }

  double parseDisplay(String display) {
    return double.tryParse(display.replaceAll(',', '')) ?? 0.0;
  }
}
