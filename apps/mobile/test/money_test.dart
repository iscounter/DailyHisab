import 'package:flutter_test/flutter_test.dart';
import 'package:dailyhisab/core/utils/money.dart';

void main() {
  group('formatBdtMinor', () {
    test('formats correctly', () {
      expect(formatBdtMinor(1050), '৳10.50');
      expect(formatBdtMinor(0), '৳0.00');
      expect(formatBdtMinor(-1050), '-৳10.50');
      expect(formatBdtMinor(100050), '৳1000.50');
    });
  });

  group('minorToBdtInput', () {
    test('formats plain input string', () {
      expect(minorToBdtInput(10050), '100.50');
      expect(minorToBdtInput(0), '0.00');
      expect(minorToBdtInput(5), '0.05');
      expect(minorToBdtInput(-2575), '-25.75');
    });
  });

  group('parseBdtToMinor', () {
    test('parses whole amounts', () {
      expect(parseBdtToMinor('100'), 10000);
      expect(parseBdtToMinor('0'), 0);
      expect(parseBdtToMinor('1000'), 100000);
    });

    test('parses decimal amounts without float error', () {
      expect(parseBdtToMinor('100.5'), 10050);
      expect(parseBdtToMinor('100.50'), 10050);
      expect(parseBdtToMinor('0.01'), 1);
      expect(parseBdtToMinor('0.1'), 10);
      expect(parseBdtToMinor('1,000.50'), 100050);
    });

    test('handles negatives', () {
      expect(parseBdtToMinor('-25.75'), -2575);
      expect(parseBdtToMinor('-0.50'), -50);
    });

    test('handles surrounding whitespace', () {
      expect(parseBdtToMinor('  42.25  '), 4225);
    });

    test('rejects invalid input', () {
      expect(parseBdtToMinor(''), isNull);
      expect(parseBdtToMinor('abc'), isNull);
      expect(parseBdtToMinor('100.509'), isNull);
      expect(parseBdtToMinor('1.2.3'), isNull);
      expect(parseBdtToMinor('-'), isNull);
      expect(parseBdtToMinor('.'), isNull);
    });

    test('round-trips with minorToBdtInput', () {
      for (final minor in [0, 1, 50, 100, 10050, 100050, 999999]) {
        expect(parseBdtToMinor(minorToBdtInput(minor)), minor);
      }
    });
  });
}
