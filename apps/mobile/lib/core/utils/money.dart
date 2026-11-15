/// Amounts are stored as integer minor units (e.g. BDT poisha).
String formatBdtMinor(int amountMinor) {
  final negative = amountMinor < 0;
  final abs = amountMinor.abs();
  final major = abs ~/ 100;
  final minor = abs % 100;
  final sign = negative ? '-' : '';
  return '$sign৳$major.${minor.toString().padLeft(2, '0')}';
}

int bdtToMinor(double majorUnits) => (majorUnits * 100).round();
