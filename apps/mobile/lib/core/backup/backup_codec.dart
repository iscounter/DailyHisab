/// Versioned, validated backup format for DailyHisab.
///
/// The codec is pure Dart (no Flutter, no Drift) so it can be unit tested on
/// the host. The repository in `lib/data` maps Drift rows to/from the
/// normalized maps produced here.
///
/// Envelope:
/// ```json
/// {
///   "format": "dailyhisab.backup",
///   "version": 1,
///   "exportedAt": "2026-11-25T06:00:00.000Z",
///   "appVersion": "1.0.0",
///   "data": { "accounts": [], "categories": [], "transactions": [],
///             "budgets": [], "savingsGoals": [], "settings": [] }
/// }
/// ```
library;

import 'dart:convert';

class BackupFormatException implements Exception {
  BackupFormatException(this.message);
  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// Validated, normalized backup content (maps only; typed accessors below).
class BackupContent {
  const BackupContent({
    required this.exportedAt,
    required this.appVersion,
    required this.accounts,
    required this.categories,
    required this.transactions,
    required this.budgets,
    required this.savingsGoals,
    required this.settings,
  });

  final String exportedAt;
  final String appVersion;
  final List<Map<String, Object?>> accounts;
  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> transactions;
  final List<Map<String, Object?>> budgets;
  final List<Map<String, Object?>> savingsGoals;
  final List<Map<String, Object?>> settings;

  int get countOfAccounts => accounts.length;
  int get countOfCategories => categories.length;
  int get countOfTransactions => transactions.length;
  int get countOfBudgets => budgets.length;
  int get countOfGoals => savingsGoals.length;
}

class BackupCodec {
  BackupCodec._();

  static const String formatId = 'dailyhisab.backup';
  static const int version = 1;

