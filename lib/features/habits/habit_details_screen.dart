import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../models/habit.dart';
import '../../services/decay_service.dart';
import '../habits/habit_provider.dart';
import 'widgets/decay_chart.dart';
import 'widgets/strength_pie_chart.dart';

class HabitDetailsScreen extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  ConsumerState<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends ConsumerState<HabitDetailsScreen> {
  late Habit _currentHabit;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentHabit = widget.habit;
    // Refresh UI periodically to show decay animation
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        // Force rebuild to update charts
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get updates if the habit changes (e.g. perform action)
    final habitsAsync = ref.watch(habitsProvider);
    
    // Update local habit reference if provider updates
    habitsAsync.whenData((habits) {
      final updated = habits.where((h) => h.id == widget.habit.id).firstOrNull;
      if (updated != null) {
        _currentHabit = updated;
      }
    });

    final double currentStrength = DecayService.calculateCurrentStrength(_currentHabit);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentHabit.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Confirm delete
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Habit?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(habitsProvider.notifier).deleteHabit(_currentHabit.id);
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Close screen
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Section: Pie Chart & Stats
            Center(
              child: StrengthPieChart(
                currentStrength: currentStrength,
                radius: 120,
              ),
            ),
            const Gap(32),

            // 2. Purpose Card
            if (_currentHabit.purpose != null) ...[
              _PurposeCard(purpose: _currentHabit.purpose!),
              const Gap(24),
            ],

            // 3. Decay Graph
            Text(
              'Decay Projection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text(
              'Projected strength over the next 3 half-lives if not performed.',
              style: TextStyle(color: Colors.grey),
            ),
            const Gap(16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DecayChart(habit: _currentHabit),
            ),
            
            const Gap(32),
            
            // 4. Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Streak',
                    value: '${_currentHabit.streak} days',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: _StatCard(
                    label: 'Half-Life',
                    value: _formatDuration(_currentHabit.halfLifeSeconds),
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            
            const Gap(48), // Bottom spacing
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ref.read(habitsProvider.notifier).performHabit(_currentHabit.id);
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Habit performed! Strength boosted.')),
          );
        },
        icon: const Icon(Icons.check),
        label: const Text('Perform Now'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
    return '${duration.inHours}h';
  }
}

class _PurposeCard extends StatelessWidget {
  final HabitPurpose purpose;

  const _PurposeCard({required this.purpose});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Theme.of(context).primaryColor),
                const Gap(8),
                Text(
                  'Your Why',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (purpose.feelStatement != null) _PurposeItem(label: 'Feel', text: purpose.feelStatement!),
            if (purpose.becomeStatement != null) _PurposeItem(label: 'Become', text: purpose.becomeStatement!),
            if (purpose.achieveStatement != null) _PurposeItem(label: 'Achieve', text: purpose.achieveStatement!),
          ],
        ),
      ),
    );
  }
}

class _PurposeItem extends StatelessWidget {
  final String label;
  final String text;

  const _PurposeItem({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const Gap(8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

