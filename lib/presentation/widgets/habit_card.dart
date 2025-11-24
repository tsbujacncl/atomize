import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../providers/today_habits_provider.dart';
import '../screens/habit_detail/habit_detail_screen.dart';
import 'flame_widget.dart';

/// Card widget displaying a single habit for the home screen.
class HabitCard extends StatelessWidget {
  final TodayHabit todayHabit;
  final VoidCallback? onComplete;

  const HabitCard({
    super.key,
    required this.todayHabit,
    this.onComplete,
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
              // Flame button
              _FlameButton(
                score: score,
                isCompleted: isCompleted,
                onTap: onComplete,
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

/// Tappable flame button for completing habits.
class _FlameButton extends StatelessWidget {
  final double score;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _FlameButton({
    required this.score,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.getFlameColor(score).withValues(alpha: 0.15)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_circle,
                    size: 32,
                    color: AppColors.getFlameColor(score),
                  )
                : FlameWidget(
                    score: score,
                    size: 40,
                    animate: false,
                  ),
          ),
        ),
      ),
    );
  }
}
