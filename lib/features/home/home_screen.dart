import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../models/habit.dart';
import '../../services/decay_service.dart';
import '../habits/create_habit_screen.dart';
import '../habits/habit_details_screen.dart';
import '../habits/habit_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update UI every minute to reflect decay
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atomize'),
        centerTitle: true,
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.science_outlined, size: 64, color: Colors.grey),
                  const Gap(16),
                  Text(
                    'No habits active.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                  const Gap(8),
                  const Text('Create one to start tracking your atomic decay!'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitCard(habit: habit);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateHabitScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      ),
    );
  }
}

class HabitCard extends ConsumerWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate live strength for display
    final double strength = DecayService.calculateCurrentStrength(habit);
    final Color statusColor = _getStatusColor(strength);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HabitDetailsScreen(habit: habit),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
          children: [
            // Circular Indicator
            CircularPercentIndicator(
              radius: 40.0,
              lineWidth: 8.0,
              percent: strength / 100,
              center: Text(
                "${strength.round()}%",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              progressColor: statusColor,
              backgroundColor: Colors.grey.shade200,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animateFromLastPercent: true,
            ),
            const Gap(16),
            // Habit Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (habit.description.isNotEmpty)
                    Text(
                      habit.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Gap(4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                      const Gap(4),
                      Text(
                        'Streak: ${habit.streak}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Button
            IconButton.filledTonal(
              onPressed: () {
                ref.read(habitsProvider.notifier).performHabit(habit.id);
              },
              icon: const Icon(Icons.check),
              tooltip: 'Log Performance',
            ),
          ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(double strength) {
    if (strength > 75) return Colors.green;
    if (strength > 40) return Colors.purple;
    if (strength > 20) return Colors.orange;
    return Colors.red;
  }
}
