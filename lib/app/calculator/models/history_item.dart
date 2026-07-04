class HistoryItem {
  final String id;
  final String calculation;
  final String result;
  final DateTime timestamp;

  const HistoryItem({
    required this.id,
    required this.calculation,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'calculation': calculation,
        'result': result,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory HistoryItem.fromMap(Map<String, dynamic> map) => HistoryItem(
        id: map['id'] as String,
        calculation: map['calculation'] as String,
        result: map['result'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HistoryItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
