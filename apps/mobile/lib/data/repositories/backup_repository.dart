import 'package:drift/drift.dart';

import '../../core/backup/backup_codec.dart';
import '../drift/app_database.dart';

/// Exports the whole database to the versioned backup format and restores a
/// validated backup atomically (single SQLite transaction, full replace).
class BackupRepository {
  BackupRepository(this._db, {this.appVersion = '1.0.0'});

  final AppDatabase _db;
  final String appVersion;

  // ---------- export ----------

  /// Reads every table (including archived accounts and soft-deleted
  /// transactions so nothing is silently lost) and returns validated content.
  Future<BackupContent> exportContent() async {
    final accounts = await _db.select(_db.accounts).get();
    final categories = await _db.select(_db.categories).get();
    final txns = await _db.select(_db.transactions).get();
    final budgets = await _db.select(_db.budgets).get();
    final goals = await _db.select(_db.savingsGoals).get();
    final settings = await _db.select(_db.appSettings).get();

    final content = BackupContent(
      exportedAt: DateTime.now().toUtc().toIso8601String(),
      appVersion: appVersion,
      accounts: accounts.map(_accountToMap).toList(),
      categories: categories.map(_categoryToMap).toList(),
      transactions: txns.map(_txnToMap).toList(),
      budgets: budgets.map(_budgetToMap).toList(),
      savingsGoals: goals.map(_goalToMap).toList(),
      settings: settings.map(_settingToMap).toList(),
    );

    // Self-check: our own export must always round-trip cleanly.
    BackupCodec.decode(BackupCodec.encode(content));
    return content;
  }

  String exportToJson(BackupContent content) => BackupCodec.encode(content);

  // ---------- restore ----------

