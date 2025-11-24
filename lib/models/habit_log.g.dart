// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitLog _$HabitLogFromJson(Map<String, dynamic> json) => HabitLog(
  id: json['id'] as String,
  habitId: json['habitId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  strengthBefore: (json['strengthBefore'] as num).toDouble(),
  strengthAfter: (json['strengthAfter'] as num).toDouble(),
  wasPerformed: json['wasPerformed'] as bool,
  notificationStyle: json['notificationStyle'] as String?,
);

Map<String, dynamic> _$HabitLogToJson(HabitLog instance) => <String, dynamic>{
  'id': instance.id,
  'habitId': instance.habitId,
  'timestamp': instance.timestamp.toIso8601String(),
  'strengthBefore': instance.strengthBefore,
  'strengthAfter': instance.strengthAfter,
  'wasPerformed': instance.wasPerformed,
  'notificationStyle': instance.notificationStyle,
};
