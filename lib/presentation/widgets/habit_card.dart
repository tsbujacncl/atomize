import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../providers/today_habits_provider.dart';
import '../screens/habit_detail/habit_detail_screen.dart';
import '../screens/timer/timer_screen.dart';
import 'flame_widget.dart';

/// Card widget displaying a single habit for the home screen.
class HabitCard extends StatelessWidget {
  final TodayHabit todayHabit;

  /// Called when quick complete is tapped (checkmark button).
  final VoidCallback? onQuickComplete;

  /// Called when count is incremented for count-type habits.
  final VoidCallback? onCountIncrement;

  const HabitCard({
    super.key,
    required this.todayHabit,
    this.onQuickComplete,
    this.onCountIncrement,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Action buttons
              _ActionButtons(
                todayHabit: todayHabit,
                onQuickComplete: onQuickComplete,
                onCountIncrement: onCountIncrement,
              ),
              const Gap(16),

              // Habit info
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

              // Score indicator
              Text(
                '${score.round()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.getFlameColor(score),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
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

/// Action buttons for timer and quick complete.
class _ActionButtons extends StatelessWidget {
  final TodayHabit todayHabit;
  final VoidCallback? onQuickComplete;
  final VoidCallback? onCountIncrement;

  const _ActionButtons({
    required this.todayHabit,
    this.onQuickComplete,
    this.onCountIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final habit = todayHabit.habit;
    final score = habit.score;
    final isCompleted = todayHabit.isCompletedToday;
    final isCountType = todayHabit.isCountType;
    final isWeeklyType = todayHabit.isWeeklyType;

    if (isCompleted) {
      // Show completed state
      if (isCountType) {
        return _CountCompletedButton(
          score: score,
          count: todayHabit.todayCount,
          target: todayHabit.countTarget,
        );
      }
      if (isWeeklyType) {
        return _WeeklyCompletedButton(
          score: score,
          count: todayHabit.weeklyCount,
          target: todayHabit.weeklyTarget,
        );
      }
      return _CompletedButton(score: score);
    }

    // For count-type habits, show count progress button
    if (isCountType) {
      return _CountProgressButton(
        score: score,
        count: todayHabit.todayCount,
        target: todayHabit.countTarget,
        progress: todayHabit.countProgress,
        onTap: onCountIncrement,
      );
    }

    // For weekly-type habits, show weekly progress button
    if (isWeeklyType) {
      return _WeeklyProgressButton(
        habit: habit,
        score: score,
        count: todayHabit.weeklyCount,
        target: todayHabit.weeklyTarget,
        progress: todayHabit.weeklyProgress,
        onQuickComplete: onQuickComplete,
      );
    }

    // Show dual buttons: timer flame + quick complete checkmark
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer button (flame) - main action
        _TimerButton(
          habit: habit,
          score: score,
        ),
        const Gap(4),
        // Quick complete button (small checkmark)
        _QuickCompleteButton(
          onTap: onQuickComplete,
        ),
      ],
    );
  }
}

/// Button showing completed state for binary habits.
class _CompletedButton extends StatelessWidget {
  final double score;

  const _CompletedButton({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.getFlameColor(score).withValues(alpha: 0.15),
      ),
      child: Center(
        child: Icon(
          Icons.check_circle,
          size: 32,
          color: AppColors.getFlameColor(score),
        ),
      ),
    );
  }
}

/// Button showing completed state for count-type habits.
class _CountCompletedButton extends StatelessWidget {
  final double score;
  final int count;
  final int target;

  const _CountCompletedButton({
    required this.score,
    required this.count,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getFlameColor(score);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 18,
              color: color,
            ),
            Text(
              '$count/$target',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress button for count-type habits showing count and progress ring.
class _CountProgressButton extends StatelessWidget {
  final double score;
  final int count;
  final int target;
  final double progress;
  final VoidCallback? onTap;

  const _CountProgressButton({
    required this.score,
    required this.count,
    required this.target,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.getFlameColor(score);

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'Tap to add one',
        child: InkWell(
          onTap: onTap,
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
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                // Progress indicator
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
                // Count text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/$target',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Flame button that opens the timer screen.
class _TimerButton extends StatelessWidget {
  final Habit habit;
  final double score;

  const _TimerButton({
    required this.habit,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TimerScreen(habit: habit),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: FlameWidget(
              score: score,
              size: 32,
              animate: false,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small quick complete button.
class _QuickCompleteButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _QuickCompleteButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'Quick complete',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.check,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Button showing completed state for weekly-type habits.
class _WeeklyCompletedButton extends StatelessWidget {
  final double score;
  final int count;
  final int target;

  const _WeeklyCompletedButton({
    required this.score,
    required this.count,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getFlameColor(score);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_view_week,
              size: 18,
              color: color,
            ),
            Text(
              '$count/$target',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress button for weekly-type habits showing week progress and action buttons.
class _WeeklyProgressButton extends StatelessWidget {
  final Habit habit;
  final double score;
  final int count;
  final int target;
  final double progress;
  final VoidCallback? onQuickComplete;

  const _WeeklyProgressButton({
    required this.habit,
    required this.score,
    required this.count,
    required this.target,
    required this.progress,
    this.onQuickComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppColors.getFlameColor(score);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Weekly progress indicator with timer
        Material(
          color: Colors.transparent,
          child: Tooltip(
            message: '$count of $target this week',
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TimerScreen(habit: habit),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    // Progress indicator
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor:
                            theme.colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    // Week icon and count
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_view_week,
                          size: 16,
                          color: color,
                        ),
                        Text(
                          '$count/$target',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Gap(4),
        // Quick complete button
        _QuickCompleteButton(onTap: onQuickComplete),
      ],
    );
  }
}
