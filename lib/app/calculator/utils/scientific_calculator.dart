import 'dart:math';

class ScientificCalculator {
  // Trigonometric functions (radians)
  double sine(double value) => sin(value);
  double cosine(double value) => cos(value);
  double tangent(double value) => tan(value);

  // Inverse trigonometric
  double arcsine(double value) => asin(value);
  double arccosine(double value) => acos(value);
  double arctangent(double value) => atan(value);

  // Logarithmic functions
  double naturalLog(double value) => value > 0 ? log(value) : 0;
  double log10(double value) => value > 0 ? log(value) / log(10) : 0;
  double log2(double value) => value > 0 ? log(value) / log(2) : 0;

  // Exponential functions
  double power(double base, double exponent) => pow(base, exponent).toDouble();
  double squareRoot(double value) => value >= 0 ? sqrt(value) : 0;
  double cubeRoot(double value) => value >= 0
      ? pow(value, 1 / 3).toDouble()
      : -pow(-value, 1 / 3).toDouble();
  double exponential(double value) => exp(value);

  // Factorial
  double factorial(double value) {
    if (value < 0 || value != value.toInt()) return 0;
    int n = value.toInt();
    if (n > 170) return double.infinity;
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  // Absolute value
  double absolute(double value) => value.abs();

  // Percentage
  double percentage(double value) => value / 100;

  // Reciprocal
  double reciprocal(double value) => value != 0 ? 1 / value : 0;

  // Pi constant
  double get pi => 3.141592653589793;

  // Euler's number
  double get e => 2.718281828459045;

  // Degree to Radian conversion
  double degreesToRadians(double degrees) => degrees * (pi / 180);

  // Radian to Degree conversion
  double radiansToDegrees(double radians) => radians * (180 / pi);
}
