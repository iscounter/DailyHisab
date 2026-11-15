import 'package:flutter_test/flutter_test.dart';
import 'package:dailyhisab/core/utils/money.dart';

void main() {
  test('formatBdtMinor formats correctly', () {
    expect(formatBdtMinor(1050), '৳10.50');
    expect(formatBdtMinor(0), '৳0.00');
    expect(formatBdtMinor(-1050), '-৳10.50');
  });
}
