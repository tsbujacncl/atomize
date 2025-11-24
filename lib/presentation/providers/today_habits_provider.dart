import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import 'repository_providers.dart';
import 'habit_provider.dart';

/// A habit with its completion status for today.
class TodayHabit {
  final Habit habit;
  final bool isCompletedToday;
  final DateTime effectiveDate;

  const TodayHabit({
    required this.habit,
    required this.isCompletedToday,
    required this.effectiveDate,
  });
}

/// Provides today's habits with completion status.
///
/// Habits are sorted:
/// 1. Incomplete habits first (by scheduled time)
/// 2. Completed habits last (by scheduled time)
class TodayHabitsNotifier extends AsyncNotifier<List<TodayHabit>> {
  @override
  Future<List<TodayHabit>> build() async {
    // Watch habits stream to react to changes
    final habits = await ref.watch(habitsStreamProvider.future);
    final prefsRepo = ref.watch(preferencesRepositoryProvider);
    final completionRepo = ref.watch(completionRepositoryProvider);

    // Get effective date for today
    final effectiveDate = await prefsRepo.getEffectiveDate(DateTime.now());

    // Check completion status for each habit
    final todayHabits = <TodayHabit>[];

    for (final habit in habits) {
      final isCompleted = await completionRepo.wasCompletedOnDate(
        habit.id,
        effectiveDate,
      );

      todayHabits.add(TodayHabit(
        habit: habit,
        isCompletedToday: isCompleted,
        effectiveDate: effectiveDate,
      ));
    }

    // Sort: incomplete first (by time), then completed (by time)
    todayHabits.sort((a, b) {
      if (a.isCompletedToday != b.isCompletedToday) {
        return a.isCompletedToday ? 1 : -1;
      }
      return a.habit.scheduledTime.compareTo(b.habit.scheduledTime);
    });

    return todayHabits;
  }

  /// Refresh the list after a completion
  void refresh() {
    ref.invalidateSelf();
  }
}

/// Provider for today's habits.
final todayHabitsProvider =
    AsyncNotifierProvider<TodayHabitsNotifier, List<TodayHabit>>(
        TodayHabitsNotifier.new);

/// Provides the current effective date (accounting for 4am boundary).
final effectiveDateProvider = FutureProvider<DateTime>((ref) async {
  final prefsRepo = ref.watch(preferencesRepositoryProvider);
  return prefsRepo.getEffectiveDate(DateTime.now());
});
