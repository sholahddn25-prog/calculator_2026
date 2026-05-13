class HistoryItem {
  final String id;
  final String calculation;
  final String result;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.calculation,
    required this.result,
    required this.timestamp,
  });
}
