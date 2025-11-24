import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/habits_table.dart';

part 'habit_dao.g.dart';

@DriftAccessor(tables: [Habits])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  /// Get all active (non-archived) habits
  Future<List<Habit>> getAllActive() {
    return (select(habits)..where((h) => h.isArchived.equals(false))).get();
  }

  /// Watch all active habits (reactive stream)
  Stream<List<Habit>> watchAllActive() {
    return (select(habits)..where((h) => h.isArchived.equals(false))).watch();
  }

  /// Get a single habit by ID
  Future<Habit?> getById(String id) {
    return (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  /// Watch a single habit by ID
  Stream<Habit?> watchById(String id) {
    return (select(habits)..where((h) => h.id.equals(id))).watchSingleOrNull();
  }

  /// Get all archived habits
  Future<List<Habit>> getAllArchived() {
    return (select(habits)..where((h) => h.isArchived.equals(true))).get();
  }

  /// Insert a new habit
  Future<void> insertHabit(HabitsCompanion habit) {
    return into(habits).insert(habit);
  }

  /// Update an existing habit
  Future<bool> updateHabit(HabitsCompanion habit) {
    return update(habits).replace(habit);
  }

  /// Update specific fields of a habit
  Future<int> updateFields(String id, HabitsCompanion companion) {
    return (update(habits)..where((h) => h.id.equals(id))).write(companion);
  }

  /// Update habit score and maturity
  Future<void> updateScore(String id, double newScore, int newMaturity) {
    return (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(
        score: Value(newScore),
        maturity: Value(newMaturity),
      ),
    );
  }

  /// Archive a habit (soft delete)
  Future<void> archiveHabit(String id) {
    return (update(habits)..where((h) => h.id.equals(id))).write(
      const HabitsCompanion(isArchived: Value(true)),
    );
  }

  /// Unarchive a habit
  Future<void> unarchiveHabit(String id) {
    return (update(habits)..where((h) => h.id.equals(id))).write(
      const HabitsCompanion(isArchived: Value(false)),
    );
  }

  /// Permanently delete a habit
  Future<int> deleteHabit(String id) {
    return (delete(habits)..where((h) => h.id.equals(id))).go();
  }

  /// Update last decay timestamp
  Future<void> updateLastDecay(String id, DateTime timestamp) {
    return (update(habits)..where((h) => h.id.equals(id))).write(
      HabitsCompanion(lastDecayAt: Value(timestamp)),
    );
  }

  /// Get habits that need decay applied (last decay before given date)
  Future<List<Habit>> getHabitsNeedingDecay(DateTime before) {
    return (select(habits)
          ..where((h) => h.isArchived.equals(false))
          ..where(
            (h) =>
                h.lastDecayAt.isNull() | h.lastDecayAt.isSmallerThanValue(before),
          ))
        .get();
  }
}
