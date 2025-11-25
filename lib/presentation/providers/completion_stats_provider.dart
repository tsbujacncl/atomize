import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_providers.dart';
import 'habit_provider.dart';

/// Time period for completion statistics
enum StatsPeriod {
  oneMonth('1M', 30),
  threeMonths('3M', 90),
  oneYear('1Y', 365),
  allTime('All', 0);

  final String label;
  final int days;

  const StatsPeriod(this.label, this.days);
}

/// Completion statistics for a habit
class CompletionStats {
  final int completedDays;
  final int totalDays;
  final double percentage;
  final StatsPeriod period;

  const CompletionStats({
    required this.completedDays,
    required this.totalDays,
    required this.percentage,
    required this.period,
  });

  static const empty = CompletionStats(
    completedDays: 0,
    totalDays: 0,
    percentage: 0,
    period: StatsPeriod.oneMonth,
  );
}

/// Provider for completion stats of a habit for a specific period
final completionStatsProvider = FutureProvider.family<CompletionStats, ({String habitId, StatsPeriod period})>(
  (ref, params) async {
    final completionRepo = ref.watch(completionRepositoryProvider);
    final habitAsync = ref.watch(habitByIdProvider(params.habitId));

    final habit = habitAsync.value;
    if (habit == null) {
      return CompletionStats.empty;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate start date based on period
    late DateTime startDate;
    if (params.period == StatsPeriod.allTime) {
      startDate = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
    } else {
      final periodStart = today.subtract(Duration(days: params.period.days));
      final habitCreatedDate = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );
      // Use whichever is later: period start or habit creation
      startDate = periodStart.isAfter(habitCreatedDate) ? periodStart : habitCreatedDate;
    }

    // End date is today (inclusive, so add 1 day for the query)
    final endDate = today.add(const Duration(days: 1));

    // Count completed days
    final completedDays = await completionRepo.countCompletedDaysInRange(
      params.habitId,
      startDate,
      endDate,
    );

    // Calculate total days in the range (including today)
    final totalDays = today.difference(startDate).inDays + 1;

    // Calculate percentage
    final percentage = totalDays > 0 ? (completedDays / totalDays) * 100 : 0.0;

    return CompletionStats(
      completedDays: completedDays,
      totalDays: totalDays,
      percentage: percentage,
      period: params.period,
    );
  },
);
