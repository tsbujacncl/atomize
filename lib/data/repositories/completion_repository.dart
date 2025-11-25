import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/completion_dao.dart';
import '../sync/sync_queue.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/sync_service.dart';

/// Repository for habit completion operations
class CompletionRepository {
  final CompletionDao _dao;
  final SyncService? _syncService;
  final _uuid = const Uuid();

  CompletionRepository(this._dao, [this._syncService]);

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
    final completedAt = DateTime.now();

    await _dao.insertCompletion(
      HabitCompletionsCompanion.insert(
        id: id,
        habitId: habitId,
        completedAt: completedAt,
        effectiveDate: effectiveDate,
        source: Value(source.name),
        scoreAtCompletion: scoreAtCompletion,
        countAchieved: Value(countAchieved),
        creditPercentage: Value(creditPercentage),
      ),
    );

    // Queue for sync
    _syncService?.queueCompletionSync(
      id,
      SyncOperation.insert,
      data: {
        'id': id,
        'habit_id': habitId,
        'completed_at': completedAt.toIso8601String(),
        'effective_date': effectiveDate.toIso8601String(),
        'source': source.name,
        'score_at_completion': scoreAtCompletion,
        'count_achieved': countAchieved,
        'credit_percentage': creditPercentage,
      },
    );

    return id;
  }

  /// Delete a completion (for undo)
  Future<void> deleteCompletion(String id) async {
    await _dao.deleteCompletion(id);
    _syncService?.queueCompletionSync(id, SyncOperation.delete);
  }

  /// Delete all completions for a habit (when deleting habit)
  Future<void> deleteAllForHabit(String habitId) =>
      _dao.deleteAllForHabit(habitId);

  /// Get the most recent completion for a habit
  Future<HabitCompletion?> getMostRecent(String habitId) =>
      _dao.getMostRecent(habitId);

  /// Count distinct days with completions in a date range
  Future<int> countCompletedDaysInRange(
    String habitId,
    DateTime start,
    DateTime end,
  ) =>
      _dao.countCompletedDaysInRange(habitId, start, end);

  /// Get today's count progress for count-type habits.
  ///
  /// Returns the sum of all countAchieved values for the given date.
  Future<int> getTodayCount(String habitId, DateTime effectiveDate) async {
    final completions = await _dao.getForHabitOnDate(habitId, effectiveDate);
    int total = 0;
    for (final c in completions) {
      total += c.countAchieved ?? 0;
    }
    return total;
  }
}
