import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/completion_repository.dart';
import '../../data/repositories/preferences_repository.dart';
import 'database_provider.dart';

/// Provides the HabitRepository instance.
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HabitRepository(db.habitDao);
});

/// Provides the CompletionRepository instance.
final completionRepositoryProvider = Provider<CompletionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CompletionRepository(db.completionDao);
});

/// Provides the PreferencesRepository instance.
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PreferencesRepository(db.preferencesDao);
});
