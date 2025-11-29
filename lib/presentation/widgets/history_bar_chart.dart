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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final needsScroll = stats.length > 7;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final yAxisLabels = _getYAxisLabels(maxValue);
    final chartHeight = 100.0;
    final labelAreaHeight = 50.0; // Extra space for labels + today dot
    final effectiveMax = maxValue > 0 ? maxValue : 1;
    final barWidth = needsScroll ? 20.0 : 28.0;
    final columnWidth = needsScroll ? 28.0 : 44.0;

    // Build bars-only row (no labels)
    Widget barsOnlyRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: stats.map((stat) {
        final isSelected = selectedDate != null &&
            stat.date.year == selectedDate!.year &&
            stat.date.month == selectedDate!.month &&
            stat.date.day == selectedDate!.day;

        final barHeight = (stat.completedCount / effectiveMax * chartHeight).clamp(0.0, chartHeight);

        Color barColor;
        if (stat.isFuture) {
          barColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
        } else if (stat.completedCount == 0) {
          barColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;
        } else {
          barColor = AppColors.getBarColor(stat.completionRate * 100);
        }

        // Empty bars show as flat grey line, not rounded pill
        final isEmpty = stat.completedCount == 0 && !stat.isFuture;

        return GestureDetector(
          onTap: stat.isFuture ? null : () => onBarTap?.call(stat.date),
          child: Tooltip(
            message: stat.isFuture ? '' : '${stat.completedCount}/${stat.totalHabits} completed',
            child: SizedBox(
              width: columnWidth,
              child: Center(
                child: isEmpty
                    ? Container(
                        width: barWidth,
                        height: 2,
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                      )
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: barWidth,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                          boxShadow: isSelected ? [
                            BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1),
                          ] : null,
                        ),
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    // Build labels-only row
    Widget labelsRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((stat) {
        final statDate = DateTime(stat.date.year, stat.date.month, stat.date.day);
        final isSelected = selectedDate != null &&
            stat.date.year == selectedDate!.year &&
            stat.date.month == selectedDate!.month &&
            stat.date.day == selectedDate!.day;
        final isToday = statDate.isAtSameMomentAs(today);
        final todayColor = AppColors.accent;
        final dayLabel = DateFormat('E').format(stat.date)[0];
        final dayNum = stat.date.day.toString();

        return SizedBox(
          width: columnWidth,
          child: Column(
            children: [
              Text(
                needsScroll ? dayNum : dayLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isToday ? todayColor : (isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color),
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (!needsScroll)
                Text(
                  dayNum,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: isToday ? todayColor : (isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              if (isToday)
                Container(
                  width: 5, height: 5,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(color: todayColor, shape: BoxShape.circle),
                )
              else
                const SizedBox(height: 7),
            ],
          ),
        );
      }).toList(),
    );

    if (needsScroll) {
      barsOnlyRow = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: barsOnlyRow),
      );
      labelsRow = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: labelsRow),
      );
    }

    return SizedBox(
      height: chartHeight + labelAreaHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-axis labels
          SizedBox(
            width: 24,
            height: chartHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final label in yAxisLabels)
                  Positioned(
                    bottom: (label / effectiveMax * chartHeight) - 6,
                    right: 0,
                    child: Text(
                      label.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Chart + labels
          Expanded(
            child: Column(
              children: [
                // Chart area with gridlines and bars
                SizedBox(
                  height: chartHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Gridlines
                      for (final label in yAxisLabels)
                        Positioned(
                          bottom: label / effectiveMax * chartHeight,
                          left: 0,
                          right: 0,
                          child: Container(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
                        ),
                      // Bars row (aligned to bottom)
                      Positioned(left: 0, right: 0, bottom: 0, child: barsOnlyRow),
                    ],
                  ),
                ),
                // Label area (below chart)
                const SizedBox(height: 4),
                labelsRow,
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getYAxisLabels(int maxValue) {
    if (maxValue <= 0) return [0, 1];
    if (maxValue <= 3) return List.generate(maxValue + 1, (i) => i);
    if (maxValue <= 6) return [0, (maxValue / 2).round(), maxValue];
    final step = (maxValue / 4).ceil();
    final labels = <int>[0];
    for (var i = step; i < maxValue; i += step) {
      labels.add(i);
    }
    labels.add(maxValue);
    return labels;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final needsScroll = stats.length > 12;

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    final chartHeight = 100.0;
    final labelAreaHeight = 35.0; // Extra space for labels + dot
    final yAxisValues = [0.0, 0.5, 1.0];
    final barWidth = needsScroll ? 22.0 : 28.0;
    final columnWidth = needsScroll ? 32.0 : 44.0;

    // Build bars-only row
    Widget barsOnlyRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: stats.map((stat) {
        final isSelected = selectedDate != null &&
            stat.month.year == selectedDate!.year &&
            stat.month.month == selectedDate!.month;

        final barHeight = (stat.completionRate * chartHeight).clamp(0.0, chartHeight);

        Color barColor;
        if (stat.isFuture) {
          barColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
        } else if (stat.totalCompletions == 0) {
          barColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;
        } else {
          barColor = AppColors.getBarColor(stat.completionRate * 100);
        }

        final percentage = (stat.completionRate * 100).round();
        final tooltipMessage = '${stat.totalCompletions}/${stat.totalPossibleCompletions} ($percentage%)';

        // Empty bars show as flat grey line, not rounded pill
        final isEmpty = stat.totalCompletions == 0 && !stat.isFuture;

        return GestureDetector(
          onTap: stat.isFuture ? null : () => onBarTap?.call(stat.month),
          child: Tooltip(
            message: stat.isFuture ? '' : tooltipMessage,
            child: SizedBox(
              width: columnWidth,
              child: Center(
                child: isEmpty
                    ? Container(
                        width: barWidth,
                        height: 2,
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                      )
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: barWidth,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                          border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                          boxShadow: isSelected ? [
                            BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1),
                          ] : null,
                        ),
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );

    // Build labels-only row
    Widget labelsRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((stat) {
        final isSelected = selectedDate != null &&
            stat.month.year == selectedDate!.year &&
            stat.month.month == selectedDate!.month;
        final isCurrentMonth = stat.month.year == currentMonth.year &&
            stat.month.month == currentMonth.month;
        final currentMonthColor = AppColors.accent;

        return SizedBox(
          width: columnWidth,
          child: Column(
            children: [
              Text(
                stat.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isCurrentMonth ? currentMonthColor : (isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color),
                  fontWeight: isSelected || isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                  fontSize: needsScroll ? 9 : null,
                ),
              ),
              if (isCurrentMonth)
                Container(
                  width: 5, height: 5,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(color: currentMonthColor, shape: BoxShape.circle),
                )
              else
                const SizedBox(height: 7),
            ],
          ),
        );
      }).toList(),
    );

    if (needsScroll) {
      barsOnlyRow = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: barsOnlyRow),
      );
      labelsRow = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: labelsRow),
      );
    }

    return SizedBox(
      height: chartHeight + labelAreaHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Y-axis labels
          SizedBox(
            width: 32,
            height: chartHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (final value in yAxisValues)
                  Positioned(
                    bottom: (value * chartHeight) - 6,
                    right: 0,
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Chart + labels
          Expanded(
            child: Column(
              children: [
                // Chart area with gridlines and bars
                SizedBox(
                  height: chartHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Gridlines
                      for (final value in yAxisValues)
                        Positioned(
                          bottom: value * chartHeight,
                          left: 0,
                          right: 0,
                          child: Container(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
                        ),
                      // Bars row (aligned to bottom)
                      Positioned(left: 0, right: 0, bottom: 0, child: barsOnlyRow),
                    ],
                  ),
                ),
                // Label area (below chart)
                const SizedBox(height: 4),
                labelsRow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
