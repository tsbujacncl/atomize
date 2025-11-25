import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import 'habit_provider.dart';

/// Habits that are eligible for a deep purpose prompt.
///
/// A habit is eligible if:
/// - It's at least 7 days old
/// - It doesn't have any deep purpose fields filled (feeling/identity/outcome)
/// - Quick why alone doesn't count - we want deeper reflection
final habitsNeedingPurposePromptProvider = FutureProvider<List<Habit>>((ref) async {
  final habits = await ref.watch(habitsStreamProvider.future);
  final now = DateTime.now();
  const minDaysForPrompt = 7;

  return habits.where((habit) {
    // Check if habit is at least 7 days old
    final daysSinceCreated = now.difference(habit.createdAt).inDays;
    if (daysSinceCreated < minDaysForPrompt) return false;

    // Check if deep purpose is missing
    final hasDeepPurpose = (habit.feelingWhy != null && habit.feelingWhy!.isNotEmpty) ||
        (habit.identityWhy != null && habit.identityWhy!.isNotEmpty) ||
        (habit.outcomeWhy != null && habit.outcomeWhy!.isNotEmpty);

    return !hasDeepPurpose;
  }).toList();
});

/// Returns the first habit that needs a purpose prompt, if any.
final nextPurposePromptProvider = FutureProvider<Habit?>((ref) async {
  final habitsNeedingPrompt = await ref.watch(habitsNeedingPurposePromptProvider.future);
  if (habitsNeedingPrompt.isEmpty) return null;

  // Return the oldest habit first (most overdue for reflection)
  habitsNeedingPrompt.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return habitsNeedingPrompt.first;
});

/// Whether to show a purpose prompt banner on the home screen.
final shouldShowPurposePromptProvider = FutureProvider<bool>((ref) async {
  final nextPrompt = await ref.watch(nextPurposePromptProvider.future);
  return nextPrompt != null;
});
