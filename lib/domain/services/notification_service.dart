import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../../data/database/app_database.dart';

/// Service for managing habit notifications.
///
/// Handles:
/// - Pre-reminders (X minutes before scheduled time)
/// - Post-reminders (X minutes after if not completed)
/// - Quiet hours (no notifications during specified times)
/// - Break mode (all notifications paused)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service.
  Future<void> initialize() async {
    if (_initialized) return;

    // Skip on web - notifications not supported
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Request notification permissions (iOS/Android 13+).
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final result = await android?.requestNotificationsPermission();
      return result ?? false;
    }

    return false;
  }

  /// Schedule notifications for a habit.
  ///
  /// Schedules:
  /// - Pre-reminder: [preMinutes] before scheduled time
  /// - Post-reminder: [postMinutes] after scheduled time
  Future<void> scheduleHabitNotifications({
    required Habit habit,
    required int preMinutes,
    required int postMinutes,
    required String quietHoursStart,
    required String quietHoursEnd,
    required bool notificationsEnabled,
    DateTime? breakModeUntil,
  }) async {
    if (kIsWeb) return;
    if (!notificationsEnabled) return;

    // Check if in break mode
    if (breakModeUntil != null && DateTime.now().isBefore(breakModeUntil)) {
      return;
    }

    // Cancel existing notifications for this habit
    await cancelHabitNotifications(habit.id);

    // Parse habit scheduled time
    final timeParts = habit.scheduledTime.split(':');
    final habitHour = int.parse(timeParts[0]);
    final habitMinute = int.parse(timeParts[1]);

    // Get next occurrence of this time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      habitHour,
      habitMinute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Schedule pre-reminder
    final preReminderTime = scheduledDate.subtract(Duration(minutes: preMinutes));
    if (preReminderTime.isAfter(now) &&
        !_isInQuietHours(preReminderTime, quietHoursStart, quietHoursEnd)) {
      await _scheduleNotification(
        id: _getNotificationId(habit.id, isPreReminder: true),
        title: 'Upcoming: ${habit.name}',
        body: _getPreReminderBody(habit, preMinutes),
        scheduledTime: preReminderTime,
        payload: 'habit:${habit.id}:pre',
      );
    }

    // Schedule post-reminder
    final postReminderTime = scheduledDate.add(Duration(minutes: postMinutes));
    if (!_isInQuietHours(postReminderTime, quietHoursStart, quietHoursEnd)) {
      await _scheduleNotification(
        id: _getNotificationId(habit.id, isPreReminder: false),
        title: habit.name,
        body: _getPostReminderBody(habit),
        scheduledTime: postReminderTime,
        payload: 'habit:${habit.id}:post',
      );
    }
  }

  /// Cancel all notifications for a habit.
  Future<void> cancelHabitNotifications(String habitId) async {
    if (kIsWeb) return;

    await _notifications.cancel(_getNotificationId(habitId, isPreReminder: true));
    await _notifications.cancel(_getNotificationId(habitId, isPreReminder: false));
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }

  /// Reschedule notifications for all habits.
  Future<void> rescheduleAllHabitNotifications({
    required List<Habit> habits,
    required int preMinutes,
    required int postMinutes,
    required String quietHoursStart,
    required String quietHoursEnd,
    required bool notificationsEnabled,
    DateTime? breakModeUntil,
  }) async {
    if (kIsWeb) return;

    // Cancel all first
    await cancelAllNotifications();

    if (!notificationsEnabled) return;

    // Schedule for each active habit
    for (final habit in habits) {
      if (!habit.isArchived) {
        await scheduleHabitNotifications(
          habit: habit,
          preMinutes: preMinutes,
          postMinutes: postMinutes,
          quietHoursStart: quietHoursStart,
          quietHoursEnd: quietHoursEnd,
          notificationsEnabled: notificationsEnabled,
          breakModeUntil: breakModeUntil,
        );
      }
    }
  }

  // Private methods

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      'Habit Reminders',
      channelDescription: 'Notifications for habit reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to habit detail
    // This will be expanded in future milestones
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Check if a time falls within quiet hours.
  bool _isInQuietHours(
    DateTime time,
    String quietStart,
    String quietEnd,
  ) {
    final startParts = quietStart.split(':');
    final endParts = quietEnd.split(':');

    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);

    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    // Handle overnight quiet hours (e.g., 22:00 - 07:00)
    if (startMinutes > endMinutes) {
      // Quiet hours span midnight
      return timeMinutes >= startMinutes || timeMinutes < endMinutes;
    } else {
      // Quiet hours within same day
      return timeMinutes >= startMinutes && timeMinutes < endMinutes;
    }
  }

  /// Generate a unique notification ID from habit ID.
  int _getNotificationId(String habitId, {required bool isPreReminder}) {
    // Use hash of habit ID + offset for pre/post
    final baseId = habitId.hashCode.abs() % 100000;
    return isPreReminder ? baseId : baseId + 100000;
  }

  String _getPreReminderBody(Habit habit, int minutes) {
    if (habit.quickWhy != null && habit.quickWhy!.isNotEmpty) {
      return '${habit.quickWhy} - in $minutes minutes';
    }
    return 'Coming up in $minutes minutes';
  }

  String _getPostReminderBody(Habit habit) {
    if (habit.quickWhy != null && habit.quickWhy!.isNotEmpty) {
      return 'Remember: ${habit.quickWhy}';
    }
    return 'Did you complete this habit?';
  }
}
