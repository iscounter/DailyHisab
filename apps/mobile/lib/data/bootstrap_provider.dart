import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database_providers.dart';
import '../data/repositories/categories_repository.dart';
import '../data/repositories/accounts_repository.dart';
import '../data/drift/app_database.dart';

final appBootstrapProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  final catRepo = CategoriesRepository(db);
  final accRepo = AccountsRepository(db);
  await catRepo.seedDefaultsIfEmpty();
  final accounts = await accRepo.getAll();
  if (accounts.isEmpty) {
    await accRepo.create(name: 'Cash', kind: AccountKind.cash);
  }
});
