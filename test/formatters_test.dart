import 'package:flutter_test/flutter_test.dart';
import 'package:duescan/utils/formatters.dart';

void main() {
  test('Formatters.price', () {
    expect(Formatters.price(1.234567), '1.2346');
    expect(Formatters.price(0.1234567), '0.123457');
  });

  test('Formatters.fiat', () {
    expect(Formatters.fiat(123), '\$123.00');
    expect(Formatters.fiat(12345), '\$12.35K');
    expect(Formatters.fiat(12345678), '\$12.35M');
  });

  test('Formatters.pct', () {
    expect(Formatters.pct(1.234), '+1.23%');
    expect(Formatters.pct(-2.5), '-2.50%');
  });
}
