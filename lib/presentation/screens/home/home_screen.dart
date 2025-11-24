import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../providers/today_habits_provider.dart';
import '../../providers/score_provider.dart';
import '../../widgets/habit_card.dart';
import '../create_habit/create_habit_screen.dart';
import '../settings/settings_screen.dart';

/// Main home screen displaying today's habits.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayHabitsAsync = ref.watch(todayHabitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: todayHabitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const _EmptyState();
          }
          return _HabitList(habits: habits);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const Gap(16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Gap(8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateHabitScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      ),
    );
  }
}

/// Empty state when no habits exist.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const Gap(24),
            Text(
              'No habits yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Gap(8),
            Text(
              'Create your first habit to get started.\nSmall steps lead to big changes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateHabitScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create First Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of habits for today.
class _HabitList extends ConsumerWidget {
  final List<TodayHabit> habits;

  const _HabitList({required this.habits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Separate completed and incomplete habits
    final incomplete = habits.where((h) => !h.isCompletedToday).toList();
    final completed = habits.where((h) => h.isCompletedToday).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        // Incomplete habits
        if (incomplete.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'To Do',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          ...incomplete.map(
            (habit) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitCard(
                todayHabit: habit,
                onComplete: () => _completeHabit(ref, habit.habit.id),
              ),
            ),
          ),
        ],

        // Completed habits
        if (completed.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Completed',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          ...completed.map(
            (habit) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HabitCard(
                todayHabit: habit,
                onComplete: null, // Already completed
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _completeHabit(WidgetRef ref, String habitId) async {
    await ref.read(completionNotifierProvider.notifier).completeHabit(
          habitId: habitId,
        );
  }
}
