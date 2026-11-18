import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/drift/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.forProduction();
  ref.onDispose(db.close);
  return db;
});