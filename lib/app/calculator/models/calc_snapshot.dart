import 'operator.dart';

/// Snapshot state untuk fitur undo.
class CalcSnapshot {
  final String display;
  final String history;
  final double? prevValue;
  final Operator? operator;
  final bool waitingForOperand;
  final bool hasError;

  const CalcSnapshot({
    required this.display,
    required this.history,
    this.prevValue,
    this.operator,
    required this.waitingForOperand,
    this.hasError = false,
  });
}
