import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repository_providers.dart';
import 'habit_provider.dart';

/// Time periods for the history view.
enum HistoryPeriod {
  sevenDays('7d'),
  fourWeeks('4w'),
  oneYear('1y'),
  all('All');

  final String label;
  const HistoryPeriod(this.label);

  /// Whether this period shows daily granularity (vs monthly).
  bool get isDaily => this == sevenDays || this == fourWeeks;

  /// Number of bars to show for this period.
  int get barCount {
    switch (this) {
      case sevenDays:
        return 7;
      case fourWeeks:
        return 28;
      case oneYear:
        return 12;
      case all:
        return 0; // Dynamic based on data
    }
  }

  /// Display label for stats boxes (e.g., "(7 days)").
  String get displayLabel {
    switch (this) {
      case sevenDays:
        return '(7 days)';
      case fourWeeks:
        return '(4 weeks)';
      case oneYear:
        return '(1 year)';
      case all:
        return '(All time)';
    }
  }
}

/// Stats for a single day in the history view.
class DayStats {
  final DateTime date;
  final int completedCount;
  final int totalHabits;
  final double avgScore;

  const DayStats({
    required this.date,
    required this.completedCount,
    required this.totalHabits,
    required this.avgScore,
  });

  /// Whether all habits were completed.
  bool get isComplete => totalHabits > 0 && completedCount >= totalHabits;

  /// Completion percentage (0.0 to 1.0).
  double get completionRate =>
      totalHabits > 0 ? (completedCount / totalHabits).clamp(0.0, 1.0) : 0.0;

  /// Whether this is a future date.
  bool get isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisDate = DateTime(date.year, date.month, date.day);
    return thisDate.isAfter(today);
  }
}

/// Stats for a single month in the history view (1y/All periods).
class MonthStats {
  final DateTime month; // First day of the month
  final int totalCompletions;
  final int totalPossibleCompletions; // Total habits × days tracked
  final double avgScore;

  const MonthStats({
    required this.month,
    required this.totalCompletions,
    required this.totalPossibleCompletions,
    required this.avgScore,
  });

  /// Average completion rate for the month (0.0 to 1.0).
  double get completionRate => totalPossibleCompletions > 0
      ? (totalCompletions / totalPossibleCompletions).clamp(0.0, 1.0)
      : 0.0;

  /// Month label (e.g., "Nov").
  String get label {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month.month - 1];
  }

  /// Whether this is a future month.
  bool get isFuture {
    final now = DateTime.now();
    return month.year > now.year ||
        (month.year == now.year && month.month > now.month);
  }
}

/// Complete history data for the home screen.
class HomeHistoryData {
  final HistoryPeriod period;
  final List<DayStats> dailyStats; // For 7d/4w
  final List<MonthStats> monthlyStats; // For 1y/All
  final int maxValue; // For Y-axis scaling

  // Period aggregate stats (for period stats boxes)
  final double periodCompletionPercentage; // 0-100
  final double periodAvgScore; // Average score for the period

  // Today stats (for today stats boxes)
  final double todayAvgScore; // Today's average score
  final int todayScoreChange; // Change vs period start

  const HomeHistoryData({
    required this.period,
    this.dailyStats = const [],
    this.monthlyStats = const [],
    required this.maxValue,
    this.periodCompletionPercentage = 0,
    this.periodAvgScore = 0,
    this.todayAvgScore = 0,
    this.todayScoreChange = 0,
  });

  /// Get the appropriate stats list based on period.
  bool get isDaily => period.isDaily;

  // Legacy getters for backwards compatibility
  double get currentAvgScore => todayAvgScore;
  int get avgScoreChange => todayScoreChange;
}

