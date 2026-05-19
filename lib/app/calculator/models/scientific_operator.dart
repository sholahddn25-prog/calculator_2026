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
        return 'sin⁻¹';
      case ScientificOperator.arccos:
        return 'cos⁻¹';
      case ScientificOperator.arctan:
        return 'tan⁻¹';
      case ScientificOperator.log:
        return 'ln';
      case ScientificOperator.log10:
        return 'log';
      case ScientificOperator.log2:
        return 'log₂';
      case ScientificOperator.sqrt:
        return '√';
      case ScientificOperator.cbrt:
        return '∛';
      case ScientificOperator.power:
        return 'xʸ';
      case ScientificOperator.factorial:
        return 'n!';
      case ScientificOperator.reciprocal:
        return '1/x';
      case ScientificOperator.pi:
        return 'π';
      case ScientificOperator.e:
        return 'e';
      case ScientificOperator.exp:
        return 'eˣ';
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
        return 'arcsin(x)';
      case ScientificOperator.arccos:
        return 'arccos(x)';
      case ScientificOperator.arctan:
        return 'arctan(x)';
      case ScientificOperator.log:
        return 'ln(x)';
      case ScientificOperator.log10:
        return 'log10(x)';
      case ScientificOperator.log2:
        return 'log2(x)';
      case ScientificOperator.sqrt:
        return '√x';
      case ScientificOperator.cbrt:
        return '∛x';
      case ScientificOperator.power:
        return 'xʸ';
      case ScientificOperator.factorial:
        return 'n!';
      case ScientificOperator.reciprocal:
        return '1/x';
      case ScientificOperator.pi:
        return 'π';
      case ScientificOperator.e:
        return 'e';
      case ScientificOperator.exp:
        return 'eˣ';
    }
  }
}
