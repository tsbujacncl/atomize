import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/enums.dart';
import '../../domain/services/score_service.dart';
import 'notification_provider.dart';
import 'repository_providers.dart';
import 'habit_provider.dart';
import 'today_habits_provider.dart';

export '../../domain/services/score_service.dart' show CompletionResult;

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
  /// Returns [CompletionResult] with the new score and info needed for undo,
  /// or null if already completed today.
  Future<CompletionResult?> completeHabit({
    required String habitId,
    CompletionSource source = CompletionSource.manual,
    double creditPercentage = 100.0,
  }) async {
    final result = await _scoreService.applyCompletion(
      habitId: habitId,
      source: source,
      creditPercentage: creditPercentage,
    );

    if (result != null) {
      // Cancel pending notifications for this habit
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.cancelHabitNotifications(habitId);
    }

    // Refresh related providers
    ref.invalidate(habitNotifierProvider);
    ref.invalidate(todayHabitsProvider);

    return result;
  }

  /// Undo a habit completion, restoring the previous score.
  Future<void> undoCompletion({
    required String habitId,
    required CompletionResult completionResult,
  }) async {
    await _scoreService.undoCompletion(
      habitId: habitId,
      completionId: completionResult.completionId,
      previousScore: completionResult.previousScore,
      previousMaturity: completionResult.previousMaturity,
    );

    // Refresh related providers
    ref.invalidate(habitNotifierProvider);
    ref.invalidate(todayHabitsProvider);
  }

  /// Increment count for a count-type habit.
  ///
  /// Returns the new total count for today.
  Future<int> incrementCount({
    required String habitId,
    int increment = 1,
    CompletionSource source = CompletionSource.manual,
  }) async {
    final newCount = await _scoreService.incrementCount(
      habitId: habitId,
      increment: increment,
      source: source,
    );

    // Refresh related providers
    ref.invalidate(habitNotifierProvider);
    ref.invalidate(todayHabitsProvider);

    return newCount;
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

/// Provider that applies day-end decay when app starts.
///
/// This should be watched once during app initialization to ensure
/// decay is applied for any missed days since last app open.
/// Returns the number of decay events applied.
final dayBoundaryDecayProvider = FutureProvider<int>((ref) async {
  final scoreService = ref.read(scoreServiceProvider);
  final decayCount = await scoreService.applyDayEndDecay();

  // If any decay was applied, refresh habit providers
  if (decayCount > 0) {
    ref.invalidate(habitNotifierProvider);
    ref.invalidate(todayHabitsProvider);
  }

  return decayCount;
});
