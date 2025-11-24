import '../database/app_database.dart';
import '../database/daos/preferences_dao.dart';

/// Repository for user preferences operations
class PreferencesRepository {
  final PreferencesDao _dao;

  PreferencesRepository(this._dao);

  /// Get the user preferences
  Future<UserPreference?> get() => _dao.get();

  /// Watch the user preferences (reactive)
  Stream<UserPreference?> watch() => _dao.watch();

  /// Update quiet hours
  Future<void> updateQuietHours({
    required String start,
    required String end,
  }) =>
      _dao.updateQuietHours(start, end);

  /// Update day boundary hour (0-23)
  Future<void> updateDayBoundary(int hour) => _dao.updateDayBoundary(hour);

  /// Mark onboarding as completed
  Future<void> completeOnboarding() => _dao.completeOnboarding();

  /// Update theme mode ('system', 'light', 'dark')
  Future<void> updateThemeMode(String mode) => _dao.updateThemeMode(mode);

  /// Enable or disable notifications
  Future<void> setNotificationsEnabled(bool enabled) =>
      _dao.setNotificationsEnabled(enabled);

  /// Set break mode until a specific date, or null to end break mode
  Future<void> setBreakMode(DateTime? until) => _dao.setBreakMode(until);

  /// Update reminder offsets in minutes
  Future<void> updateReminderOffsets({int? preMinutes, int? postMinutes}) =>
      _dao.updateReminderOffsets(
        preMinutes: preMinutes,
        postMinutes: postMinutes,
      );

  /// Update weekly summary settings
  Future<void> updateWeeklySummarySettings({int? day, String? time}) =>
      _dao.updateWeeklySummarySettings(day: day, time: time);

  /// Record that weekly summary was shown
  Future<void> recordWeeklySummaryShown(DateTime timestamp) =>
      _dao.recordWeeklySummaryShown(timestamp);

  /// Check if currently in break mode
  Future<bool> isInBreakMode() async {
    final prefs = await get();
    if (prefs == null || prefs.breakModeUntil == null) return false;
    return prefs.breakModeUntil!.isAfter(DateTime.now());
  }

  /// Check if time is within quiet hours
  Future<bool> isQuietHours(DateTime time) async {
    final prefs = await get();
    if (prefs == null) return false;

    final startParts = prefs.quietHoursStart.split(':');
    final endParts = prefs.quietHoursEnd.split(':');

    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    final currentMinutes = time.hour * 60 + time.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    // Handle overnight quiet hours (e.g., 22:00 - 07:00)
    if (startMinutes > endMinutes) {
      // Quiet hours span midnight
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    } else {
      // Quiet hours within same day
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
  }

  /// Get the effective date for a given timestamp, accounting for day boundary
  Future<DateTime> getEffectiveDate(DateTime timestamp) async {
    final prefs = await get();
    final dayBoundaryHour = prefs?.dayBoundaryHour ?? 4;

    // If before day boundary, the effective date is yesterday
    if (timestamp.hour < dayBoundaryHour) {
      return DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day - 1,
      );
    }

    return DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );
  }
}
