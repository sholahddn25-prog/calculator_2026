enum Operator { add, subtract, multiply, divide }

extension OperatorX on Operator {
  String get symbol {
    switch (this) {
      case Operator.add:
        return '+';
      case Operator.subtract:
        return '-';
      case Operator.multiply:
        return '\u00d7';
      case Operator.divide:
        return '\u00f7';
    }
  }
}
