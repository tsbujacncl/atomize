import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../habits/habit_provider.dart';
import '../../models/habit.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atomize'),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(child: Text('No habits yet. Create one!'));
          }
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return ListTile(
                title: Text(habit.name),
                subtitle: Text('Strength: ${habit.currentStrength.toStringAsFixed(1)}%'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create habit screen
          // For MVP, just add a dummy habit
          /*
          final newHabit = Habit(
            id: DateTime.now().toString(),
            name: 'New Habit',
            description: 'Test habit',
            createdAt: DateTime.now(),
            halfLifeSeconds: 86400, // 1 day
          );
          ref.read(habitsProvider.notifier).addHabit(newHabit);
          */
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

