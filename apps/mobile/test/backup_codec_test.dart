import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:dailyhisab/core/backup/backup_codec.dart';

Map<String, Object?> validEnvelope() {
  return {
    'format': 'dailyhisab.backup',
    'version': 1,
    'exportedAt': '2026-11-25T06:00:00.000Z',
    'appVersion': '1.0.0',
    'data': {
      'accounts': [
        {
          'id': 'a1',
          'name': 'Cash',
          'kind': 'cash',
          'openingBalanceMinor': 100000,
          'currencyCode': 'BDT',
          'isArchived': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
        {
          'id': 'a2',
          'name': 'Bank',
          'kind': 'bank',
          'openingBalanceMinor': 0,
          'currencyCode': 'BDT',
          'isArchived': false,
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      ],
      'categories': [
        {
          'id': 'c1',
          'name': 'Food',
          'kind': 'expense',
          'iconKey': null,
          'isDefault': true,
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
        {
          'id': 'c2',
          'name': 'Salary',
          'kind': 'income',
          'iconKey': null,
          'isDefault': true,
          'createdAt': '2026-01-01T00:00:00.000Z',
        },
      ],
      'transactions': [
        {
          'id': 't1',
          'kind': 'expense',
          'amountMinor': 12550,
          'currencyCode': 'BDT',
          'categoryId': 'c1',
          'fromAccountId': 'a1',
          'toAccountId': null,
          'note': 'lunch',
          'occurredAt': '2026-11-01T12:00:00.000Z',
          'createdAt': '2026-11-01T12:00:00.000Z',
          'updatedAt': null,
          'deletedAt': null,
        },
        {
          'id': 't2',
          'kind': 'transfer',
          'amountMinor': 50000,
          'currencyCode': 'BDT',
          'categoryId': null,
          'fromAccountId': 'a1',
          'toAccountId': 'a2',
          'note': '',
          'occurredAt': '2026-11-02T09:00:00.000Z',
          'createdAt': '2026-11-02T09:00:00.000Z',
          'updatedAt': null,
          'deletedAt': null,
        },
      ],
      'budgets': [
        {
          'id': 'b1',
          'name': 'Monthly budget',
          'monthYear': 202611,
          'limitMinor': 2000000,
          'categoryId': null,
          'createdAt': '2026-11-01T00:00:00.000Z',
        },
      ],
      'savingsGoals': [
        {
          'id': 'g1',
          'name': 'Bike',
          'targetMinor': 5000000,
          'savedMinor': 120000,
          'createdAt': '2026-11-01T00:00:00.000Z',
        },
      ],
      'settings': [
        {'key': 'currency_code', 'value': 'BDT', 'updatedAt': null},
      ],
    },
  };
}

/// Deep-copies the base envelope, applies [mutate], encodes to JSON.
String mutated(void Function(Map<String, Object?>) mutate) {
  final m = jsonDecode(jsonEncode(validEnvelope())) as Map<String, Object?>;
  mutate(m);
  return jsonEncode(m);
}

void main() {
  group('BackupCodec.decode', () {
    test('accepts a valid envelope and reports counts', () {
      final c = BackupCodec.decode(jsonEncode(validEnvelope()));
      expect(c.countOfAccounts, 2);
      expect(c.countOfCategories, 2);
      expect(c.countOfTransactions, 2);
      expect(c.countOfBudgets, 1);
      expect(c.countOfGoals, 1);
      expect(c.appVersion, '1.0.0');
    });

    test('encode -> decode round-trips', () {
      final json =
          BackupCodec.encode(BackupCodec.decode(jsonEncode(validEnvelope())));
      final c2 = BackupCodec.decode(json);
      expect(c2.countOfTransactions, 2);
      expect(c2.accounts.first['id'], 'a1');
      expect(c2.transactions.first['amountMinor'], 12550);
    });

    test('rejects invalid JSON', () {
      expect(
        () => BackupCodec.decode('not json at all {'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects wrong format id', () {
      expect(
        () => BackupCodec.decode(mutated((m) => m['format'] = 'other.app')),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects future/invalid version', () {
      expect(
        () => BackupCodec.decode(mutated((m) => m['version'] = 99)),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects missing data key', () {
      expect(
        () => BackupCodec.decode(
            mutated((m) => (m['data'] as Map).remove('accounts'))),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects invalid transaction enum', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          ((m['data'] as Map)['transactions'] as List).first['kind'] =
              'donation';
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects non-positive amount', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          ((m['data'] as Map)['transactions'] as List).first['amountMinor'] = 0;
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects unknown category reference', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          ((m['data'] as Map)['transactions'] as List).first['categoryId'] =
              'ghost';
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects unknown account reference', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          ((m['data'] as Map)['transactions'] as List).first['fromAccountId'] =
              'ghost';
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects income without destination account', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          final t = ((m['data'] as Map)['transactions'] as List).first as Map;
          t['kind'] = 'income';
          t['toAccountId'] = null;
          t['categoryId'] = 'c2';
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects transfer with identical accounts', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          final t = ((m['data'] as Map)['transactions'] as List).first as Map;
          t['kind'] = 'transfer';
          t['toAccountId'] = 'a1';
          t['categoryId'] = null;
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects duplicate account ids', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          final accounts = (m['data'] as Map)['accounts'] as List;
          accounts.add(jsonDecode(jsonEncode(accounts.first)));
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects unsupported currency', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          ((m['data'] as Map)['accounts'] as List).first['currencyCode'] =
              'USD';
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('rejects invalid monthYear', () {
      expect(
        () => BackupCodec.decode(mutated((m) {
          ((m['data'] as Map)['budgets'] as List).first['monthYear'] = 202613;
        })),
        throwsA(isA<BackupFormatException>()),
      );
    });
  });
}
