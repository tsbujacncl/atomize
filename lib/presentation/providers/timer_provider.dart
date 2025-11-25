import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/database/app_database.dart';
import '../../domain/models/timer_duration.dart';

part 'timer_provider.g.dart';

/// State of the habit timer.
class TimerState {
  /// The habit being timed
  final String habitId;

  /// Total duration of the timer in seconds
  final int totalSeconds;

  /// When the timer was started
  final DateTime startTime;

  /// Total time spent paused (in milliseconds)
  final int pausedDurationMs;

  /// When the current pause started (null if not paused)
  final DateTime? pauseStartTime;

  /// Whether the timer is currently running
  final bool isRunning;

  /// Whether the timer is paused
  final bool isPaused;

  /// Whether the timer has completed
  final bool isCompleted;

  const TimerState({
    required this.habitId,
    required this.totalSeconds,
    required this.startTime,
    this.pausedDurationMs = 0,
    this.pauseStartTime,
    this.isRunning = false,
    this.isPaused = false,
    this.isCompleted = false,
  });

  /// Calculate remaining seconds based on wall clock.
  int get remainingSeconds {
    if (isCompleted) return 0;

    final now = DateTime.now();
    int totalPausedMs = pausedDurationMs;

    // Add current pause duration if paused
    if (isPaused && pauseStartTime != null) {
      totalPausedMs += now.difference(pauseStartTime!).inMilliseconds;
    }

    final elapsedMs = now.difference(startTime).inMilliseconds - totalPausedMs;
    final elapsedSeconds = elapsedMs ~/ 1000;
    final remaining = totalSeconds - elapsedSeconds;

    return remaining.clamp(0, totalSeconds);
  }

  /// Progress from 0.0 to 1.0
  double get progress {
    if (totalSeconds == 0) return 0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  TimerState copyWith({
    String? habitId,
    int? totalSeconds,
    DateTime? startTime,
    int? pausedDurationMs,
    DateTime? pauseStartTime,
    bool? isRunning,
    bool? isPaused,
    bool? isCompleted,
    bool clearPauseStartTime = false,
  }) {
    return TimerState(
      habitId: habitId ?? this.habitId,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      startTime: startTime ?? this.startTime,
      pausedDurationMs: pausedDurationMs ?? this.pausedDurationMs,
      pauseStartTime:
          clearPauseStartTime ? null : (pauseStartTime ?? this.pauseStartTime),
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Manages the timer state for habit completion.
///
/// Auto-disposes when no longer listened to (e.g., when timer screen is popped).
@riverpod
class HabitTimer extends _$HabitTimer {
  Timer? _ticker;

  @override
  TimerState? build() {
    // Clean up ticker when provider is disposed
    ref.onDispose(() {
      _ticker?.cancel();
    });
    return null;
  }

  /// Start a new timer for the given habit.
  void startTimer(Habit habit) {
    _ticker?.cancel();

    final duration =
        habit.timerDuration ?? TimerDurationOption.defaultDuration;

    state = TimerState(
      habitId: habit.id,
      totalSeconds: duration,
      startTime: DateTime.now(),
      isRunning: true,
    );

    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state == null) return;

      // Check if timer has completed
      if (state!.remainingSeconds <= 0 && !state!.isCompleted) {
        state = state!.copyWith(
          isRunning: false,
          isCompleted: true,
        );
        _ticker?.cancel();
      } else if (!state!.isPaused) {
        // Force a state update to refresh UI
        state = state!.copyWith();
      }
    });
  }

  /// Pause the timer.
  void pauseTimer() {
    if (state == null || !state!.isRunning || state!.isPaused) return;

    state = state!.copyWith(
      isPaused: true,
      pauseStartTime: DateTime.now(),
    );
  }

  /// Resume the timer.
  void resumeTimer() {
    if (state == null || !state!.isPaused) return;

    // Calculate how long we were paused
    final pauseDuration =
        DateTime.now().difference(state!.pauseStartTime!).inMilliseconds;

    state = state!.copyWith(
      isPaused: false,
      pausedDurationMs: state!.pausedDurationMs + pauseDuration,
      clearPauseStartTime: true,
    );
  }

  /// Cancel the timer without completing.
  void cancelTimer() {
    _ticker?.cancel();
    state = null;
  }

  /// Check if timer completed while app was in background.
  ///
  /// Call this when app resumes to handle background completion.
  bool checkBackgroundCompletion() {
    if (state == null || state!.isCompleted || state!.isPaused) return false;

    if (state!.remainingSeconds <= 0) {
      state = state!.copyWith(
        isRunning: false,
        isCompleted: true,
      );
      _ticker?.cancel();
      return true;
    }

    return false;
  }
}
