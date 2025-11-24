import 'package:hive/hive.dart';
import 'habit.dart';
import 'habit_log.dart';

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
      halfLifeSeconds: fields[4] as int,
      currentStrength: fields[5] as double,
      lastPerformed: fields[6] as DateTime?,
      streak: fields[7] as int,
      logs: (fields[8] as List).cast<HabitLog>(),
      purpose: fields[9] as HabitPurpose?,
      notificationPrefs: fields[10] as NotificationPreferences?,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.halfLifeSeconds)
      ..writeByte(5)
      ..write(obj.currentStrength)
      ..writeByte(6)
      ..write(obj.lastPerformed)
      ..writeByte(7)
      ..write(obj.streak)
      ..writeByte(8)
      ..write(obj.logs)
      ..writeByte(9)
      ..write(obj.purpose)
      ..writeByte(10)
      ..write(obj.notificationPrefs);
  }
}

class HabitLogAdapter extends TypeAdapter<HabitLog> {
  @override
  final int typeId = 1;

  @override
  HabitLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitLog(
      id: fields[0] as String,
      habitId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      strengthBefore: fields[3] as double,
      strengthAfter: fields[4] as double,
      wasPerformed: fields[5] as bool,
      notificationStyle: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.strengthBefore)
      ..writeByte(4)
      ..write(obj.strengthAfter)
      ..writeByte(5)
      ..write(obj.wasPerformed)
      ..writeByte(6)
      ..write(obj.notificationStyle);
  }
}

class HabitPurposeAdapter extends TypeAdapter<HabitPurpose> {
  @override
  final int typeId = 2;

  @override
  HabitPurpose read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitPurpose(
      feelStatement: fields[0] as String?,
      becomeStatement: fields[1] as String?,
      achieveStatement: fields[2] as String?,
      lastUpdated: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HabitPurpose obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.feelStatement)
      ..writeByte(1)
      ..write(obj.becomeStatement)
      ..writeByte(2)
      ..write(obj.achieveStatement)
      ..writeByte(3)
      ..write(obj.lastUpdated);
  }
}

class NotificationPreferencesAdapter extends TypeAdapter<NotificationPreferences> {
  @override
  final int typeId = 3;

  @override
  NotificationPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationPreferences(
      enabled: fields[0] as bool,
      preferredTimes: (fields[1] as List).cast<String>(),
      tone: fields[2] as NotificationTone,
      adaptiveLearning: fields[3] as bool,
      styleEffectiveness: (fields[4] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationPreferences obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.enabled)
      ..writeByte(1)
      ..write(obj.preferredTimes)
      ..writeByte(2)
      ..write(obj.tone)
      ..writeByte(3)
      ..write(obj.adaptiveLearning)
      ..writeByte(4)
      ..write(obj.styleEffectiveness);
  }
}

class NotificationToneAdapter extends TypeAdapter<NotificationTone> {
  @override
  final int typeId = 4;

  @override
  NotificationTone read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationTone.gentle;
      case 1:
        return NotificationTone.direct;
      case 2:
        return NotificationTone.motivational;
      case 3:
        return NotificationTone.auto;
      default:
        return NotificationTone.auto;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationTone obj) {
    switch (obj) {
      case NotificationTone.gentle:
        writer.writeByte(0);
        break;
      case NotificationTone.direct:
        writer.writeByte(1);
        break;
      case NotificationTone.motivational:
        writer.writeByte(2);
        break;
      case NotificationTone.auto:
        writer.writeByte(3);
        break;
    }
  }
}

