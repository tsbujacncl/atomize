import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/habit.dart';
import 'habit_repository.dart';

part 'habit_provider.g.dart';

@riverpod
HabitRepository habitRepository(HabitRepositoryRef ref) {
  return HabitRepository();
}

@riverpod
class Habits extends _$Habits {
  @override
  Future<List<Habit>> build() async {
    final repository = ref.watch(habitRepositoryProvider);
    return repository.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.saveHabit(habit);
    ref.invalidateSelf();
  }

  Future<void> updateHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.updateHabit(habit);
    ref.invalidateSelf();
  }

  Future<void> deleteHabit(String id) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.deleteHabit(id);
    ref.invalidateSelf();
  }
}

