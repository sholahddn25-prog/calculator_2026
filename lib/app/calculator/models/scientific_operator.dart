enum ScientificOperator {
  sine,
  cosine,
  tangent,
  arcsin,
  arccos,
  arctan,
  log,
  log10,
  log2,
  sqrt,
  cbrt,
  power,
  factorial,
  reciprocal,
  pi,
  e,
  exp,
}

extension ScientificOperatorX on ScientificOperator {
  String get symbol {
    switch (this) {
      case ScientificOperator.sine:
        return 'sin';
      case ScientificOperator.cosine:
        return 'cos';
      case ScientificOperator.tangent:
        return 'tan';
      case ScientificOperator.arcsin:
        return 'asin';
      case ScientificOperator.arccos:
        return 'acos';
      case ScientificOperator.arctan:
        return 'atan';
      case ScientificOperator.log:
        return 'ln';
      case ScientificOperator.log10:
        return 'log';
      case ScientificOperator.log2:
        return 'log2';
      case ScientificOperator.sqrt:
        return '\u221a';
      case ScientificOperator.cbrt:
        return '\u221b';
      case ScientificOperator.power:
        return 'x^y';
      case ScientificOperator.factorial:
        return 'n!';
      case ScientificOperator.reciprocal:
        return '1/x';
      case ScientificOperator.pi:
        return '\u03c0';
      case ScientificOperator.e:
        return 'e';
      case ScientificOperator.exp:
        return 'e^x';
    }
  }

  String get displayName {
    switch (this) {
      case ScientificOperator.sine:
        return 'sin(x)';
      case ScientificOperator.cosine:
        return 'cos(x)';
      case ScientificOperator.tangent:
        return 'tan(x)';
      case ScientificOperator.arcsin:
        return 'asin(x)';
      case ScientificOperator.arccos:
        return 'acos(x)';
      case ScientificOperator.arctan:
        return 'atan(x)';
      case ScientificOperator.log:
        return 'ln(x)';
      case ScientificOperator.log10:
        return 'log10(x)';
      case ScientificOperator.log2:
        return 'log2(x)';
      case ScientificOperator.sqrt:
        return '\u221ax';
      case ScientificOperator.cbrt:
        return '\u221bx';
      case ScientificOperator.power:
        return 'x^y';
      case ScientificOperator.factorial:
        return 'n!';
      case ScientificOperator.reciprocal:
        return '1/x';
      case ScientificOperator.pi:
        return '\u03c0';
      case ScientificOperator.e:
        return 'e';
      case ScientificOperator.exp:
        return 'e^x';
    }
  }
}
