import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/habit_repository.dart';
import '../../domain/models/enums.dart';
import 'repository_providers.dart';

/// Provides a stream of all active habits.
final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchAllActive();
});

/// Provides a single habit by ID.
final habitByIdProvider = StreamProvider.family<Habit?, String>((ref, id) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.watchById(id);
});

/// AsyncNotifier for managing habit operations.
class HabitNotifier extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() async {
    final repo = ref.watch(habitRepositoryProvider);
    return repo.getAllActive();
  }

  HabitRepository get _repo => ref.read(habitRepositoryProvider);

  /// Create a new habit.
  Future<String> createHabit({
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
    final id = await _repo.create(
      name: name,
      scheduledTime: scheduledTime,
      type: type,
      location: location,
      quickWhy: quickWhy,
      countTarget: countTarget,
      weeklyTarget: weeklyTarget,
      timerDuration: timerDuration,
      afterHabitId: afterHabitId,
    );

    // Refresh the list
    ref.invalidateSelf();
    return id;
  }

  /// Update a habit.
  Future<void> updateHabit({
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
    await _repo.update(
      id: id,
      name: name,
      scheduledTime: scheduledTime,
      location: location,
      quickWhy: quickWhy,
      timerDuration: timerDuration,
      updateTimerDuration: updateTimerDuration,
      countTarget: countTarget,
      updateCountTarget: updateCountTarget,
      weeklyTarget: weeklyTarget,
      updateWeeklyTarget: updateWeeklyTarget,
      afterHabitId: afterHabitId,
      updateAfterHabitId: updateAfterHabitId,
    );
    ref.invalidateSelf();
  }

  /// Archive a habit (soft delete).
  Future<void> archiveHabit(String id) async {
    await _repo.archive(id);
    ref.invalidateSelf();
  }

  /// Unarchive a habit.
  Future<void> unarchiveHabit(String id) async {
    await _repo.unarchive(id);
    ref.invalidateSelf();
  }

  /// Permanently delete a habit.
  Future<void> deleteHabit(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
  }

  /// Update deep purpose fields.
  Future<void> updateDeepPurpose({
    required String id,
    String? feelingWhy,
    String? identityWhy,
    String? outcomeWhy,
  }) async {
    await _repo.updateDeepPurpose(
      id: id,
      feelingWhy: feelingWhy,
      identityWhy: identityWhy,
      outcomeWhy: outcomeWhy,
    );
    ref.invalidateSelf();
  }
}

/// Provider for the HabitNotifier.
final habitNotifierProvider =
    AsyncNotifierProvider<HabitNotifier, List<Habit>>(HabitNotifier.new);
