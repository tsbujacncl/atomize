// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('binary'),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<String> scheduledTime = GeneratedColumn<String>(
    'scheduled_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _maturityMeta = const VerificationMeta(
    'maturity',
  );
  @override
  late final GeneratedColumn<int> maturity = GeneratedColumn<int>(
    'maturity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _quickWhyMeta = const VerificationMeta(
    'quickWhy',
  );
  @override
  late final GeneratedColumn<String> quickWhy = GeneratedColumn<String>(
    'quick_why',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feelingWhyMeta = const VerificationMeta(
    'feelingWhy',
  );
  @override
  late final GeneratedColumn<String> feelingWhy = GeneratedColumn<String>(
    'feeling_why',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _identityWhyMeta = const VerificationMeta(
    'identityWhy',
  );
  @override
  late final GeneratedColumn<String> identityWhy = GeneratedColumn<String>(
    'identity_why',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeWhyMeta = const VerificationMeta(
    'outcomeWhy',
  );
  @override
  late final GeneratedColumn<String> outcomeWhy = GeneratedColumn<String>(
    'outcome_why',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countTargetMeta = const VerificationMeta(
    'countTarget',
  );
  @override
  late final GeneratedColumn<int> countTarget = GeneratedColumn<int>(
    'count_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weeklyTargetMeta = const VerificationMeta(
    'weeklyTarget',
  );
  @override
  late final GeneratedColumn<int> weeklyTarget = GeneratedColumn<int>(
    'weekly_target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterHabitIdMeta = const VerificationMeta(
    'afterHabitId',
  );
  @override
  late final GeneratedColumn<String> afterHabitId = GeneratedColumn<String>(
    'after_habit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastDecayAtMeta = const VerificationMeta(
    'lastDecayAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastDecayAt = GeneratedColumn<DateTime>(
    'last_decay_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    location,
    scheduledTime,
    score,
    maturity,
    quickWhy,
    feelingWhy,
    identityWhy,
    outcomeWhy,
    countTarget,
    weeklyTarget,
    afterHabitId,
    createdAt,
    isArchived,
    lastDecayAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('maturity')) {
      context.handle(
        _maturityMeta,
        maturity.isAcceptableOrUnknown(data['maturity']!, _maturityMeta),
      );
    }
    if (data.containsKey('quick_why')) {
      context.handle(
        _quickWhyMeta,
        quickWhy.isAcceptableOrUnknown(data['quick_why']!, _quickWhyMeta),
      );
    }
    if (data.containsKey('feeling_why')) {
      context.handle(
        _feelingWhyMeta,
        feelingWhy.isAcceptableOrUnknown(data['feeling_why']!, _feelingWhyMeta),
      );
    }
    if (data.containsKey('identity_why')) {
      context.handle(
        _identityWhyMeta,
        identityWhy.isAcceptableOrUnknown(
          data['identity_why']!,
          _identityWhyMeta,
        ),
      );
    }
    if (data.containsKey('outcome_why')) {
      context.handle(
        _outcomeWhyMeta,
        outcomeWhy.isAcceptableOrUnknown(data['outcome_why']!, _outcomeWhyMeta),
      );
    }
    if (data.containsKey('count_target')) {
      context.handle(
        _countTargetMeta,
        countTarget.isAcceptableOrUnknown(
          data['count_target']!,
          _countTargetMeta,
        ),
      );
    }
    if (data.containsKey('weekly_target')) {
      context.handle(
        _weeklyTargetMeta,
        weeklyTarget.isAcceptableOrUnknown(
          data['weekly_target']!,
          _weeklyTargetMeta,
        ),
      );
    }
    if (data.containsKey('after_habit_id')) {
      context.handle(
        _afterHabitIdMeta,
        afterHabitId.isAcceptableOrUnknown(
          data['after_habit_id']!,
          _afterHabitIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('last_decay_at')) {
      context.handle(
        _lastDecayAtMeta,
        lastDecayAt.isAcceptableOrUnknown(
          data['last_decay_at']!,
          _lastDecayAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_time'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      maturity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maturity'],
      )!,
      quickWhy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quick_why'],
      ),
      feelingWhy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feeling_why'],
      ),
      identityWhy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity_why'],
      ),
      outcomeWhy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome_why'],
      ),
      countTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count_target'],
      ),
      weeklyTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_target'],
      ),
      afterHabitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_habit_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      lastDecayAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_decay_at'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  /// Unique identifier (UUID)
  final String id;

  /// Name of the habit
  final String name;

  /// Type of habit: binary, count, weekly
  final String type;

  /// Where the habit is performed (optional)
  final String? location;

  /// Scheduled time of day (stored as "HH:mm")
  final String scheduledTime;

  /// Current score (0-100)
  final double score;

  /// Maturity level (days with score > 50)
  final int maturity;

  /// Quick purpose reminder (1 line)
  final String? quickWhy;

  /// Deep purpose - How does this habit make you feel?
  final String? feelingWhy;

  /// Deep purpose - Who are you becoming?
  final String? identityWhy;

  /// Deep purpose - What will you achieve?
  final String? outcomeWhy;

  /// Target count for count-type habits (Phase 2)
  final int? countTarget;

  /// Weekly target for weekly-type habits (Phase 2)
  final int? weeklyTarget;

  /// Habit stacking - ID of habit this comes after (Phase 2)
  final String? afterHabitId;

  /// When the habit was created
  final DateTime createdAt;

  /// Whether the habit is archived (soft delete)
  final bool isArchived;

  /// Last time decay was applied
  final DateTime? lastDecayAt;
  const Habit({
    required this.id,
    required this.name,
    required this.type,
    this.location,
    required this.scheduledTime,
    required this.score,
    required this.maturity,
    this.quickWhy,
    this.feelingWhy,
    this.identityWhy,
    this.outcomeWhy,
    this.countTarget,
    this.weeklyTarget,
    this.afterHabitId,
    required this.createdAt,
    required this.isArchived,
    this.lastDecayAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['scheduled_time'] = Variable<String>(scheduledTime);
    map['score'] = Variable<double>(score);
    map['maturity'] = Variable<int>(maturity);
    if (!nullToAbsent || quickWhy != null) {
      map['quick_why'] = Variable<String>(quickWhy);
    }
    if (!nullToAbsent || feelingWhy != null) {
      map['feeling_why'] = Variable<String>(feelingWhy);
    }
    if (!nullToAbsent || identityWhy != null) {
      map['identity_why'] = Variable<String>(identityWhy);
    }
    if (!nullToAbsent || outcomeWhy != null) {
      map['outcome_why'] = Variable<String>(outcomeWhy);
    }
    if (!nullToAbsent || countTarget != null) {
      map['count_target'] = Variable<int>(countTarget);
    }
    if (!nullToAbsent || weeklyTarget != null) {
      map['weekly_target'] = Variable<int>(weeklyTarget);
    }
    if (!nullToAbsent || afterHabitId != null) {
      map['after_habit_id'] = Variable<String>(afterHabitId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_archived'] = Variable<bool>(isArchived);
    if (!nullToAbsent || lastDecayAt != null) {
      map['last_decay_at'] = Variable<DateTime>(lastDecayAt);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      scheduledTime: Value(scheduledTime),
      score: Value(score),
      maturity: Value(maturity),
      quickWhy: quickWhy == null && nullToAbsent
          ? const Value.absent()
          : Value(quickWhy),
      feelingWhy: feelingWhy == null && nullToAbsent
          ? const Value.absent()
          : Value(feelingWhy),
      identityWhy: identityWhy == null && nullToAbsent
          ? const Value.absent()
          : Value(identityWhy),
      outcomeWhy: outcomeWhy == null && nullToAbsent
          ? const Value.absent()
          : Value(outcomeWhy),
      countTarget: countTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(countTarget),
      weeklyTarget: weeklyTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(weeklyTarget),
      afterHabitId: afterHabitId == null && nullToAbsent
          ? const Value.absent()
          : Value(afterHabitId),
      createdAt: Value(createdAt),
      isArchived: Value(isArchived),
      lastDecayAt: lastDecayAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDecayAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      location: serializer.fromJson<String?>(json['location']),
      scheduledTime: serializer.fromJson<String>(json['scheduledTime']),
      score: serializer.fromJson<double>(json['score']),
      maturity: serializer.fromJson<int>(json['maturity']),
      quickWhy: serializer.fromJson<String?>(json['quickWhy']),
      feelingWhy: serializer.fromJson<String?>(json['feelingWhy']),
      identityWhy: serializer.fromJson<String?>(json['identityWhy']),
      outcomeWhy: serializer.fromJson<String?>(json['outcomeWhy']),
      countTarget: serializer.fromJson<int?>(json['countTarget']),
      weeklyTarget: serializer.fromJson<int?>(json['weeklyTarget']),
      afterHabitId: serializer.fromJson<String?>(json['afterHabitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      lastDecayAt: serializer.fromJson<DateTime?>(json['lastDecayAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'location': serializer.toJson<String?>(location),
      'scheduledTime': serializer.toJson<String>(scheduledTime),
      'score': serializer.toJson<double>(score),
      'maturity': serializer.toJson<int>(maturity),
      'quickWhy': serializer.toJson<String?>(quickWhy),
      'feelingWhy': serializer.toJson<String?>(feelingWhy),
      'identityWhy': serializer.toJson<String?>(identityWhy),
      'outcomeWhy': serializer.toJson<String?>(outcomeWhy),
      'countTarget': serializer.toJson<int?>(countTarget),
      'weeklyTarget': serializer.toJson<int?>(weeklyTarget),
      'afterHabitId': serializer.toJson<String?>(afterHabitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'lastDecayAt': serializer.toJson<DateTime?>(lastDecayAt),
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    String? type,
    Value<String?> location = const Value.absent(),
    String? scheduledTime,
    double? score,
    int? maturity,
    Value<String?> quickWhy = const Value.absent(),
    Value<String?> feelingWhy = const Value.absent(),
    Value<String?> identityWhy = const Value.absent(),
    Value<String?> outcomeWhy = const Value.absent(),
    Value<int?> countTarget = const Value.absent(),
    Value<int?> weeklyTarget = const Value.absent(),
    Value<String?> afterHabitId = const Value.absent(),
    DateTime? createdAt,
    bool? isArchived,
    Value<DateTime?> lastDecayAt = const Value.absent(),
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    location: location.present ? location.value : this.location,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    score: score ?? this.score,
    maturity: maturity ?? this.maturity,
    quickWhy: quickWhy.present ? quickWhy.value : this.quickWhy,
    feelingWhy: feelingWhy.present ? feelingWhy.value : this.feelingWhy,
    identityWhy: identityWhy.present ? identityWhy.value : this.identityWhy,
    outcomeWhy: outcomeWhy.present ? outcomeWhy.value : this.outcomeWhy,
    countTarget: countTarget.present ? countTarget.value : this.countTarget,
    weeklyTarget: weeklyTarget.present ? weeklyTarget.value : this.weeklyTarget,
    afterHabitId: afterHabitId.present ? afterHabitId.value : this.afterHabitId,
    createdAt: createdAt ?? this.createdAt,
    isArchived: isArchived ?? this.isArchived,
    lastDecayAt: lastDecayAt.present ? lastDecayAt.value : this.lastDecayAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      location: data.location.present ? data.location.value : this.location,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      score: data.score.present ? data.score.value : this.score,
      maturity: data.maturity.present ? data.maturity.value : this.maturity,
      quickWhy: data.quickWhy.present ? data.quickWhy.value : this.quickWhy,
      feelingWhy: data.feelingWhy.present
          ? data.feelingWhy.value
          : this.feelingWhy,
      identityWhy: data.identityWhy.present
          ? data.identityWhy.value
          : this.identityWhy,
      outcomeWhy: data.outcomeWhy.present
          ? data.outcomeWhy.value
          : this.outcomeWhy,
      countTarget: data.countTarget.present
          ? data.countTarget.value
          : this.countTarget,
      weeklyTarget: data.weeklyTarget.present
          ? data.weeklyTarget.value
          : this.weeklyTarget,
      afterHabitId: data.afterHabitId.present
          ? data.afterHabitId.value
          : this.afterHabitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      lastDecayAt: data.lastDecayAt.present
          ? data.lastDecayAt.value
          : this.lastDecayAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('location: $location, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('score: $score, ')
          ..write('maturity: $maturity, ')
          ..write('quickWhy: $quickWhy, ')
          ..write('feelingWhy: $feelingWhy, ')
          ..write('identityWhy: $identityWhy, ')
          ..write('outcomeWhy: $outcomeWhy, ')
          ..write('countTarget: $countTarget, ')
          ..write('weeklyTarget: $weeklyTarget, ')
          ..write('afterHabitId: $afterHabitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('lastDecayAt: $lastDecayAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    location,
    scheduledTime,
    score,
    maturity,
    quickWhy,
    feelingWhy,
    identityWhy,
    outcomeWhy,
    countTarget,
    weeklyTarget,
    afterHabitId,
    createdAt,
    isArchived,
    lastDecayAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.location == this.location &&
          other.scheduledTime == this.scheduledTime &&
          other.score == this.score &&
          other.maturity == this.maturity &&
          other.quickWhy == this.quickWhy &&
          other.feelingWhy == this.feelingWhy &&
          other.identityWhy == this.identityWhy &&
          other.outcomeWhy == this.outcomeWhy &&
          other.countTarget == this.countTarget &&
          other.weeklyTarget == this.weeklyTarget &&
          other.afterHabitId == this.afterHabitId &&
          other.createdAt == this.createdAt &&
          other.isArchived == this.isArchived &&
          other.lastDecayAt == this.lastDecayAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> location;
  final Value<String> scheduledTime;
  final Value<double> score;
  final Value<int> maturity;
  final Value<String?> quickWhy;
  final Value<String?> feelingWhy;
  final Value<String?> identityWhy;
  final Value<String?> outcomeWhy;
  final Value<int?> countTarget;
  final Value<int?> weeklyTarget;
  final Value<String?> afterHabitId;
  final Value<DateTime> createdAt;
  final Value<bool> isArchived;
  final Value<DateTime?> lastDecayAt;
  final Value<int> rowid;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.location = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.score = const Value.absent(),
    this.maturity = const Value.absent(),
    this.quickWhy = const Value.absent(),
    this.feelingWhy = const Value.absent(),
    this.identityWhy = const Value.absent(),
    this.outcomeWhy = const Value.absent(),
    this.countTarget = const Value.absent(),
    this.weeklyTarget = const Value.absent(),
    this.afterHabitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.lastDecayAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitsCompanion.insert({
    required String id,
    required String name,
    this.type = const Value.absent(),
    this.location = const Value.absent(),
    required String scheduledTime,
    this.score = const Value.absent(),
    this.maturity = const Value.absent(),
    this.quickWhy = const Value.absent(),
    this.feelingWhy = const Value.absent(),
    this.identityWhy = const Value.absent(),
    this.outcomeWhy = const Value.absent(),
    this.countTarget = const Value.absent(),
    this.weeklyTarget = const Value.absent(),
    this.afterHabitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.lastDecayAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       scheduledTime = Value(scheduledTime);
  static Insertable<Habit> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? location,
    Expression<String>? scheduledTime,
    Expression<double>? score,
    Expression<int>? maturity,
    Expression<String>? quickWhy,
    Expression<String>? feelingWhy,
    Expression<String>? identityWhy,
    Expression<String>? outcomeWhy,
    Expression<int>? countTarget,
    Expression<int>? weeklyTarget,
    Expression<String>? afterHabitId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isArchived,
    Expression<DateTime>? lastDecayAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (location != null) 'location': location,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (score != null) 'score': score,
      if (maturity != null) 'maturity': maturity,
      if (quickWhy != null) 'quick_why': quickWhy,
      if (feelingWhy != null) 'feeling_why': feelingWhy,
      if (identityWhy != null) 'identity_why': identityWhy,
      if (outcomeWhy != null) 'outcome_why': outcomeWhy,
      if (countTarget != null) 'count_target': countTarget,
      if (weeklyTarget != null) 'weekly_target': weeklyTarget,
      if (afterHabitId != null) 'after_habit_id': afterHabitId,
      if (createdAt != null) 'created_at': createdAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (lastDecayAt != null) 'last_decay_at': lastDecayAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? location,
    Value<String>? scheduledTime,
    Value<double>? score,
    Value<int>? maturity,
    Value<String?>? quickWhy,
    Value<String?>? feelingWhy,
    Value<String?>? identityWhy,
    Value<String?>? outcomeWhy,
    Value<int?>? countTarget,
    Value<int?>? weeklyTarget,
    Value<String?>? afterHabitId,
    Value<DateTime>? createdAt,
    Value<bool>? isArchived,
    Value<DateTime?>? lastDecayAt,
    Value<int>? rowid,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      score: score ?? this.score,
      maturity: maturity ?? this.maturity,
      quickWhy: quickWhy ?? this.quickWhy,
      feelingWhy: feelingWhy ?? this.feelingWhy,
      identityWhy: identityWhy ?? this.identityWhy,
      outcomeWhy: outcomeWhy ?? this.outcomeWhy,
      countTarget: countTarget ?? this.countTarget,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      afterHabitId: afterHabitId ?? this.afterHabitId,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      lastDecayAt: lastDecayAt ?? this.lastDecayAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<String>(scheduledTime.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (maturity.present) {
      map['maturity'] = Variable<int>(maturity.value);
    }
    if (quickWhy.present) {
      map['quick_why'] = Variable<String>(quickWhy.value);
    }
    if (feelingWhy.present) {
      map['feeling_why'] = Variable<String>(feelingWhy.value);
    }
    if (identityWhy.present) {
      map['identity_why'] = Variable<String>(identityWhy.value);
    }
    if (outcomeWhy.present) {
      map['outcome_why'] = Variable<String>(outcomeWhy.value);
    }
    if (countTarget.present) {
      map['count_target'] = Variable<int>(countTarget.value);
    }
    if (weeklyTarget.present) {
      map['weekly_target'] = Variable<int>(weeklyTarget.value);
    }
    if (afterHabitId.present) {
      map['after_habit_id'] = Variable<String>(afterHabitId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (lastDecayAt.present) {
      map['last_decay_at'] = Variable<DateTime>(lastDecayAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('location: $location, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('score: $score, ')
          ..write('maturity: $maturity, ')
          ..write('quickWhy: $quickWhy, ')
          ..write('feelingWhy: $feelingWhy, ')
          ..write('identityWhy: $identityWhy, ')
          ..write('outcomeWhy: $outcomeWhy, ')
          ..write('countTarget: $countTarget, ')
          ..write('weeklyTarget: $weeklyTarget, ')
          ..write('afterHabitId: $afterHabitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('lastDecayAt: $lastDecayAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HabitCompletionsTable extends HabitCompletions
    with TableInfo<$HabitCompletionsTable, HabitCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<String> habitId = GeneratedColumn<String>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveDateMeta = const VerificationMeta(
    'effectiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveDate =
      GeneratedColumn<DateTime>(
        'effective_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _scoreAtCompletionMeta = const VerificationMeta(
    'scoreAtCompletion',
  );
  @override
  late final GeneratedColumn<double> scoreAtCompletion =
      GeneratedColumn<double>(
        'score_at_completion',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _countAchievedMeta = const VerificationMeta(
    'countAchieved',
  );
  @override
  late final GeneratedColumn<int> countAchieved = GeneratedColumn<int>(
    'count_achieved',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditPercentageMeta = const VerificationMeta(
    'creditPercentage',
  );
  @override
  late final GeneratedColumn<double> creditPercentage = GeneratedColumn<double>(
    'credit_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    completedAt,
    effectiveDate,
    source,
    scoreAtCompletion,
    countAchieved,
    creditPercentage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('effective_date')) {
      context.handle(
        _effectiveDateMeta,
        effectiveDate.isAcceptableOrUnknown(
          data['effective_date']!,
          _effectiveDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('score_at_completion')) {
      context.handle(
        _scoreAtCompletionMeta,
        scoreAtCompletion.isAcceptableOrUnknown(
          data['score_at_completion']!,
          _scoreAtCompletionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scoreAtCompletionMeta);
    }
    if (data.containsKey('count_achieved')) {
      context.handle(
        _countAchievedMeta,
        countAchieved.isAcceptableOrUnknown(
          data['count_achieved']!,
          _countAchievedMeta,
        ),
      );
    }
    if (data.containsKey('credit_percentage')) {
      context.handle(
        _creditPercentageMeta,
        creditPercentage.isAcceptableOrUnknown(
          data['credit_percentage']!,
          _creditPercentageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habit_id'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      effectiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_date'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      scoreAtCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score_at_completion'],
      )!,
      countAchieved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count_achieved'],
      ),
      creditPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_percentage'],
      )!,
    );
  }

  @override
  $HabitCompletionsTable createAlias(String alias) {
    return $HabitCompletionsTable(attachedDatabase, alias);
  }
}

class HabitCompletion extends DataClass implements Insertable<HabitCompletion> {
  /// Unique identifier (UUID)
  final String id;

  /// Reference to the habit
  final String habitId;

  /// When the completion was recorded
  final DateTime completedAt;

  /// The "logical" date this completion counts for (handles 4am boundary)
  final DateTime effectiveDate;

  /// How the completion was recorded
  final String source;

  /// Score at the time of completion (for history)
  final double scoreAtCompletion;

  /// Count achieved (for count-type habits, Phase 2)
  final int? countAchieved;

  /// Credit percentage (100% same day, 75% yesterday, etc.)
  final double creditPercentage;
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedAt,
    required this.effectiveDate,
    required this.source,
    required this.scoreAtCompletion,
    this.countAchieved,
    required this.creditPercentage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['habit_id'] = Variable<String>(habitId);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['effective_date'] = Variable<DateTime>(effectiveDate);
    map['source'] = Variable<String>(source);
    map['score_at_completion'] = Variable<double>(scoreAtCompletion);
    if (!nullToAbsent || countAchieved != null) {
      map['count_achieved'] = Variable<int>(countAchieved);
    }
    map['credit_percentage'] = Variable<double>(creditPercentage);
    return map;
  }

  HabitCompletionsCompanion toCompanion(bool nullToAbsent) {
    return HabitCompletionsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      completedAt: Value(completedAt),
      effectiveDate: Value(effectiveDate),
      source: Value(source),
      scoreAtCompletion: Value(scoreAtCompletion),
      countAchieved: countAchieved == null && nullToAbsent
          ? const Value.absent()
          : Value(countAchieved),
      creditPercentage: Value(creditPercentage),
    );
  }

  factory HabitCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitCompletion(
      id: serializer.fromJson<String>(json['id']),
      habitId: serializer.fromJson<String>(json['habitId']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      effectiveDate: serializer.fromJson<DateTime>(json['effectiveDate']),
      source: serializer.fromJson<String>(json['source']),
      scoreAtCompletion: serializer.fromJson<double>(json['scoreAtCompletion']),
      countAchieved: serializer.fromJson<int?>(json['countAchieved']),
      creditPercentage: serializer.fromJson<double>(json['creditPercentage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'habitId': serializer.toJson<String>(habitId),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'effectiveDate': serializer.toJson<DateTime>(effectiveDate),
      'source': serializer.toJson<String>(source),
      'scoreAtCompletion': serializer.toJson<double>(scoreAtCompletion),
      'countAchieved': serializer.toJson<int?>(countAchieved),
      'creditPercentage': serializer.toJson<double>(creditPercentage),
    };
  }

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? completedAt,
    DateTime? effectiveDate,
    String? source,
    double? scoreAtCompletion,
    Value<int?> countAchieved = const Value.absent(),
    double? creditPercentage,
  }) => HabitCompletion(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    completedAt: completedAt ?? this.completedAt,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    source: source ?? this.source,
    scoreAtCompletion: scoreAtCompletion ?? this.scoreAtCompletion,
    countAchieved: countAchieved.present
        ? countAchieved.value
        : this.countAchieved,
    creditPercentage: creditPercentage ?? this.creditPercentage,
  );
  HabitCompletion copyWithCompanion(HabitCompletionsCompanion data) {
    return HabitCompletion(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      source: data.source.present ? data.source.value : this.source,
      scoreAtCompletion: data.scoreAtCompletion.present
          ? data.scoreAtCompletion.value
          : this.scoreAtCompletion,
      countAchieved: data.countAchieved.present
          ? data.countAchieved.value
          : this.countAchieved,
      creditPercentage: data.creditPercentage.present
          ? data.creditPercentage.value
          : this.creditPercentage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('completedAt: $completedAt, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('source: $source, ')
          ..write('scoreAtCompletion: $scoreAtCompletion, ')
          ..write('countAchieved: $countAchieved, ')
          ..write('creditPercentage: $creditPercentage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitId,
    completedAt,
    effectiveDate,
    source,
    scoreAtCompletion,
    countAchieved,
    creditPercentage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitCompletion &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.completedAt == this.completedAt &&
          other.effectiveDate == this.effectiveDate &&
          other.source == this.source &&
          other.scoreAtCompletion == this.scoreAtCompletion &&
          other.countAchieved == this.countAchieved &&
          other.creditPercentage == this.creditPercentage);
}

class HabitCompletionsCompanion extends UpdateCompanion<HabitCompletion> {
  final Value<String> id;
  final Value<String> habitId;
  final Value<DateTime> completedAt;
  final Value<DateTime> effectiveDate;
  final Value<String> source;
  final Value<double> scoreAtCompletion;
  final Value<int?> countAchieved;
  final Value<double> creditPercentage;
  final Value<int> rowid;
  const HabitCompletionsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.source = const Value.absent(),
    this.scoreAtCompletion = const Value.absent(),
    this.countAchieved = const Value.absent(),
    this.creditPercentage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HabitCompletionsCompanion.insert({
    required String id,
    required String habitId,
    required DateTime completedAt,
    required DateTime effectiveDate,
    this.source = const Value.absent(),
    required double scoreAtCompletion,
    this.countAchieved = const Value.absent(),
    this.creditPercentage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       habitId = Value(habitId),
       completedAt = Value(completedAt),
       effectiveDate = Value(effectiveDate),
       scoreAtCompletion = Value(scoreAtCompletion);
  static Insertable<HabitCompletion> custom({
    Expression<String>? id,
    Expression<String>? habitId,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? effectiveDate,
    Expression<String>? source,
    Expression<double>? scoreAtCompletion,
    Expression<int>? countAchieved,
    Expression<double>? creditPercentage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (completedAt != null) 'completed_at': completedAt,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (source != null) 'source': source,
      if (scoreAtCompletion != null) 'score_at_completion': scoreAtCompletion,
      if (countAchieved != null) 'count_achieved': countAchieved,
      if (creditPercentage != null) 'credit_percentage': creditPercentage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HabitCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? habitId,
    Value<DateTime>? completedAt,
    Value<DateTime>? effectiveDate,
    Value<String>? source,
    Value<double>? scoreAtCompletion,
    Value<int?>? countAchieved,
    Value<double>? creditPercentage,
    Value<int>? rowid,
  }) {
    return HabitCompletionsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      source: source ?? this.source,
      scoreAtCompletion: scoreAtCompletion ?? this.scoreAtCompletion,
      countAchieved: countAchieved ?? this.countAchieved,
      creditPercentage: creditPercentage ?? this.creditPercentage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<String>(habitId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<DateTime>(effectiveDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (scoreAtCompletion.present) {
      map['score_at_completion'] = Variable<double>(scoreAtCompletion.value);
    }
    if (countAchieved.present) {
      map['count_achieved'] = Variable<int>(countAchieved.value);
    }
    if (creditPercentage.present) {
      map['credit_percentage'] = Variable<double>(creditPercentage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('completedAt: $completedAt, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('source: $source, ')
          ..write('scoreAtCompletion: $scoreAtCompletion, ')
          ..write('countAchieved: $countAchieved, ')
          ..write('creditPercentage: $creditPercentage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPreferencesTable extends UserPreferences
    with TableInfo<$UserPreferencesTable, UserPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _quietHoursStartMeta = const VerificationMeta(
    'quietHoursStart',
  );
  @override
  late final GeneratedColumn<String> quietHoursStart = GeneratedColumn<String>(
    'quiet_hours_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('22:00'),
  );
  static const VerificationMeta _quietHoursEndMeta = const VerificationMeta(
    'quietHoursEnd',
  );
  @override
  late final GeneratedColumn<String> quietHoursEnd = GeneratedColumn<String>(
    'quiet_hours_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('07:00'),
  );
  static const VerificationMeta _dayBoundaryHourMeta = const VerificationMeta(
    'dayBoundaryHour',
  );
  @override
  late final GeneratedColumn<int> dayBoundaryHour = GeneratedColumn<int>(
    'day_boundary_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
    'onboarding_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _preReminderMinutesMeta =
      const VerificationMeta('preReminderMinutes');
  @override
  late final GeneratedColumn<int> preReminderMinutes = GeneratedColumn<int>(
    'pre_reminder_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _postReminderMinutesMeta =
      const VerificationMeta('postReminderMinutes');
  @override
  late final GeneratedColumn<int> postReminderMinutes = GeneratedColumn<int>(
    'post_reminder_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _breakModeUntilMeta = const VerificationMeta(
    'breakModeUntil',
  );
  @override
  late final GeneratedColumn<DateTime> breakModeUntil =
      GeneratedColumn<DateTime>(
        'break_mode_until',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _weeklySummaryDayMeta = const VerificationMeta(
    'weeklySummaryDay',
  );
  @override
  late final GeneratedColumn<int> weeklySummaryDay = GeneratedColumn<int>(
    'weekly_summary_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(6),
  );
  static const VerificationMeta _weeklySummaryTimeMeta = const VerificationMeta(
    'weeklySummaryTime',
  );
  @override
  late final GeneratedColumn<String> weeklySummaryTime =
      GeneratedColumn<String>(
        'weekly_summary_time',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('18:00'),
      );
  static const VerificationMeta _lastWeeklySummaryAtMeta =
      const VerificationMeta('lastWeeklySummaryAt');
  @override
  late final GeneratedColumn<DateTime> lastWeeklySummaryAt =
      GeneratedColumn<DateTime>(
        'last_weekly_summary_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quietHoursStart,
    quietHoursEnd,
    dayBoundaryHour,
    onboardingCompleted,
    themeMode,
    notificationsEnabled,
    preReminderMinutes,
    postReminderMinutes,
    breakModeUntil,
    weeklySummaryDay,
    weeklySummaryTime,
    lastWeeklySummaryAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quiet_hours_start')) {
      context.handle(
        _quietHoursStartMeta,
        quietHoursStart.isAcceptableOrUnknown(
          data['quiet_hours_start']!,
          _quietHoursStartMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_end')) {
      context.handle(
        _quietHoursEndMeta,
        quietHoursEnd.isAcceptableOrUnknown(
          data['quiet_hours_end']!,
          _quietHoursEndMeta,
        ),
      );
    }
    if (data.containsKey('day_boundary_hour')) {
      context.handle(
        _dayBoundaryHourMeta,
        dayBoundaryHour.isAcceptableOrUnknown(
          data['day_boundary_hour']!,
          _dayBoundaryHourMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
        _onboardingCompletedMeta,
        onboardingCompleted.isAcceptableOrUnknown(
          data['onboarding_completed']!,
          _onboardingCompletedMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('pre_reminder_minutes')) {
      context.handle(
        _preReminderMinutesMeta,
        preReminderMinutes.isAcceptableOrUnknown(
          data['pre_reminder_minutes']!,
          _preReminderMinutesMeta,
        ),
      );
    }
    if (data.containsKey('post_reminder_minutes')) {
      context.handle(
        _postReminderMinutesMeta,
        postReminderMinutes.isAcceptableOrUnknown(
          data['post_reminder_minutes']!,
          _postReminderMinutesMeta,
        ),
      );
    }
    if (data.containsKey('break_mode_until')) {
      context.handle(
        _breakModeUntilMeta,
        breakModeUntil.isAcceptableOrUnknown(
          data['break_mode_until']!,
          _breakModeUntilMeta,
        ),
      );
    }
    if (data.containsKey('weekly_summary_day')) {
      context.handle(
        _weeklySummaryDayMeta,
        weeklySummaryDay.isAcceptableOrUnknown(
          data['weekly_summary_day']!,
          _weeklySummaryDayMeta,
        ),
      );
    }
    if (data.containsKey('weekly_summary_time')) {
      context.handle(
        _weeklySummaryTimeMeta,
        weeklySummaryTime.isAcceptableOrUnknown(
          data['weekly_summary_time']!,
          _weeklySummaryTimeMeta,
        ),
      );
    }
    if (data.containsKey('last_weekly_summary_at')) {
      context.handle(
        _lastWeeklySummaryAtMeta,
        lastWeeklySummaryAt.isAcceptableOrUnknown(
          data['last_weekly_summary_at']!,
          _lastWeeklySummaryAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      quietHoursStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiet_hours_start'],
      )!,
      quietHoursEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiet_hours_end'],
      )!,
      dayBoundaryHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_boundary_hour'],
      )!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_completed'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      preReminderMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pre_reminder_minutes'],
      )!,
      postReminderMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}post_reminder_minutes'],
      )!,
      breakModeUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}break_mode_until'],
      ),
      weeklySummaryDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_summary_day'],
      )!,
      weeklySummaryTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekly_summary_time'],
      )!,
      lastWeeklySummaryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_weekly_summary_at'],
      ),
    );
  }

  @override
  $UserPreferencesTable createAlias(String alias) {
    return $UserPreferencesTable(attachedDatabase, alias);
  }
}

class UserPreference extends DataClass implements Insertable<UserPreference> {
  /// Always 1 (singleton)
  final int id;

  /// Quiet hours start (stored as "HH:mm", default "22:00")
  final String quietHoursStart;

  /// Quiet hours end (stored as "HH:mm", default "07:00")
  final String quietHoursEnd;

  /// Day boundary hour (0-23, default 4 for 4am)
  final int dayBoundaryHour;

  /// Whether onboarding has been completed
  final bool onboardingCompleted;

  /// Theme mode: system, light, dark
  final String themeMode;

  /// Whether notifications are enabled
  final bool notificationsEnabled;

  /// Pre-reminder offset in minutes (default 30)
  final int preReminderMinutes;

  /// Post-reminder offset in minutes (default 30)
  final int postReminderMinutes;

  /// Break mode end date (null if not in break mode)
  final DateTime? breakModeUntil;

  /// Weekly summary day (0=Monday, 6=Sunday, default 6)
  final int weeklySummaryDay;

  /// Weekly summary time (stored as "HH:mm", default "18:00")
  final String weeklySummaryTime;

  /// Last weekly summary shown
  final DateTime? lastWeeklySummaryAt;
  const UserPreference({
    required this.id,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.dayBoundaryHour,
    required this.onboardingCompleted,
    required this.themeMode,
    required this.notificationsEnabled,
    required this.preReminderMinutes,
    required this.postReminderMinutes,
    this.breakModeUntil,
    required this.weeklySummaryDay,
    required this.weeklySummaryTime,
    this.lastWeeklySummaryAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quiet_hours_start'] = Variable<String>(quietHoursStart);
    map['quiet_hours_end'] = Variable<String>(quietHoursEnd);
    map['day_boundary_hour'] = Variable<int>(dayBoundaryHour);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    map['theme_mode'] = Variable<String>(themeMode);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['pre_reminder_minutes'] = Variable<int>(preReminderMinutes);
    map['post_reminder_minutes'] = Variable<int>(postReminderMinutes);
    if (!nullToAbsent || breakModeUntil != null) {
      map['break_mode_until'] = Variable<DateTime>(breakModeUntil);
    }
    map['weekly_summary_day'] = Variable<int>(weeklySummaryDay);
    map['weekly_summary_time'] = Variable<String>(weeklySummaryTime);
    if (!nullToAbsent || lastWeeklySummaryAt != null) {
      map['last_weekly_summary_at'] = Variable<DateTime>(lastWeeklySummaryAt);
    }
    return map;
  }

  UserPreferencesCompanion toCompanion(bool nullToAbsent) {
    return UserPreferencesCompanion(
      id: Value(id),
      quietHoursStart: Value(quietHoursStart),
      quietHoursEnd: Value(quietHoursEnd),
      dayBoundaryHour: Value(dayBoundaryHour),
      onboardingCompleted: Value(onboardingCompleted),
      themeMode: Value(themeMode),
      notificationsEnabled: Value(notificationsEnabled),
      preReminderMinutes: Value(preReminderMinutes),
      postReminderMinutes: Value(postReminderMinutes),
      breakModeUntil: breakModeUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(breakModeUntil),
      weeklySummaryDay: Value(weeklySummaryDay),
      weeklySummaryTime: Value(weeklySummaryTime),
      lastWeeklySummaryAt: lastWeeklySummaryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWeeklySummaryAt),
    );
  }

  factory UserPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPreference(
      id: serializer.fromJson<int>(json['id']),
      quietHoursStart: serializer.fromJson<String>(json['quietHoursStart']),
      quietHoursEnd: serializer.fromJson<String>(json['quietHoursEnd']),
      dayBoundaryHour: serializer.fromJson<int>(json['dayBoundaryHour']),
      onboardingCompleted: serializer.fromJson<bool>(
        json['onboardingCompleted'],
      ),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      preReminderMinutes: serializer.fromJson<int>(json['preReminderMinutes']),
      postReminderMinutes: serializer.fromJson<int>(
        json['postReminderMinutes'],
      ),
      breakModeUntil: serializer.fromJson<DateTime?>(json['breakModeUntil']),
      weeklySummaryDay: serializer.fromJson<int>(json['weeklySummaryDay']),
      weeklySummaryTime: serializer.fromJson<String>(json['weeklySummaryTime']),
      lastWeeklySummaryAt: serializer.fromJson<DateTime?>(
        json['lastWeeklySummaryAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'quietHoursStart': serializer.toJson<String>(quietHoursStart),
      'quietHoursEnd': serializer.toJson<String>(quietHoursEnd),
      'dayBoundaryHour': serializer.toJson<int>(dayBoundaryHour),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'themeMode': serializer.toJson<String>(themeMode),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'preReminderMinutes': serializer.toJson<int>(preReminderMinutes),
      'postReminderMinutes': serializer.toJson<int>(postReminderMinutes),
      'breakModeUntil': serializer.toJson<DateTime?>(breakModeUntil),
      'weeklySummaryDay': serializer.toJson<int>(weeklySummaryDay),
      'weeklySummaryTime': serializer.toJson<String>(weeklySummaryTime),
      'lastWeeklySummaryAt': serializer.toJson<DateTime?>(lastWeeklySummaryAt),
    };
  }

  UserPreference copyWith({
    int? id,
    String? quietHoursStart,
    String? quietHoursEnd,
    int? dayBoundaryHour,
    bool? onboardingCompleted,
    String? themeMode,
    bool? notificationsEnabled,
    int? preReminderMinutes,
    int? postReminderMinutes,
    Value<DateTime?> breakModeUntil = const Value.absent(),
    int? weeklySummaryDay,
    String? weeklySummaryTime,
    Value<DateTime?> lastWeeklySummaryAt = const Value.absent(),
  }) => UserPreference(
    id: id ?? this.id,
    quietHoursStart: quietHoursStart ?? this.quietHoursStart,
    quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    dayBoundaryHour: dayBoundaryHour ?? this.dayBoundaryHour,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    themeMode: themeMode ?? this.themeMode,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    preReminderMinutes: preReminderMinutes ?? this.preReminderMinutes,
    postReminderMinutes: postReminderMinutes ?? this.postReminderMinutes,
    breakModeUntil: breakModeUntil.present
        ? breakModeUntil.value
        : this.breakModeUntil,
    weeklySummaryDay: weeklySummaryDay ?? this.weeklySummaryDay,
    weeklySummaryTime: weeklySummaryTime ?? this.weeklySummaryTime,
    lastWeeklySummaryAt: lastWeeklySummaryAt.present
        ? lastWeeklySummaryAt.value
        : this.lastWeeklySummaryAt,
  );
  UserPreference copyWithCompanion(UserPreferencesCompanion data) {
    return UserPreference(
      id: data.id.present ? data.id.value : this.id,
      quietHoursStart: data.quietHoursStart.present
          ? data.quietHoursStart.value
          : this.quietHoursStart,
      quietHoursEnd: data.quietHoursEnd.present
          ? data.quietHoursEnd.value
          : this.quietHoursEnd,
      dayBoundaryHour: data.dayBoundaryHour.present
          ? data.dayBoundaryHour.value
          : this.dayBoundaryHour,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      preReminderMinutes: data.preReminderMinutes.present
          ? data.preReminderMinutes.value
          : this.preReminderMinutes,
      postReminderMinutes: data.postReminderMinutes.present
          ? data.postReminderMinutes.value
          : this.postReminderMinutes,
      breakModeUntil: data.breakModeUntil.present
          ? data.breakModeUntil.value
          : this.breakModeUntil,
      weeklySummaryDay: data.weeklySummaryDay.present
          ? data.weeklySummaryDay.value
          : this.weeklySummaryDay,
      weeklySummaryTime: data.weeklySummaryTime.present
          ? data.weeklySummaryTime.value
          : this.weeklySummaryTime,
      lastWeeklySummaryAt: data.lastWeeklySummaryAt.present
          ? data.lastWeeklySummaryAt.value
          : this.lastWeeklySummaryAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPreference(')
          ..write('id: $id, ')
          ..write('quietHoursStart: $quietHoursStart, ')
          ..write('quietHoursEnd: $quietHoursEnd, ')
          ..write('dayBoundaryHour: $dayBoundaryHour, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('themeMode: $themeMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('preReminderMinutes: $preReminderMinutes, ')
          ..write('postReminderMinutes: $postReminderMinutes, ')
          ..write('breakModeUntil: $breakModeUntil, ')
          ..write('weeklySummaryDay: $weeklySummaryDay, ')
          ..write('weeklySummaryTime: $weeklySummaryTime, ')
          ..write('lastWeeklySummaryAt: $lastWeeklySummaryAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quietHoursStart,
    quietHoursEnd,
    dayBoundaryHour,
    onboardingCompleted,
    themeMode,
    notificationsEnabled,
    preReminderMinutes,
    postReminderMinutes,
    breakModeUntil,
    weeklySummaryDay,
    weeklySummaryTime,
    lastWeeklySummaryAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPreference &&
          other.id == this.id &&
          other.quietHoursStart == this.quietHoursStart &&
          other.quietHoursEnd == this.quietHoursEnd &&
          other.dayBoundaryHour == this.dayBoundaryHour &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.themeMode == this.themeMode &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.preReminderMinutes == this.preReminderMinutes &&
          other.postReminderMinutes == this.postReminderMinutes &&
          other.breakModeUntil == this.breakModeUntil &&
          other.weeklySummaryDay == this.weeklySummaryDay &&
          other.weeklySummaryTime == this.weeklySummaryTime &&
          other.lastWeeklySummaryAt == this.lastWeeklySummaryAt);
}

class UserPreferencesCompanion extends UpdateCompanion<UserPreference> {
  final Value<int> id;
  final Value<String> quietHoursStart;
  final Value<String> quietHoursEnd;
  final Value<int> dayBoundaryHour;
  final Value<bool> onboardingCompleted;
  final Value<String> themeMode;
  final Value<bool> notificationsEnabled;
  final Value<int> preReminderMinutes;
  final Value<int> postReminderMinutes;
  final Value<DateTime?> breakModeUntil;
  final Value<int> weeklySummaryDay;
  final Value<String> weeklySummaryTime;
  final Value<DateTime?> lastWeeklySummaryAt;
  const UserPreferencesCompanion({
    this.id = const Value.absent(),
    this.quietHoursStart = const Value.absent(),
    this.quietHoursEnd = const Value.absent(),
    this.dayBoundaryHour = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.preReminderMinutes = const Value.absent(),
    this.postReminderMinutes = const Value.absent(),
    this.breakModeUntil = const Value.absent(),
    this.weeklySummaryDay = const Value.absent(),
    this.weeklySummaryTime = const Value.absent(),
    this.lastWeeklySummaryAt = const Value.absent(),
  });
  UserPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.quietHoursStart = const Value.absent(),
    this.quietHoursEnd = const Value.absent(),
    this.dayBoundaryHour = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.preReminderMinutes = const Value.absent(),
    this.postReminderMinutes = const Value.absent(),
    this.breakModeUntil = const Value.absent(),
    this.weeklySummaryDay = const Value.absent(),
    this.weeklySummaryTime = const Value.absent(),
    this.lastWeeklySummaryAt = const Value.absent(),
  });
  static Insertable<UserPreference> custom({
    Expression<int>? id,
    Expression<String>? quietHoursStart,
    Expression<String>? quietHoursEnd,
    Expression<int>? dayBoundaryHour,
    Expression<bool>? onboardingCompleted,
    Expression<String>? themeMode,
    Expression<bool>? notificationsEnabled,
    Expression<int>? preReminderMinutes,
    Expression<int>? postReminderMinutes,
    Expression<DateTime>? breakModeUntil,
    Expression<int>? weeklySummaryDay,
    Expression<String>? weeklySummaryTime,
    Expression<DateTime>? lastWeeklySummaryAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quietHoursStart != null) 'quiet_hours_start': quietHoursStart,
      if (quietHoursEnd != null) 'quiet_hours_end': quietHoursEnd,
      if (dayBoundaryHour != null) 'day_boundary_hour': dayBoundaryHour,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (themeMode != null) 'theme_mode': themeMode,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (preReminderMinutes != null)
        'pre_reminder_minutes': preReminderMinutes,
      if (postReminderMinutes != null)
        'post_reminder_minutes': postReminderMinutes,
      if (breakModeUntil != null) 'break_mode_until': breakModeUntil,
      if (weeklySummaryDay != null) 'weekly_summary_day': weeklySummaryDay,
      if (weeklySummaryTime != null) 'weekly_summary_time': weeklySummaryTime,
      if (lastWeeklySummaryAt != null)
        'last_weekly_summary_at': lastWeeklySummaryAt,
    });
  }

  UserPreferencesCompanion copyWith({
    Value<int>? id,
    Value<String>? quietHoursStart,
    Value<String>? quietHoursEnd,
    Value<int>? dayBoundaryHour,
    Value<bool>? onboardingCompleted,
    Value<String>? themeMode,
    Value<bool>? notificationsEnabled,
    Value<int>? preReminderMinutes,
    Value<int>? postReminderMinutes,
    Value<DateTime?>? breakModeUntil,
    Value<int>? weeklySummaryDay,
    Value<String>? weeklySummaryTime,
    Value<DateTime?>? lastWeeklySummaryAt,
  }) {
    return UserPreferencesCompanion(
      id: id ?? this.id,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      dayBoundaryHour: dayBoundaryHour ?? this.dayBoundaryHour,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preReminderMinutes: preReminderMinutes ?? this.preReminderMinutes,
      postReminderMinutes: postReminderMinutes ?? this.postReminderMinutes,
      breakModeUntil: breakModeUntil ?? this.breakModeUntil,
      weeklySummaryDay: weeklySummaryDay ?? this.weeklySummaryDay,
      weeklySummaryTime: weeklySummaryTime ?? this.weeklySummaryTime,
      lastWeeklySummaryAt: lastWeeklySummaryAt ?? this.lastWeeklySummaryAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (quietHoursStart.present) {
      map['quiet_hours_start'] = Variable<String>(quietHoursStart.value);
    }
    if (quietHoursEnd.present) {
      map['quiet_hours_end'] = Variable<String>(quietHoursEnd.value);
    }
    if (dayBoundaryHour.present) {
      map['day_boundary_hour'] = Variable<int>(dayBoundaryHour.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (preReminderMinutes.present) {
      map['pre_reminder_minutes'] = Variable<int>(preReminderMinutes.value);
    }
    if (postReminderMinutes.present) {
      map['post_reminder_minutes'] = Variable<int>(postReminderMinutes.value);
    }
    if (breakModeUntil.present) {
      map['break_mode_until'] = Variable<DateTime>(breakModeUntil.value);
    }
    if (weeklySummaryDay.present) {
      map['weekly_summary_day'] = Variable<int>(weeklySummaryDay.value);
    }
    if (weeklySummaryTime.present) {
      map['weekly_summary_time'] = Variable<String>(weeklySummaryTime.value);
    }
    if (lastWeeklySummaryAt.present) {
      map['last_weekly_summary_at'] = Variable<DateTime>(
        lastWeeklySummaryAt.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('quietHoursStart: $quietHoursStart, ')
          ..write('quietHoursEnd: $quietHoursEnd, ')
          ..write('dayBoundaryHour: $dayBoundaryHour, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('themeMode: $themeMode, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('preReminderMinutes: $preReminderMinutes, ')
          ..write('postReminderMinutes: $postReminderMinutes, ')
          ..write('breakModeUntil: $breakModeUntil, ')
          ..write('weeklySummaryDay: $weeklySummaryDay, ')
          ..write('weeklySummaryTime: $weeklySummaryTime, ')
          ..write('lastWeeklySummaryAt: $lastWeeklySummaryAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitCompletionsTable habitCompletions = $HabitCompletionsTable(
    this,
  );
  late final $UserPreferencesTable userPreferences = $UserPreferencesTable(
    this,
  );
  late final HabitDao habitDao = HabitDao(this as AppDatabase);
  late final CompletionDao completionDao = CompletionDao(this as AppDatabase);
  late final PreferencesDao preferencesDao = PreferencesDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    habits,
    habitCompletions,
    userPreferences,
  ];
}

typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      required String id,
      required String name,
      Value<String> type,
      Value<String?> location,
      required String scheduledTime,
      Value<double> score,
      Value<int> maturity,
      Value<String?> quickWhy,
      Value<String?> feelingWhy,
      Value<String?> identityWhy,
      Value<String?> outcomeWhy,
      Value<int?> countTarget,
      Value<int?> weeklyTarget,
      Value<String?> afterHabitId,
      Value<DateTime> createdAt,
      Value<bool> isArchived,
      Value<DateTime?> lastDecayAt,
      Value<int> rowid,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String?> location,
      Value<String> scheduledTime,
      Value<double> score,
      Value<int> maturity,
      Value<String?> quickWhy,
      Value<String?> feelingWhy,
      Value<String?> identityWhy,
      Value<String?> outcomeWhy,
      Value<int?> countTarget,
      Value<int?> weeklyTarget,
      Value<String?> afterHabitId,
      Value<DateTime> createdAt,
      Value<bool> isArchived,
      Value<DateTime?> lastDecayAt,
      Value<int> rowid,
    });

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maturity => $composableBuilder(
    column: $table.maturity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quickWhy => $composableBuilder(
    column: $table.quickWhy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feelingWhy => $composableBuilder(
    column: $table.feelingWhy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identityWhy => $composableBuilder(
    column: $table.identityWhy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcomeWhy => $composableBuilder(
    column: $table.outcomeWhy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countTarget => $composableBuilder(
    column: $table.countTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterHabitId => $composableBuilder(
    column: $table.afterHabitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDecayAt => $composableBuilder(
    column: $table.lastDecayAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maturity => $composableBuilder(
    column: $table.maturity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quickWhy => $composableBuilder(
    column: $table.quickWhy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feelingWhy => $composableBuilder(
    column: $table.feelingWhy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identityWhy => $composableBuilder(
    column: $table.identityWhy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcomeWhy => $composableBuilder(
    column: $table.outcomeWhy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countTarget => $composableBuilder(
    column: $table.countTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterHabitId => $composableBuilder(
    column: $table.afterHabitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDecayAt => $composableBuilder(
    column: $table.lastDecayAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get maturity =>
      $composableBuilder(column: $table.maturity, builder: (column) => column);

  GeneratedColumn<String> get quickWhy =>
      $composableBuilder(column: $table.quickWhy, builder: (column) => column);

  GeneratedColumn<String> get feelingWhy => $composableBuilder(
    column: $table.feelingWhy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get identityWhy => $composableBuilder(
    column: $table.identityWhy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcomeWhy => $composableBuilder(
    column: $table.outcomeWhy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countTarget => $composableBuilder(
    column: $table.countTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyTarget => $composableBuilder(
    column: $table.weeklyTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterHabitId => $composableBuilder(
    column: $table.afterHabitId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastDecayAt => $composableBuilder(
    column: $table.lastDecayAt,
    builder: (column) => column,
  );
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> scheduledTime = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<int> maturity = const Value.absent(),
                Value<String?> quickWhy = const Value.absent(),
                Value<String?> feelingWhy = const Value.absent(),
                Value<String?> identityWhy = const Value.absent(),
                Value<String?> outcomeWhy = const Value.absent(),
                Value<int?> countTarget = const Value.absent(),
                Value<int?> weeklyTarget = const Value.absent(),
                Value<String?> afterHabitId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime?> lastDecayAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                type: type,
                location: location,
                scheduledTime: scheduledTime,
                score: score,
                maturity: maturity,
                quickWhy: quickWhy,
                feelingWhy: feelingWhy,
                identityWhy: identityWhy,
                outcomeWhy: outcomeWhy,
                countTarget: countTarget,
                weeklyTarget: weeklyTarget,
                afterHabitId: afterHabitId,
                createdAt: createdAt,
                isArchived: isArchived,
                lastDecayAt: lastDecayAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> type = const Value.absent(),
                Value<String?> location = const Value.absent(),
                required String scheduledTime,
                Value<double> score = const Value.absent(),
                Value<int> maturity = const Value.absent(),
                Value<String?> quickWhy = const Value.absent(),
                Value<String?> feelingWhy = const Value.absent(),
                Value<String?> identityWhy = const Value.absent(),
                Value<String?> outcomeWhy = const Value.absent(),
                Value<int?> countTarget = const Value.absent(),
                Value<int?> weeklyTarget = const Value.absent(),
                Value<String?> afterHabitId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime?> lastDecayAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                type: type,
                location: location,
                scheduledTime: scheduledTime,
                score: score,
                maturity: maturity,
                quickWhy: quickWhy,
                feelingWhy: feelingWhy,
                identityWhy: identityWhy,
                outcomeWhy: outcomeWhy,
                countTarget: countTarget,
                weeklyTarget: weeklyTarget,
                afterHabitId: afterHabitId,
                createdAt: createdAt,
                isArchived: isArchived,
                lastDecayAt: lastDecayAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$HabitCompletionsTableCreateCompanionBuilder =
    HabitCompletionsCompanion Function({
      required String id,
      required String habitId,
      required DateTime completedAt,
      required DateTime effectiveDate,
      Value<String> source,
      required double scoreAtCompletion,
      Value<int?> countAchieved,
      Value<double> creditPercentage,
      Value<int> rowid,
    });
typedef $$HabitCompletionsTableUpdateCompanionBuilder =
    HabitCompletionsCompanion Function({
      Value<String> id,
      Value<String> habitId,
      Value<DateTime> completedAt,
      Value<DateTime> effectiveDate,
      Value<String> source,
      Value<double> scoreAtCompletion,
      Value<int?> countAchieved,
      Value<double> creditPercentage,
      Value<int> rowid,
    });

class $$HabitCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scoreAtCompletion => $composableBuilder(
    column: $table.scoreAtCompletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countAchieved => $composableBuilder(
    column: $table.countAchieved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditPercentage => $composableBuilder(
    column: $table.creditPercentage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scoreAtCompletion => $composableBuilder(
    column: $table.scoreAtCompletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countAchieved => $composableBuilder(
    column: $table.countAchieved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditPercentage => $composableBuilder(
    column: $table.creditPercentage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get scoreAtCompletion => $composableBuilder(
    column: $table.scoreAtCompletion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countAchieved => $composableBuilder(
    column: $table.countAchieved,
    builder: (column) => column,
  );

  GeneratedColumn<double> get creditPercentage => $composableBuilder(
    column: $table.creditPercentage,
    builder: (column) => column,
  );
}

class $$HabitCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitCompletionsTable,
          HabitCompletion,
          $$HabitCompletionsTableFilterComposer,
          $$HabitCompletionsTableOrderingComposer,
          $$HabitCompletionsTableAnnotationComposer,
          $$HabitCompletionsTableCreateCompanionBuilder,
          $$HabitCompletionsTableUpdateCompanionBuilder,
          (
            HabitCompletion,
            BaseReferences<
              _$AppDatabase,
              $HabitCompletionsTable,
              HabitCompletion
            >,
          ),
          HabitCompletion,
          PrefetchHooks Function()
        > {
  $$HabitCompletionsTableTableManager(
    _$AppDatabase db,
    $HabitCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> habitId = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<DateTime> effectiveDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<double> scoreAtCompletion = const Value.absent(),
                Value<int?> countAchieved = const Value.absent(),
                Value<double> creditPercentage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion(
                id: id,
                habitId: habitId,
                completedAt: completedAt,
                effectiveDate: effectiveDate,
                source: source,
                scoreAtCompletion: scoreAtCompletion,
                countAchieved: countAchieved,
                creditPercentage: creditPercentage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String habitId,
                required DateTime completedAt,
                required DateTime effectiveDate,
                Value<String> source = const Value.absent(),
                required double scoreAtCompletion,
                Value<int?> countAchieved = const Value.absent(),
                Value<double> creditPercentage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HabitCompletionsCompanion.insert(
                id: id,
                habitId: habitId,
                completedAt: completedAt,
                effectiveDate: effectiveDate,
                source: source,
                scoreAtCompletion: scoreAtCompletion,
                countAchieved: countAchieved,
                creditPercentage: creditPercentage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitCompletionsTable,
      HabitCompletion,
      $$HabitCompletionsTableFilterComposer,
      $$HabitCompletionsTableOrderingComposer,
      $$HabitCompletionsTableAnnotationComposer,
      $$HabitCompletionsTableCreateCompanionBuilder,
      $$HabitCompletionsTableUpdateCompanionBuilder,
      (
        HabitCompletion,
        BaseReferences<_$AppDatabase, $HabitCompletionsTable, HabitCompletion>,
      ),
      HabitCompletion,
      PrefetchHooks Function()
    >;
typedef $$UserPreferencesTableCreateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<String> quietHoursStart,
      Value<String> quietHoursEnd,
      Value<int> dayBoundaryHour,
      Value<bool> onboardingCompleted,
      Value<String> themeMode,
      Value<bool> notificationsEnabled,
      Value<int> preReminderMinutes,
      Value<int> postReminderMinutes,
      Value<DateTime?> breakModeUntil,
      Value<int> weeklySummaryDay,
      Value<String> weeklySummaryTime,
      Value<DateTime?> lastWeeklySummaryAt,
    });
typedef $$UserPreferencesTableUpdateCompanionBuilder =
    UserPreferencesCompanion Function({
      Value<int> id,
      Value<String> quietHoursStart,
      Value<String> quietHoursEnd,
      Value<int> dayBoundaryHour,
      Value<bool> onboardingCompleted,
      Value<String> themeMode,
      Value<bool> notificationsEnabled,
      Value<int> preReminderMinutes,
      Value<int> postReminderMinutes,
      Value<DateTime?> breakModeUntil,
      Value<int> weeklySummaryDay,
      Value<String> weeklySummaryTime,
      Value<DateTime?> lastWeeklySummaryAt,
    });

class $$UserPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayBoundaryHour => $composableBuilder(
    column: $table.dayBoundaryHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preReminderMinutes => $composableBuilder(
    column: $table.preReminderMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postReminderMinutes => $composableBuilder(
    column: $table.postReminderMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get breakModeUntil => $composableBuilder(
    column: $table.breakModeUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklySummaryDay => $composableBuilder(
    column: $table.weeklySummaryDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weeklySummaryTime => $composableBuilder(
    column: $table.weeklySummaryTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWeeklySummaryAt => $composableBuilder(
    column: $table.lastWeeklySummaryAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayBoundaryHour => $composableBuilder(
    column: $table.dayBoundaryHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preReminderMinutes => $composableBuilder(
    column: $table.preReminderMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postReminderMinutes => $composableBuilder(
    column: $table.postReminderMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get breakModeUntil => $composableBuilder(
    column: $table.breakModeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklySummaryDay => $composableBuilder(
    column: $table.weeklySummaryDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weeklySummaryTime => $composableBuilder(
    column: $table.weeklySummaryTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastWeeklySummaryAt => $composableBuilder(
    column: $table.lastWeeklySummaryAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPreferencesTable> {
  $$UserPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get quietHoursStart => $composableBuilder(
    column: $table.quietHoursStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quietHoursEnd => $composableBuilder(
    column: $table.quietHoursEnd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayBoundaryHour => $composableBuilder(
    column: $table.dayBoundaryHour,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
    column: $table.onboardingCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preReminderMinutes => $composableBuilder(
    column: $table.preReminderMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get postReminderMinutes => $composableBuilder(
    column: $table.postReminderMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get breakModeUntil => $composableBuilder(
    column: $table.breakModeUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklySummaryDay => $composableBuilder(
    column: $table.weeklySummaryDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weeklySummaryTime => $composableBuilder(
    column: $table.weeklySummaryTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastWeeklySummaryAt => $composableBuilder(
    column: $table.lastWeeklySummaryAt,
    builder: (column) => column,
  );
}

class $$UserPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPreferencesTable,
          UserPreference,
          $$UserPreferencesTableFilterComposer,
          $$UserPreferencesTableOrderingComposer,
          $$UserPreferencesTableAnnotationComposer,
          $$UserPreferencesTableCreateCompanionBuilder,
          $$UserPreferencesTableUpdateCompanionBuilder,
          (
            UserPreference,
            BaseReferences<
              _$AppDatabase,
              $UserPreferencesTable,
              UserPreference
            >,
          ),
          UserPreference,
          PrefetchHooks Function()
        > {
  $$UserPreferencesTableTableManager(
    _$AppDatabase db,
    $UserPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> quietHoursStart = const Value.absent(),
                Value<String> quietHoursEnd = const Value.absent(),
                Value<int> dayBoundaryHour = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> preReminderMinutes = const Value.absent(),
                Value<int> postReminderMinutes = const Value.absent(),
                Value<DateTime?> breakModeUntil = const Value.absent(),
                Value<int> weeklySummaryDay = const Value.absent(),
                Value<String> weeklySummaryTime = const Value.absent(),
                Value<DateTime?> lastWeeklySummaryAt = const Value.absent(),
              }) => UserPreferencesCompanion(
                id: id,
                quietHoursStart: quietHoursStart,
                quietHoursEnd: quietHoursEnd,
                dayBoundaryHour: dayBoundaryHour,
                onboardingCompleted: onboardingCompleted,
                themeMode: themeMode,
                notificationsEnabled: notificationsEnabled,
                preReminderMinutes: preReminderMinutes,
                postReminderMinutes: postReminderMinutes,
                breakModeUntil: breakModeUntil,
                weeklySummaryDay: weeklySummaryDay,
                weeklySummaryTime: weeklySummaryTime,
                lastWeeklySummaryAt: lastWeeklySummaryAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> quietHoursStart = const Value.absent(),
                Value<String> quietHoursEnd = const Value.absent(),
                Value<int> dayBoundaryHour = const Value.absent(),
                Value<bool> onboardingCompleted = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> preReminderMinutes = const Value.absent(),
                Value<int> postReminderMinutes = const Value.absent(),
                Value<DateTime?> breakModeUntil = const Value.absent(),
                Value<int> weeklySummaryDay = const Value.absent(),
                Value<String> weeklySummaryTime = const Value.absent(),
                Value<DateTime?> lastWeeklySummaryAt = const Value.absent(),
              }) => UserPreferencesCompanion.insert(
                id: id,
                quietHoursStart: quietHoursStart,
                quietHoursEnd: quietHoursEnd,
                dayBoundaryHour: dayBoundaryHour,
                onboardingCompleted: onboardingCompleted,
                themeMode: themeMode,
                notificationsEnabled: notificationsEnabled,
                preReminderMinutes: preReminderMinutes,
                postReminderMinutes: postReminderMinutes,
                breakModeUntil: breakModeUntil,
                weeklySummaryDay: weeklySummaryDay,
                weeklySummaryTime: weeklySummaryTime,
                lastWeeklySummaryAt: lastWeeklySummaryAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPreferencesTable,
      UserPreference,
      $$UserPreferencesTableFilterComposer,
      $$UserPreferencesTableOrderingComposer,
      $$UserPreferencesTableAnnotationComposer,
      $$UserPreferencesTableCreateCompanionBuilder,
      $$UserPreferencesTableUpdateCompanionBuilder,
      (
        UserPreference,
        BaseReferences<_$AppDatabase, $UserPreferencesTable, UserPreference>,
      ),
      UserPreference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(_db, _db.habitCompletions);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(_db, _db.userPreferences);
}
