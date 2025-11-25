import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/notification_service.dart';
import 'habit_provider.dart';
import 'preferences_provider.dart';

/// Provider for the notification service singleton.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider that manages notification scheduling.
///
/// Automatically reschedules notifications when habits or preferences change.
final notificationSchedulerProvider = FutureProvider<void>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  final habitsAsync = ref.watch(habitsStreamProvider);
  final prefsAsync = ref.watch(preferencesStreamProvider);

  final habits = habitsAsync.value;
  final prefs = prefsAsync.value;

  if (habits == null || prefs == null) return;

  await notificationService.rescheduleAllHabitNotifications(
    habits: habits,
    preMinutes: prefs.preReminderMinutes,
    postMinutes: prefs.postReminderMinutes,
    quietHoursStart: prefs.quietHoursStart,
    quietHoursEnd: prefs.quietHoursEnd,
    notificationsEnabled: prefs.notificationsEnabled,
    breakModeUntil: prefs.breakModeUntil,
  );
});

/// Initialize notification service and request permissions.
Future<void> initializeNotifications() async {
  final service = NotificationService();
  await service.initialize();
  await service.requestPermissions();
}
