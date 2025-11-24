import 'package:drift/drift.dart';

/// Database table for habit completions
class HabitCompletions extends Table {
  /// Unique identifier (UUID)
  TextColumn get id => text()();

  /// Reference to the habit
  TextColumn get habitId => text()();

  /// When the completion was recorded
  DateTimeColumn get completedAt => dateTime()();

  /// The "logical" date this completion counts for (handles 4am boundary)
  DateTimeColumn get effectiveDate => dateTime()();

  /// How the completion was recorded
  TextColumn get source => text().withDefault(const Constant('manual'))();

  /// Score at the time of completion (for history)
  RealColumn get scoreAtCompletion => real()();

  /// Count achieved (for count-type habits, Phase 2)
  IntColumn get countAchieved => integer().nullable()();

  /// Credit percentage (100% same day, 75% yesterday, etc.)
  RealColumn get creditPercentage =>
      real().withDefault(const Constant(100.0))();

  @override
  Set<Column> get primaryKey => {id};
}
