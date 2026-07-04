/// Hasil operasi kalkulator — nilai atau pesan error.
class CalcResult {
  final double? value;
  final String? errorMessage;

  const CalcResult._({this.value, this.errorMessage});

  factory CalcResult.ok(double value) => CalcResult._(value: value);

  factory CalcResult.error(String message) =>
      CalcResult._(errorMessage: message);

  bool get isError => errorMessage != null;
  bool get isOk => value != null && !isError;
}