  /// Validates and then replaces ALL current data inside one transaction.
  /// Throws [BackupFormatException] before touching the database if the
  /// content is invalid.
  Future<void> restoreContent(BackupContent c) async {
    await _db.transaction(() async {
      // Children first on delete (FK order), parents first on insert.
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.budgets).go();
      await _db.delete(_db.savingsGoals).go();
      await _db.delete(_db.appSettings).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.accounts).go();

      await _db.batch((b) {
        b.insertAll(
          _db.accounts,
          c.accounts.map(_accountFromMap).toList(),
        );
        b.insertAll(
          _db.categories,
          c.categories.map(_categoryFromMap).toList(),
        );
        b.insertAll(
          _db.transactions,
          c.transactions.map(_txnFromMap).toList(),
        );
        b.insertAll(
          _db.budgets,
          c.budgets.map(_budgetFromMap).toList(),
        );
        b.insertAll(
          _db.savingsGoals,
          c.savingsGoals.map(_goalFromMap).toList(),
        );
        b.insertAll(
          _db.appSettings,
          c.settings.map(_settingFromMap).toList(),
        );
      });
    });
  }

  /// Convenience: decode + validate + restore in one call.
  Future<void> restoreFromJson(String raw) async {
    final content = BackupCodec.decode(raw);
    await restoreContent(content);
  }

  // ---------- row -> map ----------

  Map<String, Object?> _accountToMap(Account a) => {
        'id': a.id,
        'name': a.name,
        'kind': a.kind.name,
        'openingBalanceMinor': a.openingBalanceMinor,
        'currencyCode': a.currencyCode,
        'isArchived': a.isArchived,
        'createdAt': a.createdAt.toUtc().toIso8601String(),
      };

  Map<String, Object?> _categoryToMap(Category c) => {
        'id': c.id,
        'name': c.name,
        'kind': c.kind.name,
        'iconKey': c.iconKey,
        'isDefault': c.isDefault,
        'createdAt': c.createdAt.toUtc().toIso8601String(),
      };

  Map<String, Object?> _txnToMap(Transaction t) => {
        'id': t.id,
        'kind': t.kind.name,
        'amountMinor': t.amountMinor,
        'currencyCode': t.currencyCode,
        'categoryId': t.categoryId,
        'fromAccountId': t.fromAccountId,
        'toAccountId': t.toAccountId,
        'note': t.note,
        'occurredAt': t.occurredAt.toUtc().toIso8601String(),
        'createdAt': t.createdAt.toUtc().toIso8601String(),
        'updatedAt': t.updatedAt?.toUtc().toIso8601String(),
        'deletedAt': t.deletedAt?.toUtc().toIso8601String(),
      };

  Map<String, Object?> _budgetToMap(Budget b) => {
        'id': b.id,
        'name': b.name,
        'monthYear': b.monthYear,
        'limitMinor': b.limitMinor,
        'categoryId': b.categoryId,
        'createdAt': b.createdAt.toUtc().toIso8601String(),
      };

  Map<String, Object?> _goalToMap(SavingsGoal g) => {
        'id': g.id,
        'name': g.name,
        'targetMinor': g.targetMinor,
        'savedMinor': g.savedMinor,
        'createdAt': g.createdAt.toUtc().toIso8601String(),
      };

  Map<String, Object?> _settingToMap(AppSetting s) => {
        'key': s.key,
        'value': s.value,
        'updatedAt': s.updatedAt?.toUtc().toIso8601String(),
      };

  // ---------- map -> row ----------

  AccountsCompanion _accountFromMap(Map<String, Object?> m) =>
      AccountsCompanion.insert(
        id: m['id'] as String,
        name: m['name'] as String,
        kind: AccountKind.values.byName(m['kind'] as String),
        openingBalanceMinor: Value(m['openingBalanceMinor'] as int),
        currencyCode: Value(m['currencyCode'] as String),
        isArchived: Value(m['isArchived'] as bool),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  CategoriesCompanion _categoryFromMap(Map<String, Object?> m) =>
      CategoriesCompanion.insert(
        id: m['id'] as String,
        name: m['name'] as String,
        kind: CategoryKind.values.byName(m['kind'] as String),
        iconKey: Value(m['iconKey'] as String?),
        isDefault: Value(m['isDefault'] as bool),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  TransactionsCompanion _txnFromMap(Map<String, Object?> m) =>
      TransactionsCompanion.insert(
        id: m['id'] as String,
        kind: TxnKind.values.byName(m['kind'] as String),
        amountMinor: m['amountMinor'] as int,
        currencyCode: Value(m['currencyCode'] as String),
        categoryId: Value(m['categoryId'] as String?),
        fromAccountId: Value(m['fromAccountId'] as String?),
        toAccountId: Value(m['toAccountId'] as String?),
        note: Value(m['note'] as String),
        occurredAt: DateTime.parse(m['occurredAt'] as String),
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: Value(_optDate(m, 'updatedAt')),
        deletedAt: Value(_optDate(m, 'deletedAt')),
      );

  BudgetsCompanion _budgetFromMap(Map<String, Object?> m) =>
      BudgetsCompanion.insert(
        id: m['id'] as String,
        name: m['name'] as String,
        monthYear: m['monthYear'] as int,
        limitMinor: m['limitMinor'] as int,
        categoryId: Value(m['categoryId'] as String?),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  SavingsGoalsCompanion _goalFromMap(Map<String, Object?> m) =>
      SavingsGoalsCompanion.insert(
        id: m['id'] as String,
        name: m['name'] as String,
        targetMinor: m['targetMinor'] as int,
        savedMinor: Value(m['savedMinor'] as int),
        createdAt: DateTime.parse(m['createdAt'] as String),
      );

  AppSettingsCompanion _settingFromMap(Map<String, Object?> m) =>
      AppSettingsCompanion.insert(
        key: m['key'] as String,
        value: m['value'] as String,
        updatedAt: Value(_optDate(m, 'updatedAt')),
      );

  DateTime? _optDate(Map<String, Object?> m, String key) {
    final v = m[key];
    return v == null ? null : DateTime.parse(v as String);
  }
}
