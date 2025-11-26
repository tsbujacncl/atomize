import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../providers/home_history_provider.dart';

/// A bar chart showing habit completion history.
class HistoryBarChart extends StatelessWidget {
  final HomeHistoryData data;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onBarTap;

  const HistoryBarChart({
    super.key,
    required this.data,
    this.selectedDate,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isDaily) {
      return _DailyBarChart(
        stats: data.dailyStats,
        maxValue: data.maxValue,
        selectedDate: selectedDate,
        onBarTap: onBarTap,
      );
    } else {
      return _MonthlyBarChart(
        stats: data.monthlyStats,
        maxValue: data.maxValue,
        selectedDate: selectedDate,
        onBarTap: onBarTap,
      );
    }
  }
}

/// Bar chart for daily data (7d and 4w views).
class _DailyBarChart extends StatelessWidget {
  final List<DayStats> stats;
  final int maxValue;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onBarTap;

  const _DailyBarChart({
    required this.stats,
    required this.maxValue,
    this.selectedDate,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use SingleChildScrollView for 4w view (28 bars)
    final needsScroll = stats.length > 7;

    Widget chart = SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: stats.map((stat) {
          final isSelected = selectedDate != null &&
              stat.date.year == selectedDate!.year &&
              stat.date.month == selectedDate!.month &&
              stat.date.day == selectedDate!.day;

          return _DayBar(
            stat: stat,
            maxValue: maxValue,
            isSelected: isSelected,
            onTap: stat.isFuture ? null : () => onBarTap?.call(stat.date),
            compact: needsScroll,
          );
        }).toList(),
      ),
    );

    if (needsScroll) {
      chart = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: chart,
        ),
      );
    }

    return chart;
  }
}

/// Single day bar in the chart.
class _DayBar extends StatelessWidget {
  final DayStats stat;
  final int maxValue;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  const _DayBar({
    required this.stat,
    required this.maxValue,
    required this.isSelected,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate bar height
    final barHeight = maxValue > 0
        ? (stat.completedCount / maxValue * 80).clamp(0.0, 80.0)
        : 0.0;

    // Determine bar color based on completion and heat
    Color barColor;
    if (stat.isFuture) {
      barColor = isDark
          ? Colors.grey.shade800
          : Colors.grey.shade300;
    } else if (stat.completedCount == 0) {
      barColor = isDark
          ? Colors.grey.shade700
          : Colors.grey.shade400;
    } else if (stat.isComplete) {
      // All habits complete - green
      barColor = AppColors.success;
    } else {
      // Partial completion - use heat color
      barColor = AppColors.getFlameColor(stat.avgScore);
    }

    // Day label
    final dayLabel = DateFormat('E').format(stat.date)[0]; // M, T, W, etc.
    final dayNum = stat.date.day.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 24 : 36,
        padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: compact ? 16 : 24,
              height: barHeight > 0 ? barHeight : 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
                border: isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            // Day label
            Text(
              compact ? dayNum : dayLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            // Selected indicator
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

/// Bar chart for monthly data (1y and All views).
class _MonthlyBarChart extends StatelessWidget {
  final List<MonthStats> stats;
  final int maxValue;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onBarTap;

  const _MonthlyBarChart({
    required this.stats,
    required this.maxValue,
    this.selectedDate,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    final needsScroll = stats.length > 12;

    Widget chart = SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: stats.map((stat) {
          final isSelected = selectedDate != null &&
              stat.month.year == selectedDate!.year &&
              stat.month.month == selectedDate!.month;

          return _MonthBar(
            stat: stat,
            maxValue: maxValue,
            isSelected: isSelected,
            onTap: stat.isFuture ? null : () => onBarTap?.call(stat.month),
            compact: needsScroll,
          );
        }).toList(),
      ),
    );

    if (needsScroll) {
      chart = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: chart,
        ),
      );
    }

    return chart;
  }
}

/// Single month bar in the chart.
class _MonthBar extends StatelessWidget {
  final MonthStats stat;
  final int maxValue;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  const _MonthBar({
    required this.stat,
    required this.maxValue,
    required this.isSelected,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate bar height
    final barHeight = maxValue > 0
        ? (stat.totalCompletions / maxValue * 80).clamp(0.0, 80.0)
        : 0.0;

    // Determine bar color based on heat
    Color barColor;
    if (stat.isFuture) {
      barColor = isDark
          ? Colors.grey.shade800
          : Colors.grey.shade300;
    } else if (stat.totalCompletions == 0) {
      barColor = isDark
          ? Colors.grey.shade700
          : Colors.grey.shade400;
    } else {
      // Use heat color based on avg score
      barColor = AppColors.getFlameColor(stat.avgScore);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 28 : 36,
        padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: compact ? 20 : 28,
              height: barHeight > 0 ? barHeight : 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
                border: isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            // Month label
            Text(
              stat.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodySmall?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: compact ? 9 : null,
              ),
            ),
            // Selected indicator
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