/// Provider for home screen history data.
final homeHistoryProvider = FutureProvider.family<HomeHistoryData,
    ({HistoryPeriod period, DateTime selectedDate})>((ref, params) async {
  final completionRepo = ref.watch(completionRepositoryProvider);
  final habitRepo = ref.watch(habitRepositoryProvider);
  final prefsRepo = ref.watch(preferencesRepositoryProvider);

  // Get all active habits for total count
  final habits = await ref.watch(habitsStreamProvider.future);
  final totalHabits = habits.length;

  // Get effective date
  final effectiveDate = await prefsRepo.getEffectiveDate(params.selectedDate);
  final today = DateTime(effectiveDate.year, effectiveDate.month, effectiveDate.day);

  if (params.period.isDaily) {
    // Daily stats for 7d or 4w
    final days = params.period.barCount;
    final startDate = today.subtract(Duration(days: days - 1));

    final dailyStats = <DayStats>[];
    int maxCompletions = totalHabits > 0 ? totalHabits : 1;

    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final isFuture = date.isAfter(today);

      if (isFuture) {
        // Future date - no data
        dailyStats.add(DayStats(
          date: date,
          completedCount: 0,
          totalHabits: totalHabits,
          avgScore: 0,
        ));
        continue;
      }

      // Count completions for this day across all habits
      int completedCount = 0;
      double totalScore = 0;
      int habitsWithScore = 0;

      for (final habit in habits) {
        final wasCompleted = await completionRepo.wasCompletedOnDate(
          habit.id,
          date,
        );
        if (wasCompleted) {
          completedCount++;
          totalScore += habit.score;
          habitsWithScore++;
        }
      }

      final avgScore = habitsWithScore > 0 ? totalScore / habitsWithScore : 0.0;

      dailyStats.add(DayStats(
        date: date,
        completedCount: completedCount,
        totalHabits: totalHabits,
        avgScore: avgScore,
      ));
    }

    // Calculate today's average score across all habits
    double todayAvgScore = 0;
    if (habits.isNotEmpty) {
      todayAvgScore = habits.map((h) => h.score).reduce((a, b) => a + b) / habits.length;
    }

    // Calculate score at period start for comparison
    double periodStartScore = 0;
    if (dailyStats.isNotEmpty && dailyStats.first.avgScore > 0) {
      periodStartScore = dailyStats.first.avgScore;
    }
    final todayScoreChange = (todayAvgScore - periodStartScore).round();

    // Calculate period aggregate stats
    int totalCompletions = 0;
    int totalPossible = 0;
    double totalScore = 0;
    int scoreCount = 0;
    for (final stat in dailyStats) {
      if (!stat.isFuture) {
        totalCompletions += stat.completedCount;
        totalPossible += stat.totalHabits;
        if (stat.avgScore > 0) {
          totalScore += stat.avgScore;
          scoreCount++;
        }
      }
    }
    final periodCompletionPercentage = totalPossible > 0
        ? (totalCompletions / totalPossible * 100)
        : 0.0;
    final periodAvgScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;

    return HomeHistoryData(
      period: params.period,
      dailyStats: dailyStats,
      maxValue: maxCompletions,
      periodCompletionPercentage: periodCompletionPercentage,
      periodAvgScore: periodAvgScore,
      todayAvgScore: todayAvgScore,
      todayScoreChange: todayScoreChange,
    );
  } else {
    // Monthly stats for 1y or All
    final monthlyStats = <MonthStats>[];

    DateTime startMonth;
    if (params.period == HistoryPeriod.oneYear) {
      // Last 12 months
      startMonth = DateTime(today.year - 1, today.month + 1, 1);
    } else {
      // All time - find earliest habit
      final allHabits = await habitRepo.getAllActive();
      if (allHabits.isEmpty) {
        return HomeHistoryData(
          period: params.period,
          monthlyStats: [],
          maxValue: 1,
        );
      }
      final earliestHabit = allHabits.reduce(
          (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
      startMonth = DateTime(earliestHabit.createdAt.year,
          earliestHabit.createdAt.month, 1);
    }

    final endMonth = DateTime(today.year, today.month, 1);
    int maxCompletions = 1;

    var currentMonth = startMonth;
    while (!currentMonth.isAfter(endMonth)) {
      final monthEnd = DateTime(currentMonth.year, currentMonth.month + 1, 0);
      final isFuture = currentMonth.isAfter(endMonth);

      // Calculate days in month (up to today if current month)
      final daysInMonth = monthEnd.day;
      final isCurrentMonth = currentMonth.year == today.year && currentMonth.month == today.month;
      final daysToCount = isCurrentMonth ? today.day : daysInMonth;
      final totalPossibleCompletions = daysToCount * totalHabits;

      if (isFuture) {
        monthlyStats.add(MonthStats(
          month: currentMonth,
          totalCompletions: 0,
          totalPossibleCompletions: totalPossibleCompletions,
          avgScore: 0,
        ));
      } else {
        // Count total completions for this month
        int totalCompletions = 0;
        double totalScore = 0;
        int completionsWithScore = 0;

        for (final habit in habits) {
          final completions = await completionRepo.getInRange(
            habit.id,
            currentMonth,
            monthEnd.add(const Duration(days: 1)),
          );
          totalCompletions += completions.length;

          for (final c in completions) {
            totalScore += c.scoreAtCompletion;
            completionsWithScore++;
          }
        }

        if (totalCompletions > maxCompletions) {
          maxCompletions = totalCompletions;
        }

        final avgScore =
            completionsWithScore > 0 ? totalScore / completionsWithScore : 0.0;

        monthlyStats.add(MonthStats(
          month: currentMonth,
          totalCompletions: totalCompletions,
          totalPossibleCompletions: totalPossibleCompletions,
          avgScore: avgScore,
        ));
      }

      // Move to next month
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    // Calculate today's average score across all habits
    double todayAvgScore = 0;
    if (habits.isNotEmpty) {
      todayAvgScore = habits.map((h) => h.score).reduce((a, b) => a + b) / habits.length;
    }

    // Calculate score at period start for comparison
    double periodStartScore = 0;
    if (monthlyStats.isNotEmpty && monthlyStats.first.avgScore > 0) {
      periodStartScore = monthlyStats.first.avgScore;
    }
    final todayScoreChange = (todayAvgScore - periodStartScore).round();

    // Calculate period aggregate stats
    int totalCompletions = 0;
    int totalPossible = 0;
    double totalScore = 0;
    int scoreCount = 0;
    for (final stat in monthlyStats) {
      if (!stat.isFuture) {
        totalCompletions += stat.totalCompletions;
        totalPossible += stat.totalPossibleCompletions;
        if (stat.avgScore > 0) {
          totalScore += stat.avgScore;
          scoreCount++;
        }
      }
    }
    final periodCompletionPercentage = totalPossible > 0
        ? (totalCompletions / totalPossible * 100)
        : 0.0;
    final periodAvgScore = scoreCount > 0 ? totalScore / scoreCount : 0.0;

    return HomeHistoryData(
      period: params.period,
      monthlyStats: monthlyStats,
      maxValue: maxCompletions,
      periodCompletionPercentage: periodCompletionPercentage,
      periodAvgScore: periodAvgScore,
      todayAvgScore: todayAvgScore,
      todayScoreChange: todayScoreChange,
    );
  }
});
