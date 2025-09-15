import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String price(num? v) {
    final n = (v ?? 0).toDouble();
    if (n == 0) return '\$0.00';
    if (n >= 1) return '\$${n.toStringAsFixed(4)}';
    if (n >= 0.001) return '\$${n.toStringAsFixed(6)}';
    if (n >= 0.000001) return '\$${n.toStringAsFixed(9)}';
    if (n >= 0.000000001) return '\$${n.toStringAsFixed(12)}';
    return '\$${n.toStringAsExponential(3)}';
  }

  static String fiat(num? v) {
    final n = (v ?? 0).toDouble();
    if (n >= 1e9) return '\$${(n / 1e9).toStringAsFixed(2)}B';
    if (n >= 1e6) return '\$${(n / 1e6).toStringAsFixed(2)}M';
    if (n >= 1e3) return '\$${(n / 1e3).toStringAsFixed(2)}K';
    return '\$${n.toStringAsFixed(2)}';
  }

  static String pct(num? v, {int digits = 2}) {
    final n = (v ?? 0).toDouble();
    final sign = n >= 0 ? '+' : '';
    return '$sign${n.toStringAsFixed(digits)}%';
  }
}
