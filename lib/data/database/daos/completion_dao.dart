import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/completions_table.dart';

part 'completion_dao.g.dart';

@DriftAccessor(tables: [HabitCompletions])
class CompletionDao extends DatabaseAccessor<AppDatabase>
    with _$CompletionDaoMixin {
  CompletionDao(super.db);

  /// Get all completions for a habit
  Future<List<HabitCompletion>> getForHabit(String habitId) {
    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .get();
  }

  /// Watch completions for a habit
  Stream<List<HabitCompletion>> watchForHabit(String habitId) {
    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .watch();
  }

  /// Get completions for a habit on a specific effective date
  Future<List<HabitCompletion>> getForHabitOnDate(
    String habitId,
    DateTime effectiveDate,
  ) {
    final startOfDay = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..where(
            (c) =>
                c.effectiveDate.isBiggerOrEqualValue(startOfDay) &
                c.effectiveDate.isSmallerThanValue(endOfDay),
          ))
        .get();
  }

  /// Check if habit was completed on a specific effective date
  Future<bool> wasCompletedOnDate(String habitId, DateTime effectiveDate) async {
    final completions = await getForHabitOnDate(habitId, effectiveDate);
    return completions.isNotEmpty;
  }

  /// Get completions in a date range
  Future<List<HabitCompletion>> getInRange(
    String habitId,
    DateTime start,
    DateTime end,
  ) {
    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..where(
            (c) =>
                c.effectiveDate.isBiggerOrEqualValue(start) &
                c.effectiveDate.isSmallerThanValue(end),
          )
          ..orderBy([(c) => OrderingTerm.asc(c.effectiveDate)]))
        .get();
  }

  /// Get total completion count for a habit
  Future<int> getCompletionCount(String habitId) async {
    final count = habitCompletions.id.count();
    final query = selectOnly(habitCompletions)
      ..addColumns([count])
      ..where(habitCompletions.habitId.equals(habitId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Insert a new completion
  Future<void> insertCompletion(HabitCompletionsCompanion completion) {
    return into(habitCompletions).insert(completion);
  }

  /// Delete a completion
  Future<int> deleteCompletion(String id) {
    return (delete(habitCompletions)..where((c) => c.id.equals(id))).go();
  }

  /// Delete all completions for a habit
  Future<int> deleteAllForHabit(String habitId) {
    return (delete(habitCompletions)..where((c) => c.habitId.equals(habitId)))
        .go();
  }

  /// Get the most recent completion for a habit
  Future<HabitCompletion?> getMostRecent(String habitId) {
    return (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Count distinct days with completions in a date range
  Future<int> countCompletedDaysInRange(
    String habitId,
    DateTime start,
    DateTime end,
  ) async {
    final completions = await getInRange(habitId, start, end);
    // Get unique dates (by day only, ignoring time)
    final uniqueDays = <String>{};
    for (final completion in completions) {
      final dateKey =
          '${completion.effectiveDate.year}-${completion.effectiveDate.month}-${completion.effectiveDate.day}';
      uniqueDays.add(dateKey);
    }
    return uniqueDays.length;
  }
}
