// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitPurpose _$HabitPurposeFromJson(Map<String, dynamic> json) => HabitPurpose(
  feelStatement: json['feelStatement'] as String?,
  becomeStatement: json['becomeStatement'] as String?,
  achieveStatement: json['achieveStatement'] as String?,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$HabitPurposeToJson(HabitPurpose instance) =>
    <String, dynamic>{
      'feelStatement': instance.feelStatement,
      'becomeStatement': instance.becomeStatement,
      'achieveStatement': instance.achieveStatement,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => NotificationPreferences(
  enabled: json['enabled'] as bool? ?? true,
  preferredTimes:
      (json['preferredTimes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  tone:
      $enumDecodeNullable(_$NotificationToneEnumMap, json['tone']) ??
      NotificationTone.auto,
  adaptiveLearning: json['adaptiveLearning'] as bool? ?? true,
  styleEffectiveness:
      (json['styleEffectiveness'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  NotificationPreferences instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'preferredTimes': instance.preferredTimes,
  'tone': _$NotificationToneEnumMap[instance.tone]!,
  'adaptiveLearning': instance.adaptiveLearning,
  'styleEffectiveness': instance.styleEffectiveness,
};

const _$NotificationToneEnumMap = {
  NotificationTone.gentle: 'gentle',
  NotificationTone.direct: 'direct',
  NotificationTone.motivational: 'motivational',
  NotificationTone.auto: 'auto',
};

Habit _$HabitFromJson(Map<String, dynamic> json) => Habit(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  halfLifeSeconds: (json['halfLifeSeconds'] as num).toInt(),
  currentStrength: (json['currentStrength'] as num?)?.toDouble() ?? 100.0,
  lastPerformed: json['lastPerformed'] == null
      ? null
      : DateTime.parse(json['lastPerformed'] as String),
  streak: (json['streak'] as num?)?.toInt() ?? 0,
  logs:
      (json['logs'] as List<dynamic>?)
          ?.map((e) => HabitLog.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  purpose: json['purpose'] == null
      ? null
      : HabitPurpose.fromJson(json['purpose'] as Map<String, dynamic>),
  notificationPrefs: json['notificationPrefs'] == null
      ? null
      : NotificationPreferences.fromJson(
          json['notificationPrefs'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$HabitToJson(Habit instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'createdAt': instance.createdAt.toIso8601String(),
  'halfLifeSeconds': instance.halfLifeSeconds,
  'currentStrength': instance.currentStrength,
  'lastPerformed': instance.lastPerformed?.toIso8601String(),
  'streak': instance.streak,
  'logs': instance.logs,
  'purpose': instance.purpose,
  'notificationPrefs': instance.notificationPrefs,
};
