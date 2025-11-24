import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit.dart';

class HabitRepository {
  static const String boxName = 'habits';

  Future<Box<Habit>> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Habit>(boxName);
    }
    return await Hive.openBox<Habit>(boxName);
  }

  Future<List<Habit>> getHabits() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> saveHabit(Habit habit) async {
    final box = await _getBox();
    await box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> updateHabit(Habit habit) async {
    await saveHabit(habit);
  }
}

