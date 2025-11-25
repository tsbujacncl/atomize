import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/habit_dao.dart';
import '../sync/sync_queue.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/sync_service.dart';

/// Repository for habit operations
class HabitRepository {
  final HabitDao _dao;
  final SyncService? _syncService;
  final _uuid = const Uuid();

  HabitRepository(this._dao, [this._syncService]);

  /// Get all active (non-archived) habits
  Future<List<Habit>> getAllActive() => _dao.getAllActive();

  /// Watch all active habits (reactive)
  Stream<List<Habit>> watchAllActive() => _dao.watchAllActive();

  /// Get a single habit by ID
  Future<Habit?> getById(String id) => _dao.getById(id);

  /// Watch a single habit by ID
  Stream<Habit?> watchById(String id) => _dao.watchById(id);

  /// Get all archived habits
  Future<List<Habit>> getAllArchived() => _dao.getAllArchived();

  /// Create a new habit
  Future<String> create({
    required String name,
    required String scheduledTime,
    HabitType type = HabitType.binary,
    String? location,
    String? quickWhy,
    int? countTarget,
    int? weeklyTarget,
    int? timerDuration,
    String? afterHabitId,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _dao.insertHabit(
      HabitsCompanion.insert(
        id: id,
        name: name,
        type: Value(type.name),
        scheduledTime: scheduledTime,
        location: Value(location),
        quickWhy: Value(quickWhy),
        countTarget: Value(countTarget),
        weeklyTarget: Value(weeklyTarget),
        timerDuration: Value(timerDuration),
        afterHabitId: Value(afterHabitId),
      ),
    );

    // Queue for sync
    _syncService?.queueHabitSync(
      id,
      SyncOperation.insert,
      data: {
        'id': id,
        'name': name,
        'type': type.name,
        'scheduled_time': scheduledTime,
        'location': location,
        'quick_why': quickWhy,
        'count_target': countTarget,
        'weekly_target': weeklyTarget,
        'timer_duration': timerDuration,
        'after_habit_id': afterHabitId,
        'score': 0.0,
        'maturity': 0,
        'is_archived': false,
        'created_at': now.toIso8601String(),
      },
    );

    return id;
  }

  /// Update a habit's basic info
  Future<void> update({
    required String id,
    String? name,
    String? scheduledTime,
    String? location,
    String? quickWhy,
    int? timerDuration,
    bool updateTimerDuration = false,
    int? countTarget,
    bool updateCountTarget = false,
    int? weeklyTarget,
    bool updateWeeklyTarget = false,
    String? afterHabitId,
    bool updateAfterHabitId = false,
  }) async {
    await _dao.updateFields(
      id,
      HabitsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        scheduledTime:
            scheduledTime != null ? Value(scheduledTime) : const Value.absent(),
        location: Value(location),
        quickWhy: Value(quickWhy),
        timerDuration:
            updateTimerDuration ? Value(timerDuration) : const Value.absent(),
        countTarget:
            updateCountTarget ? Value(countTarget) : const Value.absent(),
        weeklyTarget:
            updateWeeklyTarget ? Value(weeklyTarget) : const Value.absent(),
        afterHabitId:
            updateAfterHabitId ? Value(afterHabitId) : const Value.absent(),
      ),
    );

    // Queue for sync - fetch updated habit data
    final habit = await _dao.getById(id);
    if (habit != null) {
      _syncService?.queueHabitSync(
        id,
        SyncOperation.update,
        data: _habitToSyncData(habit),
      );
    }
  }

  /// Update a habit's score and maturity
  Future<void> updateScore(String id, double newScore, int newMaturity) =>
      _dao.updateScore(id, newScore, newMaturity);

  /// Update deep purpose fields
  Future<void> updateDeepPurpose({
    required String id,
    String? feelingWhy,
    String? identityWhy,
    String? outcomeWhy,
  }) async {
    await _dao.updateFields(
      id,
      HabitsCompanion(
        feelingWhy: Value(feelingWhy),
        identityWhy: Value(identityWhy),
        outcomeWhy: Value(outcomeWhy),
      ),
    );
  }

  /// Archive a habit (soft delete)
  Future<void> archive(String id) async {
    await _dao.archiveHabit(id);

    // Queue sync update
    final habit = await _dao.getById(id);
    if (habit != null) {
      _syncService?.queueHabitSync(
        id,
        SyncOperation.update,
        data: _habitToSyncData(habit),
      );
    }
  }

  /// Unarchive a habit
  Future<void> unarchive(String id) async {
    await _dao.unarchiveHabit(id);

    // Queue sync update
    final habit = await _dao.getById(id);
    if (habit != null) {
      _syncService?.queueHabitSync(
        id,
        SyncOperation.update,
        data: _habitToSyncData(habit),
      );
    }
  }

  /// Permanently delete a habit
  Future<void> delete(String id) async {
    await _dao.deleteHabit(id);

    // Queue sync delete
    _syncService?.queueHabitSync(id, SyncOperation.delete);
  }

  /// Update last decay timestamp
  Future<void> updateLastDecay(String id, DateTime timestamp) =>
      _dao.updateLastDecay(id, timestamp);

  /// Get habits that need decay applied
  Future<List<Habit>> getHabitsNeedingDecay(DateTime before) =>
      _dao.getHabitsNeedingDecay(before);

  /// Set habit stacking (after which habit)
  Future<void> setAfterHabit(String id, String? afterHabitId) async {
    await _dao.updateFields(
      id,
      HabitsCompanion(afterHabitId: Value(afterHabitId)),
    );
  }

  /// Convert a Habit to sync data map.
  Map<String, dynamic> _habitToSyncData(Habit habit) => {
        'id': habit.id,
        'name': habit.name,
        'type': habit.type,
        'scheduled_time': habit.scheduledTime,
        'location': habit.location,
        'quick_why': habit.quickWhy,
        'feeling_why': habit.feelingWhy,
        'identity_why': habit.identityWhy,
        'outcome_why': habit.outcomeWhy,
        'count_target': habit.countTarget,
        'weekly_target': habit.weeklyTarget,
        'after_habit_id': habit.afterHabitId,
        'timer_duration': habit.timerDuration,
        'score': habit.score,
        'maturity': habit.maturity,
        'is_archived': habit.isArchived,
        'created_at': habit.createdAt.toIso8601String(),
        'last_decay_at': habit.lastDecayAt?.toIso8601String(),
      };
}
