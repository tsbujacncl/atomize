import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';

/// Provides the singleton database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
