import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_providers.dart';

/// Represents a single day's completion status
class DayCompletion {
  final DateTime date;
  final bool completed;

  const DayCompletion({
    required this.date,
    required this.completed,
  });
}

/// Represents completion history for a habit
class CompletionHistory {
  final List<DayCompletion> days;
  final int completedCount;
  final int totalDays;

  const CompletionHistory({
    required this.days,
    required this.completedCount,
    required this.totalDays,
  });

  double get completionRate =>
      totalDays > 0 ? (completedCount / totalDays) * 100 : 0;
}

/// Provider for fetching completion history for the last N days
final completionHistoryProvider = FutureProvider.family<CompletionHistory,
    ({String habitId, int days})>((ref, params) async {
  final completionRepo = ref.watch(completionRepositoryProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startDate = today.subtract(Duration(days: params.days - 1));

  // Get all completions in range
  final completions = await completionRepo.getInRange(
    params.habitId,
    startDate,
    today.add(const Duration(days: 1)),
  );

  // Build set of completed dates for quick lookup
  final completedDates = <String>{};
  for (final completion in completions) {
    final date = completion.effectiveDate;
    final key = '${date.year}-${date.month}-${date.day}';
    completedDates.add(key);
  }

  // Build list of day completions
  final days = <DayCompletion>[];
  var completedCount = 0;

  for (var i = 0; i < params.days; i++) {
    final date = startDate.add(Duration(days: i));
    final key = '${date.year}-${date.month}-${date.day}';
    final completed = completedDates.contains(key);

    days.add(DayCompletion(date: date, completed: completed));
    if (completed) completedCount++;
  }

  return CompletionHistory(
    days: days,
    completedCount: completedCount,
    totalDays: params.days,
  );
});
