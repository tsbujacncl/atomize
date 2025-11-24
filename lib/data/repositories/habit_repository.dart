import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/habit_dao.dart';
import '../../domain/models/enums.dart';

/// Repository for habit operations
class HabitRepository {
  final HabitDao _dao;
  final _uuid = const Uuid();

  HabitRepository(this._dao);

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
  }) async {
    final id = _uuid.v4();
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
      ),
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
  }) async {
    await _dao.updateFields(
      id,
      HabitsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        scheduledTime:
            scheduledTime != null ? Value(scheduledTime) : const Value.absent(),
        location: Value(location),
        quickWhy: Value(quickWhy),
      ),
    );
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
  Future<void> archive(String id) => _dao.archiveHabit(id);

  /// Unarchive a habit
  Future<void> unarchive(String id) => _dao.unarchiveHabit(id);

  /// Permanently delete a habit
  Future<void> delete(String id) => _dao.deleteHabit(id);

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
}
