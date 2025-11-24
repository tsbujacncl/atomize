import 'package:json_annotation/json_annotation.dart';
import 'habit_log.dart';

part 'habit.g.dart';

@JsonSerializable()
class HabitPurpose {
  final String? feelStatement;
  final String? becomeStatement;
  final String? achieveStatement;
  final DateTime lastUpdated;

  HabitPurpose({
    this.feelStatement,
    this.becomeStatement,
    this.achieveStatement,
    required this.lastUpdated,
  });

  factory HabitPurpose.fromJson(Map<String, dynamic> json) => _$HabitPurposeFromJson(json);
  Map<String, dynamic> toJson() => _$HabitPurposeToJson(this);
}

enum NotificationTone {
  gentle,
  direct,
  motivational,
  auto
}

@JsonSerializable()
class NotificationPreferences {
  final bool enabled;
  final List<String> preferredTimes; 
  final NotificationTone tone;
  final bool adaptiveLearning;
  final Map<String, double> styleEffectiveness;

  NotificationPreferences({
    this.enabled = true,
    this.preferredTimes = const [],
    this.tone = NotificationTone.auto,
    this.adaptiveLearning = true,
    this.styleEffectiveness = const {},
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);
}

@JsonSerializable()
class Habit {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final int halfLifeSeconds; 
  final double currentStrength;
  final DateTime? lastPerformed;
  final int streak;
  final List<HabitLog> logs;
  final HabitPurpose? purpose;
  final NotificationPreferences? notificationPrefs;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.halfLifeSeconds,
    this.currentStrength = 100.0,
    this.lastPerformed,
    this.streak = 0,
    this.logs = const [],
    this.purpose,
    this.notificationPrefs,
  });

  Duration get halfLife => Duration(seconds: halfLifeSeconds);

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
  Map<String, dynamic> toJson() => _$HabitToJson(this);
}
