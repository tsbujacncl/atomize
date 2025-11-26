import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import 'repository_providers.dart';
import 'habit_provider.dart';

/// A habit with its completion status for a specific date.
class DateHabit {
  final Habit habit;
  final bool isCompleted;
  final DateTime effectiveDate;
  final int count; // For count-type habits
  final int weeklyCount; // For weekly-type habits

  const DateHabit({
    required this.habit,
    required this.isCompleted,
    required this.effectiveDate,
    this.count = 0,
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

  /// Whether the date is editable (within last 7 days).
  bool get isEditable {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day);
    final daysDiff = today.difference(date).inDays;
    return daysDiff >= 0 && daysDiff < 7;
  }
}

/// Provider for habits with completion status for a specific date.
final dateHabitsProvider = FutureProvider.family<List<DateHabit>, DateTime>(
  (ref, date) async {
    final habits = await ref.watch(habitsStreamProvider.future);
    final completionRepo = ref.watch(completionRepositoryProvider);
    final prefsRepo = ref.watch(preferencesRepositoryProvider);

    // Get the effective date
    final effectiveDate = await prefsRepo.getEffectiveDate(date);
    final normalizedDate = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
    );

    // Calculate start of week for weekly habits
    final weekday = normalizedDate.weekday;
    final weekStart = normalizedDate.subtract(Duration(days: weekday - 1));

    final dateHabits = <DateHabit>[];

    for (final habit in habits) {
      final isCountType = habit.type == 'count';
      final isWeeklyType = habit.type == 'weekly';
      int count = 0;
      int weeklyCount = 0;
      bool isCompleted;

      if (isCountType) {
        // For count habits, get the count for that date
        count = await completionRepo.getTodayCount(habit.id, normalizedDate);
        isCompleted = count >= (habit.countTarget ?? 1);
      } else if (isWeeklyType) {
        // For weekly habits, count distinct completed days that week
        weeklyCount = await completionRepo.countCompletedDaysInRange(
          habit.id,
          weekStart,
          normalizedDate,
        );
        final completedOnDate = await completionRepo.wasCompletedOnDate(
          habit.id,
          normalizedDate,
        );
        final targetMet = weeklyCount >= (habit.weeklyTarget ?? 3);
        isCompleted = completedOnDate || targetMet;
      } else {
        // Binary habit
        isCompleted = await completionRepo.wasCompletedOnDate(
          habit.id,
          normalizedDate,
        );
      }

      dateHabits.add(DateHabit(
        habit: habit,
        isCompleted: isCompleted,
        effectiveDate: normalizedDate,
        count: count,
        weeklyCount: weeklyCount,
      ));
    }

    // Sort: incomplete first (by time), then completed (by time)
    dateHabits.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.habit.scheduledTime.compareTo(b.habit.scheduledTime);
    });

    return dateHabits;
  },
);

/// Check if a date is within the editable window (last 7 days).
bool isDateEditable(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final checkDate = DateTime(date.year, date.month, date.day);
  final daysDiff = today.difference(checkDate).inDays;
  return daysDiff >= 0 && daysDiff < 7;
}
