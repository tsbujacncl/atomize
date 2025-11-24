import 'package:drift/drift.dart';

/// Database table for user preferences (singleton row)
class UserPreferences extends Table {
  /// Always 1 (singleton)
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// Quiet hours start (stored as "HH:mm", default "22:00")
  TextColumn get quietHoursStart =>
      text().withDefault(const Constant('22:00'))();

  /// Quiet hours end (stored as "HH:mm", default "07:00")
  TextColumn get quietHoursEnd => text().withDefault(const Constant('07:00'))();

  /// Day boundary hour (0-23, default 4 for 4am)
  IntColumn get dayBoundaryHour => integer().withDefault(const Constant(4))();

  /// Whether onboarding has been completed
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  /// Theme mode: system, light, dark
  TextColumn get themeMode => text().withDefault(const Constant('system'))();

  /// Whether notifications are enabled
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();

  /// Pre-reminder offset in minutes (default 30)
  IntColumn get preReminderMinutes =>
      integer().withDefault(const Constant(30))();

  /// Post-reminder offset in minutes (default 30)
  IntColumn get postReminderMinutes =>
      integer().withDefault(const Constant(30))();

  /// Break mode end date (null if not in break mode)
  DateTimeColumn get breakModeUntil => dateTime().nullable()();

  /// Weekly summary day (0=Monday, 6=Sunday, default 6)
  IntColumn get weeklySummaryDay => integer().withDefault(const Constant(6))();

  /// Weekly summary time (stored as "HH:mm", default "18:00")
  TextColumn get weeklySummaryTime =>
      text().withDefault(const Constant('18:00'))();

  /// Last weekly summary shown
  DateTimeColumn get lastWeeklySummaryAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
