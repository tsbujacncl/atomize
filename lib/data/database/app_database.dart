import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import 'tables/habits_table.dart';
import 'tables/completions_table.dart';
import 'tables/preferences_table.dart';
import 'daos/habit_dao.dart';
import 'daos/completion_dao.dart';
import 'daos/preferences_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Habits, HabitCompletions, UserPreferences],
  daos: [HabitDao, CompletionDao, PreferencesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing with in-memory database
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Insert default preferences row
        await into(userPreferences).insert(
          UserPreferencesCompanion.insert(),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migration from v1 to v2: Add timerDuration column
        if (from < 2) {
          await customStatement(
            'ALTER TABLE habits ADD COLUMN timer_duration INTEGER',
          );
        }
        // Migration from v2 to v3: Add icon column
        if (from < 3) {
          await customStatement(
            'ALTER TABLE habits ADD COLUMN icon TEXT',
          );
        }
      },
      beforeOpen: (details) async {
        debugPrint('📦 Database beforeOpen - wasCreated: ${details.wasCreated}, '
            'from: ${details.versionBefore}, to: ${details.versionNow}');

        // Ensure default preferences row exists (fixes missing row after migrations)
        final existingPrefs = await (select(userPreferences)
              ..where((p) => p.id.equals(1)))
            .getSingleOrNull();
        if (existingPrefs == null) {
          debugPrint('📦 Creating default preferences row');
          await into(userPreferences).insert(
            UserPreferencesCompanion.insert(),
          );
        } else {
          debugPrint('📦 Preferences exist - onboardingCompleted: ${existingPrefs.onboardingCompleted}');
        }

        // Debug: count habits
        final habitCount = await (selectOnly(habits)..addColumns([habits.id.count()])).getSingle();
        debugPrint('📦 Habit count: ${habitCount.read(habits.id.count())}');
      },
    );
  }
}

QueryExecutor _openConnection() {
  debugPrint('📦 Opening Atomize database...');
  return driftDatabase(
    name: 'atomize',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
      onResult: (result) {
        if (result.missingFeatures.isNotEmpty) {
          debugPrint('📦 Missing browser features: ${result.missingFeatures}');
        }
        debugPrint('📦 Storage: ${result.chosenImplementation}');
      },
    ),
  );
}
