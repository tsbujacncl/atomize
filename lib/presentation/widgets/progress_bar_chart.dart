import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../providers/completion_history_provider.dart';

/// A simple bar chart showing completion history.
///
/// Each bar represents one day:
/// - Filled bar = habit completed that day (colored by flame)
/// - Empty bar = habit missed that day
class ProgressBarChart extends StatelessWidget {
  /// The completion history data to display
  final CompletionHistory history;

  /// The current habit score (used for flame coloring)
  final double score;

  /// Height of the chart
  final double height;

  /// Whether to show day labels on x-axis
  final bool showLabels;

  const ProgressBarChart({
    super.key,
    required this.history,
    required this.score,
    this.height = 120,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final emptyColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final flameColor = AppColors.getFlameColor(score);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: history.days.map((day) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: _Bar(
                    completed: day.completed,
                    flameColor: flameColor,
                    emptyColor: emptyColor,
                    isToday: _isToday(day.date),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Labels
        if (showLabels) ...[
          const SizedBox(height: 8),
          _AxisLabels(days: history.days),
        ],
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Individual bar in the chart
class _Bar extends StatelessWidget {
  final bool completed;
  final Color flameColor;
  final Color emptyColor;
  final bool isToday;

  const _Bar({
    required this.completed,
    required this.flameColor,
    required this.emptyColor,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // The bar itself
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: completed ? 1.0 : 0.15,
              child: Container(
                decoration: BoxDecoration(
                  color: completed ? flameColor : emptyColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Today indicator
        if (isToday)
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: flameColor,
              shape: BoxShape.circle,
            ),
          )
        else
          const SizedBox(height: 8),
      ],
    );
  }
}

/// X-axis labels showing dates
class _AxisLabels extends StatelessWidget {
  final List<DayCompletion> days;

  const _AxisLabels({required this.days});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 10,
      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
    );

    final firstDay = days.first.date;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(DateFormat.MMMd().format(firstDay), style: textStyle),
        Text('Today', style: textStyle),
      ],
    );
  }
}

/// A card containing the progress bar chart with title and stats
class ProgressChartCard extends StatelessWidget {
  final CompletionHistory history;
  final double score;
  final String title;

  const ProgressChartCard({
    super.key,
    required this.history,
    required this.score,
    this.title = 'Last 30 Days',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
                _StatsChip(
                  completedCount: history.completedCount,
                  totalDays: history.totalDays,
                  flameColor: AppColors.getFlameColor(score),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
            ProgressBarChart(
              history: history,
              score: score,
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip showing completion stats
class _StatsChip extends StatelessWidget {
  final int completedCount;
  final int totalDays;
  final Color flameColor;

  const _StatsChip({
    required this.completedCount,
    required this.totalDays,
    required this.flameColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        totalDays > 0 ? (completedCount / totalDays * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: flameColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$completedCount/$totalDays ($percentage%)',
        style: TextStyle(
          color: flameColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
