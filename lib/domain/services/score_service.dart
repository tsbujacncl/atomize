import 'dart:math' as math;

import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/completion_repository.dart';
import '../../data/repositories/preferences_repository.dart';
import '../models/enums.dart';

/// Service for calculating habit scores based on the flame system.
///
/// Score range: 0-100
/// - Gain: Applied when habit is completed
/// - Decay: Applied at day boundary (4am default) if habit was missed
///
/// Formulas from design document:
/// - baseGain = 10 * pow(1 - currentScore / 100, 0.7)
/// - baseDecay = (3 + score * 0.05) * (1 / (1 + maturity * 0.03))
class ScoreService {
  final HabitRepository _habitRepository;
  final CompletionRepository _completionRepository;
  final PreferencesRepository _preferencesRepository;

  ScoreService({
    required HabitRepository habitRepository,
    required CompletionRepository completionRepository,
    required PreferencesRepository preferencesRepository,
  })  : _habitRepository = habitRepository,
        _completionRepository = completionRepository,
        _preferencesRepository = preferencesRepository;

  /// Calculate score gain for completing a habit.
  ///
  /// Gain is inversely proportional to current score (diminishing returns).
  /// This makes it easier to build up from low scores but harder to
  /// maintain very high scores.
  ///
  /// Examples (from design doc):
  /// - Score 0: +10.0 points
  /// - Score 30: +8.1 points
  /// - Score 50: +6.5 points
  /// - Score 70: +4.6 points
  /// - Score 90: +2.2 points
  double calculateGain(double currentScore) {
    if (currentScore >= 100) return 0;
    return 10 * math.pow(1 - currentScore / 100, 0.7).toDouble();
  }

  /// Calculate score decay for missing a habit.
  ///
  /// Decay scales with current score and decreases with maturity.
  /// Higher scores decay faster, but mature habits are more resilient.
  ///
  /// Examples:
  /// - Score 20, maturity 0: -4.0 points
  /// - Score 50, maturity 0: -5.5 points
  /// - Score 80, maturity 0: -7.0 points
  /// - Score 50, maturity 30: -2.9 points (maturity protection)
  double calculateDecay(double currentScore, int maturity) {
    if (currentScore <= 0) return 0;
    final baseDecay = 3 + currentScore * 0.05;
    final maturityProtection = 1 / (1 + maturity * 0.03);
    return baseDecay * maturityProtection;
  }

  /// Apply a completion to a habit.
  ///
  /// [habitId] - The habit being completed
  /// [source] - How the completion was recorded
  /// [creditPercentage] - Credit percentage (100 same day, 75 yesterday, etc.)
  ///
  /// Returns the new score after completion.
  Future<double> applyCompletion({
    required String habitId,
    CompletionSource source = CompletionSource.manual,
    double creditPercentage = 100.0,
  }) async {
    final habit = await _habitRepository.getById(habitId);
    if (habit == null) throw ArgumentError('Habit not found: $habitId');

    final effectiveDate =
        await _preferencesRepository.getEffectiveDate(DateTime.now());

    // Check if already completed today
    final alreadyCompleted = await _completionRepository.wasCompletedOnDate(
      habitId,
      effectiveDate,
    );
    if (alreadyCompleted) {
      return habit.score; // Already completed, no change
    }

    // Calculate gain with credit percentage
    final baseGain = calculateGain(habit.score);
    final adjustedGain = baseGain * (creditPercentage / 100);
    final newScore = math.min(100.0, habit.score + adjustedGain);

    // Update maturity if score is above 50
    int newMaturity = habit.maturity;
    if (newScore > 50) {
      newMaturity++;
    }

    // Record completion
    await _completionRepository.recordCompletion(
      habitId: habitId,
      effectiveDate: effectiveDate,
      scoreAtCompletion: habit.score,
      source: source,
      creditPercentage: creditPercentage,
    );

    // Update habit score and maturity
    await _habitRepository.updateScore(habitId, newScore, newMaturity);

    return newScore;
  }

