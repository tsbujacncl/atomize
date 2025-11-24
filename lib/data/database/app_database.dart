import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  int get schemaVersion => 1;

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
        // Handle future migrations here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'atomize.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
