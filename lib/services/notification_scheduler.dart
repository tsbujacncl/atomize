import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'decay_service.dart';
import 'notification_service.dart';

class NotificationScheduler {
  final NotificationService _notificationService = NotificationService();

  Future<void> scheduleHabitReminders(List<Habit> habits) async {
    // Cancel all existing to reschedule based on new state
    // In a real app, we would be more surgical, but for MVP this ensures accuracy
    await _notificationService.cancelAllNotifications();

    for (var habit in habits) {
      await _scheduleForHabit(habit);
    }
  }

  Future<void> _scheduleForHabit(Habit habit) async {
    // We want to schedule reminders at key decay points if the habit isn't performed.
    // 1. At 75% strength (Encouragement)
    // 2. At 50% strength (Half-Life warning)
    // 3. At 25% strength (Critical)
    
    // Calculate WHEN these thresholds will be reached
    final now = DateTime.now();
    final lastPerformed = habit.lastPerformed ?? habit.createdAt;
    
    // Calculate time until 75%
    final timeTo75 = _timeUntilStrength(habit, 75.0);
    if (timeTo75 != null && timeTo75.isAfter(now)) {
      await _scheduleNotification(
        habit: habit,
        time: timeTo75,
        type: _NotificationType.encouragement,
      );
    }

    // Calculate time until 50% (Half-Life)
    // This is simply lastPerformed + halfLife
    final timeTo50 = lastPerformed.add(Duration(seconds: habit.halfLifeSeconds));
    if (timeTo50.isAfter(now)) {
      await _scheduleNotification(
        habit: habit,
        time: timeTo50,
        type: _NotificationType.halfLife,
      );
    }

    // Calculate time until 25%
    // Decay formula: N(t) = N0 * (0.5)^(t/H)
    // 25 = 100 * (0.5)^(t/H) -> 0.25 = 0.5^(t/H) -> t/H = 2 -> t = 2H
    final timeTo25 = lastPerformed.add(Duration(seconds: habit.halfLifeSeconds * 2));
    if (timeTo25.isAfter(now)) {
       await _scheduleNotification(
        habit: habit,
        time: timeTo25,
        type: _NotificationType.critical,
      );
    }
  }
  
  DateTime? _timeUntilStrength(Habit habit, double targetStrength) {
    // N(t) = Current * (0.5)^(delta/H)
    // target = current * (0.5)^(delta/H)
    // target/current = 0.5^(delta/H)
    // log(target/current) / log(0.5) = delta/H
    // delta = H * (log(target/current) / log(0.5))
    
    final currentStrength = DecayService.calculateCurrentStrength(habit);
    if (currentStrength <= targetStrength) return null; // Already passed
    
    final ratio = targetStrength / currentStrength;
    final deltaSeconds = habit.halfLifeSeconds * (log(ratio) / log(0.5));
    
    return DateTime.now().add(Duration(seconds: deltaSeconds.toInt()));
  }

  Future<void> _scheduleNotification({
    required Habit habit,
    required DateTime time,
    required _NotificationType type,
  }) async {
    // Use hash of habit ID + type index as notification ID
    final int id = (habit.id.hashCode + type.index).abs();
    
    final String title = _getTitle(type, habit);
    final String body = _getBody(type, habit);

    await _notificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: time,
    );
  }

  String _getTitle( _NotificationType type, Habit habit) {
    switch (type) {
      case _NotificationType.encouragement:
        return "Keep it up! ${habit.name}";
      case _NotificationType.halfLife:
        return "${habit.name} is fading...";
      case _NotificationType.critical:
        return "Critical Alert: ${habit.name}";
    }
  }

  String _getBody(_NotificationType type, Habit habit) {
    // Use "Why" if available
    final purpose = habit.purpose;
    
    switch (type) {
      case _NotificationType.encouragement:
        if (purpose?.feelStatement != null) {
          return "Want to feel ${purpose!.feelStatement}? A quick session helps.";
        }
        return "You're doing great. Keep the momentum going!";
        
      case _NotificationType.halfLife:
        if (purpose?.becomeStatement != null) {
          return "Remember, you are becoming ${purpose!.becomeStatement}. Don't let it slip.";
        }
        return "Your habit strength has dropped to 50%. Time to recharge?";
        
      case _NotificationType.critical:
        if (purpose?.achieveStatement != null) {
          return "Don't lose your progress on '${purpose!.achieveStatement}'. Act now!";
        }
        return "Strength is critical (25%). Perform your habit to save it!";
    }
  }
}

enum _NotificationType {
  encouragement,
  halfLife,
  critical
}

