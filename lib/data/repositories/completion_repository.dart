import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/completion_dao.dart';
import '../../domain/models/enums.dart';

/// Repository for habit completion operations
class CompletionRepository {
  final CompletionDao _dao;
  final _uuid = const Uuid();

  CompletionRepository(this._dao);

  /// Get all completions for a habit
  Future<List<HabitCompletion>> getForHabit(String habitId) =>
      _dao.getForHabit(habitId);

  /// Watch completions for a habit
  Stream<List<HabitCompletion>> watchForHabit(String habitId) =>
      _dao.watchForHabit(habitId);

  /// Get completions for a habit on a specific date
  Future<List<HabitCompletion>> getForHabitOnDate(
    String habitId,
    DateTime effectiveDate,
  ) =>
      _dao.getForHabitOnDate(habitId, effectiveDate);

  /// Check if habit was completed on a specific date
  Future<bool> wasCompletedOnDate(String habitId, DateTime effectiveDate) =>
      _dao.wasCompletedOnDate(habitId, effectiveDate);

  /// Get completions in a date range (for charts)
  Future<List<HabitCompletion>> getInRange(
    String habitId,
    DateTime start,
    DateTime end,
  ) =>
      _dao.getInRange(habitId, start, end);

  /// Get total completion count for a habit
  Future<int> getCompletionCount(String habitId) =>
      _dao.getCompletionCount(habitId);

  /// Record a new completion
  Future<String> recordCompletion({
    required String habitId,
    required DateTime effectiveDate,
    required double scoreAtCompletion,
    CompletionSource source = CompletionSource.manual,
    int? countAchieved,
    double creditPercentage = 100.0,
  }) async {
    final id = _uuid.v4();
    await _dao.insertCompletion(
      HabitCompletionsCompanion.insert(
        id: id,
        habitId: habitId,
        completedAt: DateTime.now(),
        effectiveDate: effectiveDate,
        source: Value(source.name),
        scoreAtCompletion: scoreAtCompletion,
        countAchieved: Value(countAchieved),
        creditPercentage: Value(creditPercentage),
      ),
    );
    return id;
  }

  /// Delete a completion (for undo)
  Future<void> deleteCompletion(String id) => _dao.deleteCompletion(id);

  /// Delete all completions for a habit (when deleting habit)
  Future<void> deleteAllForHabit(String habitId) =>
      _dao.deleteAllForHabit(habitId);

  /// Get the most recent completion for a habit
  Future<HabitCompletion?> getMostRecent(String habitId) =>
      _dao.getMostRecent(habitId);
}
