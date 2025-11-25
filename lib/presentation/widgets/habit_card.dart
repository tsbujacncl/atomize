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

  const HabitCard({
    super.key,
    required this.todayHabit,
    this.onQuickComplete,
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
                habit: habit,
                score: score,
                isCompleted: isCompleted,
                onQuickComplete: onQuickComplete,
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
              Column(
                children: [
                  Text(
                    '${score.round()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.getFlameColor(score),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'score',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
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
  final Habit habit;
  final double score;
  final bool isCompleted;
  final VoidCallback? onQuickComplete;

  const _ActionButtons({
    required this.habit,
    required this.score,
    required this.isCompleted,
    this.onQuickComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      // Show completed state - single checkmark
      return _CompletedButton(score: score);
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

/// Button showing completed state.
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
