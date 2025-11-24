import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/preferences_repository.dart';
import 'repository_providers.dart';

/// Provides a stream of user preferences.
final preferencesStreamProvider = StreamProvider<UserPreference?>((ref) {
  final repo = ref.watch(preferencesRepositoryProvider);
  return repo.watch();
});

/// AsyncNotifier for managing user preferences.
class PreferencesNotifier extends AsyncNotifier<UserPreference?> {
  @override
  Future<UserPreference?> build() async {
    final repo = ref.watch(preferencesRepositoryProvider);
    return repo.get();
  }

  PreferencesRepository get _repo => ref.read(preferencesRepositoryProvider);

  /// Update quiet hours.
  Future<void> updateQuietHours({
    required String start,
    required String end,
  }) async {
    await _repo.updateQuietHours(start: start, end: end);
    ref.invalidateSelf();
  }

  /// Update day boundary hour.
  Future<void> updateDayBoundary(int hour) async {
    await _repo.updateDayBoundary(hour);
    ref.invalidateSelf();
  }

  /// Mark onboarding as completed.
  Future<void> completeOnboarding() async {
    await _repo.completeOnboarding();
    ref.invalidateSelf();
  }

  /// Update theme mode.
  Future<void> updateThemeMode(String mode) async {
    await _repo.updateThemeMode(mode);
    ref.invalidateSelf();
  }

  /// Enable or disable notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _repo.setNotificationsEnabled(enabled);
    ref.invalidateSelf();
  }

  /// Set break mode until a specific date.
  Future<void> setBreakMode(DateTime? until) async {
    await _repo.setBreakMode(until);
    ref.invalidateSelf();
  }

  /// Update reminder offsets.
  Future<void> updateReminderOffsets({
    int? preMinutes,
    int? postMinutes,
  }) async {
    await _repo.updateReminderOffsets(
      preMinutes: preMinutes,
      postMinutes: postMinutes,
    );
    ref.invalidateSelf();
  }

  /// Update weekly summary settings.
  Future<void> updateWeeklySummarySettings({int? day, String? time}) async {
    await _repo.updateWeeklySummarySettings(day: day, time: time);
    ref.invalidateSelf();
  }

  /// Record that weekly summary was shown.
  Future<void> recordWeeklySummaryShown() async {
    await _repo.recordWeeklySummaryShown(DateTime.now());
    ref.invalidateSelf();
  }
}

/// Provider for the PreferencesNotifier.
final preferencesNotifierProvider =
    AsyncNotifierProvider<PreferencesNotifier, UserPreference?>(
        PreferencesNotifier.new);

/// Provides whether onboarding is completed.
final isOnboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(preferencesNotifierProvider.future);
  return prefs?.onboardingCompleted ?? false;
});

/// Provides whether the app is in break mode.
final isInBreakModeProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(preferencesRepositoryProvider);
  return repo.isInBreakMode();
});

/// Provides the current theme mode.
final currentThemeModeProvider = FutureProvider<String>((ref) async {
  final prefs = await ref.watch(preferencesNotifierProvider.future);
  return prefs?.themeMode ?? 'system';
});
