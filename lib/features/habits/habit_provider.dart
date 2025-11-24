import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../models/habit.dart';
import '../../models/habit_log.dart';
import '../../services/decay_service.dart';
import '../../services/notification_scheduler.dart';
import 'habit_repository.dart';

part 'habit_provider.g.dart';

@riverpod
HabitRepository habitRepository(Ref ref) {
  return HabitRepository();
}

@riverpod
class Habits extends _$Habits {
  @override
  Future<List<Habit>> build() async {
    final repository = ref.watch(habitRepositoryProvider);
    return repository.getHabits();
  }

  Future<void> _rescheduleNotifications(List<Habit> habits) async {
    await NotificationScheduler().scheduleHabitReminders(habits);
  }

  Future<void> addHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.saveHabit(habit);
    ref.invalidateSelf();
    
    // Schedule notifications for all habits (simplest approach for MVP)
    // Ideally we just add for one, but scheduler clears all to be safe.
    // We need to get the list first? No, invalidateSelf triggers build.
    // But build is async.
    // Let's wait a tick or read directly from repo?
    // Better: Get fresh list from repo.
    final habits = await repository.getHabits();
    await _rescheduleNotifications(habits);
  }

  Future<void> updateHabit(Habit habit) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.updateHabit(habit);
    ref.invalidateSelf();

    final habits = await repository.getHabits();
    await _rescheduleNotifications(habits);
  }

  Future<void> deleteHabit(String id) async {
    final repository = ref.read(habitRepositoryProvider);
    await repository.deleteHabit(id);
    ref.invalidateSelf();

    final habits = await repository.getHabits();
    await _rescheduleNotifications(habits);
  }

  Future<void> performHabit(String id) async {
    final habits = await future;
    final index = habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final habit = habits[index];
    final now = DateTime.now();
    
    // 1. Calculate current decayed strength right before performance
    final strengthBefore = DecayService.calculateCurrentStrength(habit);
    
    // 2. Calculate Recovery Boost
    // Base boost 10%, plus 1% per streak day (capped at some reasonable amount)
    // Logic: New Strength = min(100%, Current + Boost)
    const double baseBoost = 10.0;
    final double streakBonus = habit.streak * 1.0; 
    final double totalBoost = baseBoost + streakBonus;
    
    final double strengthAfter = (strengthBefore + totalBoost).clamp(0.0, 100.0);
    
    // 3. Update Streak logic
    // If last performed was "yesterday" (or within a window), increment streak.
    // If too long ago, reset streak.
    // For simplicity MVP: If performed within 2x half-life? Or just check calendar days?
    // Let's use a simple window: if < 24 hours + buffer since last performed?
    // Actually, habits have different frequencies.
    // Let's stick to a simple rule for now: 
    // If (now - lastPerformed) < (halfLife * 2) -> Increment/Keep Streak
    // Else -> Reset Streak to 1
    // (This is a naive implementation, can be improved later)
    
    int newStreak = habit.streak;
    if (habit.lastPerformed != null) {
      final difference = now.difference(habit.lastPerformed!);
      // If performed within 1.5x half-life (just a guess for "kept alive")
      // Or maybe simpler: if strengthBefore > 0, streak continues?
      // Let's say if strengthBefore > 10% streak continues.
      if (strengthBefore > 10.0) {
        newStreak++;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    // 4. Create Log
    final log = HabitLog(
      id: const Uuid().v4(),
      habitId: habit.id,
      timestamp: now,
      strengthBefore: strengthBefore,
      strengthAfter: strengthAfter,
      wasPerformed: true,
    );

    // 5. Create Updated Habit
    final updatedHabit = Habit(
      id: habit.id,
      name: habit.name,
      description: habit.description,
      createdAt: habit.createdAt,
      halfLifeSeconds: habit.halfLifeSeconds,
      currentStrength: strengthAfter,
      lastPerformed: now,
      streak: newStreak,
      logs: [...habit.logs, log],
      purpose: habit.purpose,
      notificationPrefs: habit.notificationPrefs,
    );

    await updateHabit(updatedHabit);
  }
}
