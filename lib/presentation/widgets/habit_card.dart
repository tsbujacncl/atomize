import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/constants/habit_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../providers/today_habits_provider.dart';
import '../screens/habit_detail/habit_detail_screen.dart';
import '../screens/timer/timer_screen.dart';
import 'flame_score.dart';

/// Card widget displaying a single habit for the home screen.
///
/// New layout:
/// - Left: Habit icon (tap → timer, long press → quick complete)
/// - Middle: Habit name and details
/// - Right: Flame with score
class HabitCard extends StatelessWidget {
  final TodayHabit todayHabit;

  /// Called when quick complete is confirmed.
  final VoidCallback? onQuickComplete;

  /// Called when count is incremented for count-type habits.
  final VoidCallback? onCountIncrement;

  /// Called when the card is long-pressed (for context menu).
  final VoidCallback? onLongPress;

  const HabitCard({
    super.key,
    required this.todayHabit,
    this.onQuickComplete,
    this.onCountIncrement,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final habit = todayHabit.habit;
    final isCompleted = todayHabit.isCompletedToday;
    final score = habit.score;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habitId: habit.id),
            ),
          );
        },
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Habit icon button (left)
              _HabitIconButton(
                todayHabit: todayHabit,
                onTap: () => _openTimer(context, habit),
                onLongPress: () => _showQuickCompleteDialog(context),
                onCountIncrement: onCountIncrement,
              ),
              const Gap(12),

              // Habit info (middle)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? Theme.of(context).textTheme.bodySmall?.color
                                : null,
                          ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const Gap(4),
                        Text(
                          _formatTime(habit.scheduledTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (habit.location != null &&
                            habit.location!.isNotEmpty) ...[
                          const Gap(12),
                          Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const Gap(4),
                          Expanded(
                            child: Text(
                              habit.location!,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Flame score (right)
              FlameScore(score: score, size: 44),
            ],
          ),
        ),
      ),
    );
  }

  void _openTimer(BuildContext context, Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimerScreen(habit: habit),
      ),
    );
  }

  void _showQuickCompleteDialog(BuildContext context) {
    if (todayHabit.isCompletedToday || onQuickComplete == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Complete'),
        content: const Text(
          'Complete this habit without starting the timer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onQuickComplete?.call();
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String scheduledTime) {
    try {
      final parts = scheduledTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final time = DateTime(2000, 1, 1, hour, minute);
      return DateFormat.jm().format(time);
    } catch (e) {
      return scheduledTime;
    }
  }
}

/// Icon button showing the habit icon with progress ring and completion state.
class _HabitIconButton extends StatelessWidget {
  final TodayHabit todayHabit;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onCountIncrement;

  const _HabitIconButton({
    required this.todayHabit,
    required this.onTap,
    required this.onLongPress,
    this.onCountIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = todayHabit.habit;
    final isCompleted = todayHabit.isCompletedToday;
    final isCountType = todayHabit.isCountType;
    final isWeeklyType = todayHabit.isWeeklyType;
    final score = habit.score;
    final color = AppColors.getFlameColor(score);

    // Get the icon
    final iconData = getIconData(habit.icon);

    // Determine progress for count/weekly types
    double? progress;
    String? progressText;
    if (isCountType) {
      progress = todayHabit.countProgress;
      progressText = '${todayHabit.todayCount}/${todayHabit.countTarget}';
    } else if (isWeeklyType) {
      progress = todayHabit.weeklyProgress;
      progressText = '${todayHabit.weeklyCount}/${todayHabit.weeklyTarget}';
    }

    // For count type habits, tap increments the count
    final effectiveOnTap = isCountType && !isCompleted && onCountIncrement != null
        ? onCountIncrement!
        : onTap;

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: isCountType
            ? 'Tap to add one'
            : isCompleted
                ? 'Completed'
                : 'Tap for timer, hold to quick complete',
        child: InkWell(
          onTap: effectiveOnTap,
          onLongPress: isCompleted ? null : onLongPress,
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? color.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                ),

                // Progress ring (for count/weekly types)
                if (progress != null && !isCompleted)
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),

                // Icon
                Icon(
                  iconData,
                  size: 28,
                  color: isCompleted ? color : theme.colorScheme.onSurfaceVariant,
                ),

                // Completion tick overlay
                if (isCompleted)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),

                // Progress text (for count/weekly when not completed)
                if (progressText != null && !isCompleted)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: color.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        progressText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
