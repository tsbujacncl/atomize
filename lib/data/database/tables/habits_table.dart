import 'package:drift/drift.dart';

/// Database table for habits
class Habits extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Name of the habit
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Type of habit: binary, count, weekly
  TextColumn get type => text().withDefault(const Constant('binary'))();

  /// Where the habit is performed (optional)
  TextColumn get location => text().nullable()();

  /// Scheduled time of day (stored as "HH:mm")
  TextColumn get scheduledTime => text()();

  /// Current score (0-100)
  RealColumn get score => real().withDefault(const Constant(0.0))();

  /// Maturity level (days with score > 50)
  IntColumn get maturity => integer().withDefault(const Constant(0))();

  /// Quick purpose reminder (1 line)
  TextColumn get quickWhy => text().nullable()();

  /// Deep purpose - How does this habit make you feel?
  TextColumn get feelingWhy => text().nullable()();

  /// Deep purpose - Who are you becoming?
  TextColumn get identityWhy => text().nullable()();

  /// Deep purpose - What will you achieve?
  TextColumn get outcomeWhy => text().nullable()();

  /// Target count for count-type habits (Phase 2)
  IntColumn get countTarget => integer().nullable()();

  /// Weekly target for weekly-type habits (Phase 2)
  IntColumn get weeklyTarget => integer().nullable()();

  /// Habit stacking - ID of habit this comes after (Phase 2)
  TextColumn get afterHabitId => text().nullable()();

  /// When the habit was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Whether the habit is archived (soft delete)
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Last time decay was applied
  DateTimeColumn get lastDecayAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
