extension DoubleExtension on double {
  String toCurrency({String symbol = '\$'}) {
    return '$symbol${toStringAsFixed(2)}';
  }

  double roundTo(int decimals) {
    final mod = _pow10(decimals);
    return (this * mod).round() / mod;
  }

  double _pow10(int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) { result *= 10; }
    return result;
  }
}
