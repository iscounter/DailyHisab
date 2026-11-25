/// Amounts are stored as integer minor units (e.g. BDT poisha).
String formatBdtMinor(int amountMinor) {
  final negative = amountMinor < 0;
  final abs = amountMinor.abs();
  final major = abs ~/ 100;
  final minor = abs % 100;
  final sign = negative ? '-' : '';
  return '$sign৳$major.${minor.toString().padLeft(2, '0')}';
}

/// Legacy helper (kept for compatibility). Prefer [parseBdtToMinor] for user input,
/// which never touches binary floating point.
int bdtToMinor(double majorUnits) => (majorUnits * 100).round();

/// Formats integer poisha as a plain editable input string (no currency symbol),
/// e.g. `10050` -> `"100.50"`. Exact integer math only.
String minorToBdtInput(int amountMinor) {
  final negative = amountMinor < 0;
  final abs = amountMinor.abs();
  final major = abs ~/ 100;
  final minor = abs % 100;
  final sign = negative ? '-' : '';
  return '$sign$major.${minor.toString().padLeft(2, '0')}';
}

/// Parses a user-entered BDT amount string into integer poisha **exactly**, without
/// using binary floating point (PROJECT_ARCHITECTURE.md §6.1).
///
/// Accepted format: optional leading `-`, digits, optional single `.` with 1–2 decimals.
/// Thousands separators (`,`) and surrounding whitespace are ignored.
///
/// Returns `null` for invalid input (empty, non-numeric, more than 2 decimal places, etc.).
///
/// Examples:
///   `"100"`    -> 10000
///   `"100.5"`  -> 10050
///   `"100.50"` -> 10050
///   `"0.01"`   -> 1
///   `"1,000.50"` -> 100050
///   `"-25.75"` -> -2575
///   `"100.509"` -> null (too many decimals)
int? parseBdtToMinor(String input) {
  var s = input.trim().replaceAll(',', '');
  if (s.isEmpty) return null;

  var negative = false;
  if (s.startsWith('-')) {
    negative = true;
    s = s.substring(1);
  }
  if (s.isEmpty) return null;

  final parts = s.split('.');
  if (parts.length > 2) return null;
  // A decimal point must be followed by digits ('.', '100.' are invalid).
  if (parts.length == 2 && parts[1].isEmpty) return null;

  final wholeStr = parts[0].isEmpty ? '0' : parts[0];
  final fracStr = parts.length == 2 ? parts[1] : '';

  if (!_isDigits(wholeStr) || !_isDigits(fracStr)) return null;
  if (fracStr.length > 2) return null;

  final whole = int.tryParse(wholeStr);
  if (whole == null) return null;

  final frac = fracStr.isEmpty ? 0 : int.parse('${fracStr}00'.substring(0, 2));

  var minor = whole * 100 + frac;
  if (negative) minor = -minor;
  return minor;
}

bool _isDigits(String s) {
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    if (c < 48 || c > 57) return false;
  }
  return true;
}
