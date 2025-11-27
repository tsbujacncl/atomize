import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/date_habits_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/flame_widget.dart';

/// Screen displaying habits for a past day.
class PastDayScreen extends ConsumerWidget {
  final DateTime date;

  const PastDayScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateHabitsAsync = ref.watch(dateHabitsProvider(date));
    final theme = Theme.of(context);

    // Format the date for display
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dateText;
    if (dateOnly == today) {
      dateText = 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('EEEE, MMMM d').format(date);
    }

    // Check if editable (within 7 days)
    final isEditable = isDateEditable(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(dateText),
        centerTitle: true,
      ),
      body: dateHabitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const Gap(16),
                  Text(
                    'No habits for this day',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          final completed = habits.where((h) => h.isCompleted).toList();
          final incomplete = habits.where((h) => !h.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Summary card
                        _SummaryCard(
                          completed: completed.length,
                          total: habits.length,
                        ),
                        const Gap(24),

                        // Editable notice
                        if (isEditable) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    'You can still edit completions for this day',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(16),
                        ],

                        // Completed habits
                        if (completed.isNotEmpty) ...[
                          Text(
                            'Completed (${completed.length})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const Gap(8),
                          ...completed.map((h) => _PastDayHabitCard(
                            dateHabit: h,
                            isEditable: isEditable,
                          )),
                          const Gap(16),
                        ],

                        // Incomplete habits
                        if (incomplete.isNotEmpty) ...[
                          Text(
                            'Missed (${incomplete.length})',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                          const Gap(8),
                          ...incomplete.map((h) => _PastDayHabitCard(
                            dateHabit: h,
                            isEditable: isEditable,
                          )),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const Gap(16),
                Text(
                  'Failed to load habits',
                  style: theme.textTheme.titleMedium,
                ),
                const Gap(8),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Summary card showing completion stats.
class _SummaryCard extends StatelessWidget {
  final int completed;
  final int total;

  const _SummaryCard({
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (completed / total * 100).round() : 0;
    final isAllComplete = completed == total && total > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Circular progress
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    strokeWidth: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      isAllComplete ? AppColors.success : AppColors.accent,
                    ),
                  ),
                  Center(
                    child: Text(
                      '$percentage%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),
            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAllComplete ? 'All habits completed!' : '$completed of $total completed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    isAllComplete
                        ? 'Great job keeping up!'
                        : 'Keep building momentum',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isAllComplete)
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }
}

/// Habit card for past day view.
class _PastDayHabitCard extends ConsumerWidget {
  final DateHabit dateHabit;
  final bool isEditable;

  const _PastDayHabitCard({
    required this.dateHabit,
    required this.isEditable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habit = dateHabit.habit;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isEditable ? () => _toggleCompletion(context, ref) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Flame indicator
              FlameWidget(
                score: habit.score,
                size: 32,
                isCompleted: dateHabit.isCompleted,
              ),
              const Gap(12),
              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration: dateHabit.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: dateHabit.isCompleted
                            ? theme.textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                    if (habit.scheduledTime.isNotEmpty) ...[
                      const Gap(2),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const Gap(4),
                          Text(
                            habit.scheduledTime,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Status indicator
              if (isEditable)
                Icon(
                  dateHabit.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: dateHabit.isCompleted
                      ? AppColors.success
                      : theme.colorScheme.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleCompletion(BuildContext context, WidgetRef ref) async {
    final completionRepo = ref.read(completionRepositoryProvider);

    if (dateHabit.isCompleted) {
      // Remove completion - find and delete
      final completions = await completionRepo.getForHabitOnDate(
        dateHabit.habit.id,
        dateHabit.effectiveDate,
      );
      if (completions.isNotEmpty) {
        await completionRepo.deleteCompletion(completions.first.id);
      }
    } else {
      // Add completion for the past date
      await completionRepo.recordCompletion(
        habitId: dateHabit.habit.id,
        effectiveDate: dateHabit.effectiveDate,
        scoreAtCompletion: dateHabit.habit.score,
      );
    }

    // Refresh the provider
    ref.invalidate(dateHabitsProvider(dateHabit.effectiveDate));
  }
}
