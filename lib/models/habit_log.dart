import 'package:json_annotation/json_annotation.dart';

part 'habit_log.g.dart';

@JsonSerializable()
class HabitLog {
  final String id;
  final String habitId;
  final DateTime timestamp;
  final double strengthBefore;
  final double strengthAfter;
  final bool wasPerformed;
  final String? notificationStyle;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.timestamp,
    required this.strengthBefore,
    required this.strengthAfter,
    required this.wasPerformed,
    this.notificationStyle,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) => _$HabitLogFromJson(json);
  Map<String, dynamic> toJson() => _$HabitLogToJson(this);
}
