enum Operator { add, subtract, multiply, divide }

extension OperatorX on Operator {
  String get symbol {
    switch (this) {
      case Operator.add:
        return '+';
      case Operator.subtract:
        return '-';
      case Operator.multiply:
        return '×';
      case Operator.divide:
        return '÷';
    }
  }
}