  /// Apply day-end decay to all habits that weren't completed.
  ///
  /// Called at day boundary (default 4am) or when app opens.
  /// Handles multi-day gaps: if user hasn't opened app for several days,
  /// decay is applied for each missed day.
  ///
  /// For weekly habits, decay is applied only if the weekly target wasn't met
  /// for the week containing the missed day.
  ///
  /// Returns the number of decay events applied.
  Future<int> applyDayEndDecay() async {
    final now = DateTime.now();
    final todayEffective = await _preferencesRepository.getEffectiveDate(now);
    final habits = await _habitRepository.getAllActive();
    int totalDecayEvents = 0;

    for (final habit in habits) {
      // Determine the starting point for decay check
      // Use lastDecayAt if available, otherwise use createdAt
      DateTime startDate;
      if (habit.lastDecayAt != null) {
        startDate = habit.lastDecayAt!;
      } else {
        // For habits that have never had decay applied,
        // start from the day after creation
        startDate = DateTime(
          habit.createdAt.year,
          habit.createdAt.month,
          habit.createdAt.day,
        );
      }

      // Calculate days between lastDecayAt and today (exclusive of today)
      // We check each day to see if decay should be applied
      var currentScore = habit.score;
      var currentMaturity = habit.maturity;
      var checkDate = startDate.add(const Duration(days: 1));
      final isWeeklyHabit = habit.type == 'weekly';

      while (checkDate.isBefore(todayEffective) ||
          _isSameDay(checkDate, todayEffective)) {
        // Check if habit was completed on the previous day
        // (we're decaying for not completing on checkDate - 1 day)
        final dayToCheck = checkDate.subtract(const Duration(days: 1));

        // Don't check days before the habit was created
        if (dayToCheck.isBefore(DateTime(
          habit.createdAt.year,
          habit.createdAt.month,
          habit.createdAt.day,
        ))) {
          checkDate = checkDate.add(const Duration(days: 1));
          continue;
        }

        bool shouldDecay = false;

        if (isWeeklyHabit) {
          // For weekly habits, only decay if we're at the end of a week
          // and the weekly target wasn't met
          final isEndOfWeek = dayToCheck.weekday == DateTime.sunday;
          if (isEndOfWeek) {
            final weekStart = _getStartOfWeek(dayToCheck);
            final weekEnd = dayToCheck;
            final weeklyCount = await _completionRepository.countCompletedDaysInRange(
              habit.id,
              weekStart,
              weekEnd,
            );
            final weeklyTarget = habit.weeklyTarget ?? 3;
            shouldDecay = weeklyCount < weeklyTarget && currentScore > 0;
          }
        } else {
          // For binary and count habits, decay if not completed that day
          final wasCompleted = await _completionRepository.wasCompletedOnDate(
            habit.id,
            dayToCheck,
          );
          shouldDecay = !wasCompleted && currentScore > 0;
        }

        if (shouldDecay) {
          // Apply decay for this missed day
          final decay = calculateDecay(currentScore, currentMaturity);
          currentScore = math.max(0.0, currentScore - decay);
          totalDecayEvents++;
        }

        checkDate = checkDate.add(const Duration(days: 1));
      }

      // Update the habit if score changed
      if (currentScore != habit.score) {
        await _habitRepository.updateScore(habit.id, currentScore, currentMaturity);
      }

      // Always update lastDecayAt to today so we don't reprocess
      await _habitRepository.updateLastDecay(habit.id, todayEffective);
    }

    return totalDecayEvents;
  }

  /// Get the start of the week (Monday at midnight) for a given date.
  DateTime _getStartOfWeek(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Apply partial credit for count-type habits (Phase 2).
  ///
  /// Returns the effective credit percentage based on completion ratio.
  double calculateCountCredit(int achieved, int target) {
    if (target <= 0) return 100.0;
    final ratio = achieved / target;

    if (ratio >= 1.0) return 100.0; // 100% completion
    if (ratio >= 0.6) return 50.0; // 60-99% completion
    if (ratio >= 0.2) return 0.0; // 20-59% no change
    if (ratio > 0) return 0.0; // 1-19% no change
    return -100.0; // 0% full decay
  }

  /// Increment count for a count-type habit.
  ///
  /// Records a completion with countAchieved = [increment].
  /// Applies score gain only when the total reaches the target for the first time.
  ///
  /// Returns the new total count for today.
  Future<int> incrementCount({
    required String habitId,
    int increment = 1,
    CompletionSource source = CompletionSource.manual,
  }) async {
    final habit = await _habitRepository.getById(habitId);
    if (habit == null) throw ArgumentError('Habit not found: $habitId');

    final effectiveDate =
        await _preferencesRepository.getEffectiveDate(DateTime.now());

    // Get current count for today
    final currentCount = await _completionRepository.getTodayCount(
      habitId,
      effectiveDate,
    );
    final target = habit.countTarget ?? 1;
    final wasAlreadyComplete = currentCount >= target;
    final newCount = currentCount + increment;

    // Record the increment
    await _completionRepository.recordCompletion(
      habitId: habitId,
      effectiveDate: effectiveDate,
      scoreAtCompletion: habit.score,
      source: source,
      countAchieved: increment,
      creditPercentage: 100.0,
    );

    // Apply score gain only on first completion of target
    if (!wasAlreadyComplete && newCount >= target) {
      final baseGain = calculateGain(habit.score);
      final newScore = math.min(100.0, habit.score + baseGain);

      // Update maturity if score is above 50
      int newMaturity = habit.maturity;
      if (newScore > 50) {
        newMaturity++;
      }

      await _habitRepository.updateScore(habitId, newScore, newMaturity);
    }

    return newCount;
  }

  /// Check if two dates are the same day.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get the current effective date (accounting for 4am boundary).
  Future<DateTime> getCurrentEffectiveDate() {
    return _preferencesRepository.getEffectiveDate(DateTime.now());
  }
}
