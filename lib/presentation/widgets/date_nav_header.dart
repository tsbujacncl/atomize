import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/home_history_provider.dart';

/// A header with date display and navigation arrows.
class DateNavHeader extends StatelessWidget {
  final DateTime date;
  final HistoryPeriod period;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onDateTap;

  const DateNavHeader({
    super.key,
    required this.date,
    required this.period,
    this.onPrevious,
    this.onNext,
    this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format date based on period
    String dateText;
    if (period.isDaily) {
      // Show full date for daily views
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        dateText = 'Today';
      } else if (dateOnly == today.subtract(const Duration(days: 1))) {
        dateText = 'Yesterday';
      } else {
        dateText = DateFormat('EEE, MMM d').format(date);
      }
    } else {
      // Show month/year for monthly views
      dateText = DateFormat('MMMM yyyy').format(date);
    }

    // Check if can navigate forward (not beyond today)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final canGoNext = period.isDaily
        ? date.isBefore(today)
        : (date.year < now.year ||
            (date.year == now.year && date.month < now.month));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrevious,
          visualDensity: VisualDensity.compact,
          tooltip: period.isDaily ? 'Previous day' : 'Previous month',
        ),

        // Date text (tappable for calendar in 1y/All mode)
        GestureDetector(
          onTap: onDateTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: onDateTap != null
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dateText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onDateTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Next button
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: canGoNext ? onNext : null,
          visualDensity: VisualDensity.compact,
          tooltip: period.isDaily ? 'Next day' : 'Next month',
        ),
      ],
    );
  }
}
