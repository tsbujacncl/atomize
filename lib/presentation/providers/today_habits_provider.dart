import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import 'repository_providers.dart';
import 'habit_provider.dart';

/// A habit with its completion status for today.
class TodayHabit {
  final Habit habit;
  final bool isCompletedToday;
  final DateTime effectiveDate;

  /// For count-type habits: today's progress count.
  final int todayCount;

  /// For weekly-type habits: this week's completion count (distinct days).
  final int weeklyCount;

  const TodayHabit({
    required this.habit,
    required this.isCompletedToday,
    required this.effectiveDate,
    this.todayCount = 0,
    this.weeklyCount = 0,
  });

  /// Whether this is a count-type habit.
  bool get isCountType => habit.type == 'count';

  /// Whether this is a weekly-type habit.
  bool get isWeeklyType => habit.type == 'weekly';

  /// Target count for count-type habits.
  int get countTarget => habit.countTarget ?? 1;

  /// Target count for weekly-type habits.
  int get weeklyTarget => habit.weeklyTarget ?? 3;

  /// Progress percentage for count-type habits (0.0 to 1.0).
  double get countProgress =>
      isCountType ? (todayCount / countTarget).clamp(0.0, 1.0) : 0.0;

  /// Progress percentage for weekly-type habits (0.0 to 1.0).
  double get weeklyProgress =>
      isWeeklyType ? (weeklyCount / weeklyTarget).clamp(0.0, 1.0) : 0.0;

  /// Whether the weekly target has been met.
  bool get isWeeklyTargetMet => isWeeklyType && weeklyCount >= weeklyTarget;
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

    // Calculate start of current week (Monday)
    final weekStart = _getStartOfWeek(effectiveDate);

    // Check completion status for each habit
    final todayHabits = <TodayHabit>[];

    for (final habit in habits) {
      final isCountType = habit.type == 'count';
      final isWeeklyType = habit.type == 'weekly';
      int todayCount = 0;
      int weeklyCount = 0;
      bool isCompleted;

      if (isCountType) {
        // For count habits, check if target is met
        todayCount = await completionRepo.getTodayCount(habit.id, effectiveDate);
        isCompleted = todayCount >= (habit.countTarget ?? 1);
      } else if (isWeeklyType) {
        // For weekly habits, count distinct completed days this week
        weeklyCount = await completionRepo.countCompletedDaysInRange(
          habit.id,
          weekStart,
          effectiveDate,
        );
        // Weekly habit is "complete" for today if already completed today
        // OR if weekly target is already met
        final completedToday = await completionRepo.wasCompletedOnDate(
          habit.id,
          effectiveDate,
        );
        final targetMet = weeklyCount >= (habit.weeklyTarget ?? 3);
        isCompleted = completedToday || targetMet;
      } else {
        // For binary habits, just check if completed
        isCompleted = await completionRepo.wasCompletedOnDate(
          habit.id,
          effectiveDate,
        );
      }

      todayHabits.add(TodayHabit(
        habit: habit,
        isCompletedToday: isCompleted,
        effectiveDate: effectiveDate,
        todayCount: todayCount,
        weeklyCount: weeklyCount,
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

  /// Get the start of the week (Monday at midnight) for a given date.
  DateTime _getStartOfWeek(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
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
