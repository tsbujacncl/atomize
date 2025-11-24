import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/enums.dart';
import '../../domain/services/score_service.dart';
import 'repository_providers.dart';
import 'habit_provider.dart';
import 'today_habits_provider.dart';

/// Provides the ScoreService instance.
final scoreServiceProvider = Provider<ScoreService>((ref) {
  return ScoreService(
    habitRepository: ref.watch(habitRepositoryProvider),
    completionRepository: ref.watch(completionRepositoryProvider),
    preferencesRepository: ref.watch(preferencesRepositoryProvider),
  );
});

/// Notifier for handling habit completions.
class CompletionNotifier extends Notifier<void> {
  @override
  void build() {
    // No state to initialize
  }

  ScoreService get _scoreService => ref.read(scoreServiceProvider);

  /// Complete a habit and update its score.
  ///
  /// Returns the new score after completion.
  Future<double> completeHabit({
    required String habitId,
    CompletionSource source = CompletionSource.manual,
    double creditPercentage = 100.0,
  }) async {
    final newScore = await _scoreService.applyCompletion(
      habitId: habitId,
      source: source,
      creditPercentage: creditPercentage,
    );

    // Refresh related providers
    ref.invalidate(habitNotifierProvider);
    ref.invalidate(todayHabitsProvider);

    return newScore;
  }

  /// Apply day-end decay to all habits.
  Future<void> applyDayEndDecay() async {
    await _scoreService.applyDayEndDecay();

    // Refresh related providers
    ref.invalidate(habitNotifierProvider);
    ref.invalidate(todayHabitsProvider);
  }
}

/// Provider for the CompletionNotifier.
final completionNotifierProvider =
    NotifierProvider<CompletionNotifier, void>(CompletionNotifier.new);
