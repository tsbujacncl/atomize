import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/preferences_table.dart';

part 'preferences_dao.g.dart';

@DriftAccessor(tables: [UserPreferences])
class PreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$PreferencesDaoMixin {
  PreferencesDao(super.db);

  /// Get the user preferences (singleton row)
  Future<UserPreference?> get() {
    return (select(userPreferences)..where((p) => p.id.equals(1)))
        .getSingleOrNull();
  }

  /// Watch the user preferences
  Stream<UserPreference?> watch() {
    return (select(userPreferences)..where((p) => p.id.equals(1)))
        .watchSingleOrNull();
  }

  /// Update preferences
  Future<void> updatePreferences(UserPreferencesCompanion companion) {
    return (update(userPreferences)..where((p) => p.id.equals(1)))
        .write(companion);
  }

  /// Update quiet hours
  Future<void> updateQuietHours(String start, String end) {
    return updatePreferences(
      UserPreferencesCompanion(
        quietHoursStart: Value(start),
        quietHoursEnd: Value(end),
      ),
    );
  }

  /// Update day boundary hour
  Future<void> updateDayBoundary(int hour) {
    return updatePreferences(
      UserPreferencesCompanion(dayBoundaryHour: Value(hour)),
    );
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() {
    return updatePreferences(
      const UserPreferencesCompanion(onboardingCompleted: Value(true)),
    );
  }

  /// Update theme mode
  Future<void> updateThemeMode(String mode) {
    return updatePreferences(
      UserPreferencesCompanion(themeMode: Value(mode)),
    );
  }

  /// Toggle notifications
  Future<void> setNotificationsEnabled(bool enabled) {
    return updatePreferences(
      UserPreferencesCompanion(notificationsEnabled: Value(enabled)),
    );
  }

  /// Set break mode until a specific date
  Future<void> setBreakMode(DateTime? until) {
    return updatePreferences(
      UserPreferencesCompanion(breakModeUntil: Value(until)),
    );
  }

  /// Update reminder offsets
  Future<void> updateReminderOffsets({int? preMinutes, int? postMinutes}) {
    return updatePreferences(
      UserPreferencesCompanion(
        preReminderMinutes:
            preMinutes != null ? Value(preMinutes) : const Value.absent(),
        postReminderMinutes:
            postMinutes != null ? Value(postMinutes) : const Value.absent(),
      ),
    );
  }

  /// Update weekly summary settings
  Future<void> updateWeeklySummarySettings({int? day, String? time}) {
    return updatePreferences(
      UserPreferencesCompanion(
        weeklySummaryDay: day != null ? Value(day) : const Value.absent(),
        weeklySummaryTime: time != null ? Value(time) : const Value.absent(),
      ),
    );
  }

  /// Record that weekly summary was shown
  Future<void> recordWeeklySummaryShown(DateTime timestamp) {
    return updatePreferences(
      UserPreferencesCompanion(lastWeeklySummaryAt: Value(timestamp)),
    );
  }
}