  static String encode(BackupContent c) {
    final json = <String, Object?>{
      'format': formatId,
      'version': version,
      'exportedAt': c.exportedAt,
      'appVersion': c.appVersion,
      'data': <String, Object?>{
        'accounts': c.accounts,
        'categories': c.categories,
        'transactions': c.transactions,
        'budgets': c.budgets,
        'savingsGoals': c.savingsGoals,
        'settings': c.settings,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  /// Parses and fully validates a backup string. Throws
  /// [BackupFormatException] with a precise reason on any structural,
  /// type, enum, duplicate-id or referential-integrity problem.
  static BackupContent decode(String raw) {
    final Object? root;
    try {
      root = const JsonDecoder().convert(raw);
    } on FormatException catch (e) {
      throw BackupFormatException('not valid JSON: ${e.message}');
    }
    if (root is! Map<String, Object?>) {
      throw BackupFormatException('root must be a JSON object');
    }

    if (root['format'] != formatId) {
      throw BackupFormatException('wrong or missing "format" field');
    }
    final v = root['version'];
    if (v is! int || v < 1 || v > version) {
      throw BackupFormatException(
          'unsupported backup version: ${v.runtimeType} ($v)');
    }
    final exportedAt = root['exportedAt'];
    if (exportedAt is! String || DateTime.tryParse(exportedAt) == null) {
      throw BackupFormatException('invalid "exportedAt" timestamp');
    }
    final appVersion = root['appVersion'];
    if (appVersion is! String) {
      throw BackupFormatException('missing "appVersion"');
    }
    final dataRaw = root['data'];
    if (dataRaw is! Map<String, Object?>) {
      throw BackupFormatException('missing "data" object');
    }

    final accounts = _rowList(dataRaw, 'accounts');
    final categories = _rowList(dataRaw, 'categories');
    final transactions = _rowList(dataRaw, 'transactions');
    final budgets = _rowList(dataRaw, 'budgets');
    final savingsGoals = _rowList(dataRaw, 'savingsGoals');
    final settings = _rowList(dataRaw, 'settings');

    _validateAccounts(accounts);
    _validateCategories(categories);
    _validateTransactions(transactions, accounts, categories);
    _validateBudgets(budgets, categories);
    _validateGoals(savingsGoals);
    _validateSettings(settings);

    return BackupContent(
      exportedAt: exportedAt,
      appVersion: appVersion,
      accounts: accounts,
      categories: categories,
      transactions: transactions,
      budgets: budgets,
      savingsGoals: savingsGoals,
      settings: settings,
    );
  }

  // ---------- row lists ----------

  static List<Map<String, Object?>> _rowList(
      Map<String, Object?> data, String key) {
    final raw = data[key];
    if (raw == null) {
      throw BackupFormatException('missing "data.$key"');
    }
    if (raw is! List<Object?>) {
      throw BackupFormatException('"data.$key" must be a list');
    }
    for (final row in raw) {
      if (row is! Map<String, Object?>) {
        throw BackupFormatException('"data.$key" contains a non-object row');
      }
    }
    return raw.cast<Map<String, Object?>>();
  }

  // ---------- primitive accessors ----------

  static String _id(Map<String, Object?> row, String key, String where) {
    final v = row[key];
    if (v is! String || v.isEmpty) {
      throw BackupFormatException('$where: "$key" must be a non-empty string');
    }
    return v;
  }

  static String _str(Map<String, Object?> row, String key, String where) {
    final v = row[key];
    if (v is! String) {
      throw BackupFormatException('$where: "$key" must be a string');
    }
    return v;
  }

  static String? _optStr(Map<String, Object?> row, String key, String where) {
    final v = row[key];
    if (v == null) return null;
    if (v is! String) {
      throw BackupFormatException('$where: "$key" must be a string or null');
    }
    return v;
  }

  static int _int(Map<String, Object?> row, String key, String where) {
    final v = row[key];
    if (v is! int) {
      throw BackupFormatException('$where: "$key" must be an integer');
    }
    return v;
  }

  static bool _bool(Map<String, Object?> row, String key, String where,
      {bool fallback = false}) {
    final v = row[key];
    if (v == null) return fallback;
    if (v is! bool) {
      throw BackupFormatException('$where: "$key" must be a boolean');
    }
    return v;
  }

  static String _iso(Map<String, Object?> row, String key, String where,
      {bool optional = false}) {
    final v = row[key];
    if (v == null && optional) return '';
    if (v is! String || DateTime.tryParse(v) == null) {
      throw BackupFormatException(
          '$where: "$key" must be an ISO-8601 datetime');
    }
    return v;
  }

  static void _requireEnum(
      Map<String, Object?> row, String key, Set<String> allowed, String where) {
    final v = row[key];
    if (v is! String || !allowed.contains(v)) {
      throw BackupFormatException(
          '$where: "$key" must be one of ${allowed.join(', ')}');
    }
  }

  // ---------- per-collection validation ----------

  static void _validateAccounts(List<Map<String, Object?>> rows) {
    final ids = <String>{};
    for (final r in rows) {
      final where = 'accounts[${r['id'] ?? '?'}]';
      final id = _id(r, 'id', where);
      if (!ids.add(id)) throw BackupFormatException('duplicate account id $id');
      _str(r, 'name', where);
      _requireEnum(r, 'kind', {'cash', 'bank', 'wallet', 'other'}, where);
      _int(r, 'openingBalanceMinor', where);
      final cur = _str(r, 'currencyCode', where);
      if (cur != 'BDT') {
        throw BackupFormatException('$where: unsupported currency "$cur"');
      }
      _bool(r, 'isArchived', where);
      _iso(r, 'createdAt', where);
    }
  }

  static void _validateCategories(List<Map<String, Object?>> rows) {
    final ids = <String>{};
    for (final r in rows) {
      final where = 'categories[${r['id'] ?? '?'}]';
      final id = _id(r, 'id', where);
      if (!ids.add(id)) {
        throw BackupFormatException('duplicate category id $id');
      }
      _str(r, 'name', where);
      _requireEnum(r, 'kind', {'income', 'expense'}, where);
      _optStr(r, 'iconKey', where);
      _bool(r, 'isDefault', where);
      _iso(r, 'createdAt', where);
    }
  }

  static void _validateTransactions(
    List<Map<String, Object?>> rows,
    List<Map<String, Object?>> accounts,
    List<Map<String, Object?>> categories,
  ) {
    final accountIds = {
      for (final a in accounts) a['id'] as String,
    };
    final categoryIds = {
      for (final c in categories) c['id'] as String,
    };
    final ids = <String>{};
    for (final r in rows) {
      final where = 'transactions[${r['id'] ?? '?'}]';
      final id = _id(r, 'id', where);
      if (!ids.add(id)) {
        throw BackupFormatException('duplicate transaction id $id');
      }
      _requireEnum(r, 'kind', {'income', 'expense', 'transfer'}, where);
      final amount = _int(r, 'amountMinor', where);
      if (amount <= 0) {
        throw BackupFormatException('$where: amountMinor must be > 0');
      }
      final cur = _str(r, 'currencyCode', where);
      if (cur != 'BDT') {
        throw BackupFormatException('$where: unsupported currency "$cur"');
      }
      final from = _optStr(r, 'fromAccountId', where);
      final to = _optStr(r, 'toAccountId', where);
      final cat = _optStr(r, 'categoryId', where);
      final kind = r['kind'] as String;
      // Accounting invariants (PROJECT_ARCHITECTURE.md §6.2).
      switch (kind) {
        case 'income':
          if (to == null || from != null) {
            throw BackupFormatException(
                '$where: income requires toAccountId and no fromAccountId');
          }
          break;
        case 'expense':
          if (from == null || to != null) {
            throw BackupFormatException(
                '$where: expense requires fromAccountId and no toAccountId');
          }
          break;
        case 'transfer':
          if (from == null || to == null || from == to) {
            throw BackupFormatException(
                '$where: transfer requires two different accounts');
          }
          break;
      }
      if (from != null && !accountIds.contains(from)) {
        throw BackupFormatException('$where: unknown fromAccountId "$from"');
      }
      if (to != null && !accountIds.contains(to)) {
        throw BackupFormatException('$where: unknown toAccountId "$to"');
      }
      if (cat != null && !categoryIds.contains(cat)) {
        throw BackupFormatException('$where: unknown categoryId "$cat"');
      }
      _str(r, 'note', where);
      _iso(r, 'occurredAt', where);
      _iso(r, 'createdAt', where);
      _iso(r, 'updatedAt', where, optional: true);
      _iso(r, 'deletedAt', where, optional: true);
    }
  }

  static void _validateBudgets(
    List<Map<String, Object?>> rows,
    List<Map<String, Object?>> categories,
  ) {
    final categoryIds = {
      for (final c in categories) c['id'] as String,
    };
    final ids = <String>{};
    for (final r in rows) {
      final where = 'budgets[${r['id'] ?? '?'}]';
      final id = _id(r, 'id', where);
      if (!ids.add(id)) throw BackupFormatException('duplicate budget id $id');
      _str(r, 'name', where);
      final my = _int(r, 'monthYear', where);
      final month = my % 100;
      if (my < 100001 || my > 999912 || month < 1 || month > 12) {
        throw BackupFormatException(
            '$where: monthYear must be YYYYMM ($my invalid)');
      }
      final limit = _int(r, 'limitMinor', where);
      if (limit <= 0) {
        throw BackupFormatException('$where: limitMinor must be > 0');
      }
      final cat = _optStr(r, 'categoryId', where);
      if (cat != null && !categoryIds.contains(cat)) {
        throw BackupFormatException('$where: unknown categoryId "$cat"');
      }
      _iso(r, 'createdAt', where);
    }
  }

  static void _validateGoals(List<Map<String, Object?>> rows) {
    final ids = <String>{};
    for (final r in rows) {
      final where = 'savingsGoals[${r['id'] ?? '?'}]';
      final id = _id(r, 'id', where);
      if (!ids.add(id)) throw BackupFormatException('duplicate goal id $id');
      _str(r, 'name', where);
      if (_int(r, 'targetMinor', where) <= 0) {
        throw BackupFormatException('$where: targetMinor must be > 0');
      }
      if (_int(r, 'savedMinor', where) < 0) {
        throw BackupFormatException('$where: savedMinor must be >= 0');
      }
      _iso(r, 'createdAt', where);
    }
  }

  static void _validateSettings(List<Map<String, Object?>> rows) {
    final keys = <String>{};
    for (final r in rows) {
      final key = _id(r, 'key', 'settings');
      if (!keys.add(key)) {
        throw BackupFormatException('duplicate settings key "$key"');
      }
      _str(r, 'value', 'settings["$key"]');
      _iso(r, 'updatedAt', 'settings["$key"]', optional: true);
    }
  }
}
