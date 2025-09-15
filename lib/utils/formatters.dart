import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String price(num? v) {
    final n = (v ?? 0).toDouble();
    if (n == 0) return '\$0.00';
    
    // For very small numbers, show up to 10 decimal places
    if (n < 0.000001) {
      String formatted = n.toStringAsFixed(10);
      // Remove trailing zeros but keep at least 2 decimal places
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      if (formatted.endsWith('.')) formatted += '00';
      if (formatted.split('.')[1].length < 2) formatted += '0';
      return '\$$formatted';
    }
    
    // For small numbers, show appropriate precision
    if (n < 0.01) {
      String formatted = n.toStringAsFixed(8);
      // Remove trailing zeros but keep significant digits
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      if (formatted.endsWith('.')) formatted += '00';
      return '\$$formatted';
    }
    
    // For larger numbers, show 4 decimal places
    return '\$${n.toStringAsFixed(4)}';
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
