import 'package:flutter/material.dart';

/// Placeholder for habit detail screen (Milestone 7).
class HabitDetailScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
      ),
      body: Center(
        child: Text('Habit Detail Screen - Coming in Milestone 7\n\nHabit ID: $habitId'),
      ),
    );
  }
}
