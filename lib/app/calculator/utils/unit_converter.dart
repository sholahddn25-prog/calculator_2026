class UnitConverter {
  // Length conversions (to meters)
  static const double mm_to_m = 0.001;
  static const double cm_to_m = 0.01;
  static const double km_to_m = 1000;
  static const double inch_to_m = 0.0254;
  static const double foot_to_m = 0.3048;
  static const double yard_to_m = 0.9144;
  static const double mile_to_m = 1609.34;

  // Weight conversions (to kg)
  static const double mg_to_kg = 0.000001;
  static const double g_to_kg = 0.001;
  static const double lb_to_kg = 0.453592;
  static const double oz_to_kg = 0.0283495;
  static const double ton_to_kg = 1000;

  // Volume conversions (to liters)
  static const double ml_to_liter = 0.001;
  static const double gallon_to_liter = 3.78541;
  static const double pint_to_liter = 0.473176;
  static const double cup_to_liter = 0.236588;
  static const double floz_to_liter = 0.0295735;

  // Temperature conversions
  double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;
  double fahrenheitToCelsius(double fahrenheit) => (fahrenheit - 32) * 5 / 9;
  double celsiusToKelvin(double celsius) => celsius + 273.15;
  double kelvinToCelsius(double kelvin) => kelvin - 273.15;
  double fahrenheitToKelvin(double fahrenheit) =>
      (fahrenheit - 32) * 5 / 9 + 273.15;
  double kelvinToFahrenheit(double kelvin) => (kelvin - 273.15) * 9 / 5 + 32;

  // Generic conversion method
  double convertLength(double value, String from, String to) {
    // Convert to meters first
    double meters = _lengthToMeters(value, from);
    // Convert from meters to target
    return _metersToLength(meters, to);
  }

  double convertWeight(double value, String from, String to) {
    double kg = _weightToKg(value, from);
    return _kgToWeight(kg, to);
  }

  double convertVolume(double value, String from, String to) {
    double liters = _volumeToLiters(value, from);
    return _litersToVolume(liters, to);
  }

  // Helper methods
  double _lengthToMeters(double value, String unit) {
    switch (unit.toLowerCase()) {
      case 'mm':
        return value * mm_to_m;
      case 'cm':
        return value * cm_to_m;
      case 'm':
        return value;
      case 'km':
        return value * km_to_m;
      case 'in':
        return value * inch_to_m;
      case 'ft':
        return value * foot_to_m;
      case 'yd':
        return value * yard_to_m;
      case 'mi':
        return value * mile_to_m;
      default:
        return value;
    }
  }

  double _metersToLength(double meters, String unit) {
    switch (unit.toLowerCase()) {
      case 'mm':
        return meters / mm_to_m;
      case 'cm':
        return meters / cm_to_m;
      case 'm':
        return meters;
      case 'km':
        return meters / km_to_m;
      case 'in':
        return meters / inch_to_m;
      case 'ft':
        return meters / foot_to_m;
      case 'yd':
        return meters / yard_to_m;
      case 'mi':
        return meters / mile_to_m;
      default:
        return meters;
    }
  }

  double _weightToKg(double value, String unit) {
    switch (unit.toLowerCase()) {
      case 'mg':
        return value * mg_to_kg;
      case 'g':
        return value * g_to_kg;
      case 'kg':
        return value;
      case 'lb':
        return value * lb_to_kg;
      case 'oz':
        return value * oz_to_kg;
      case 'ton':
        return value * ton_to_kg;
      default:
        return value;
    }
  }

  double _kgToWeight(double kg, String unit) {
    switch (unit.toLowerCase()) {
      case 'mg':
        return kg / mg_to_kg;
      case 'g':
        return kg / g_to_kg;
      case 'kg':
        return kg;
      case 'lb':
        return kg / lb_to_kg;
      case 'oz':
        return kg / oz_to_kg;
      case 'ton':
        return kg / ton_to_kg;
      default:
        return kg;
    }
  }

  double _volumeToLiters(double value, String unit) {
    switch (unit.toLowerCase()) {
      case 'ml':
        return value * ml_to_liter;
      case 'l':
        return value;
      case 'gal':
        return value * gallon_to_liter;
      case 'pt':
        return value * pint_to_liter;
      case 'cup':
        return value * cup_to_liter;
      case 'floz':
        return value * floz_to_liter;
      default:
        return value;
    }
  }

  double _litersToVolume(double liters, String unit) {
    switch (unit.toLowerCase()) {
      case 'ml':
        return liters / ml_to_liter;
      case 'l':
        return liters;
      case 'gal':
        return liters / gallon_to_liter;
      case 'pt':
        return liters / pint_to_liter;
      case 'cup':
        return liters / cup_to_liter;
      case 'floz':
        return liters / floz_to_liter;
      default:
        return liters;
    }
  }
}
