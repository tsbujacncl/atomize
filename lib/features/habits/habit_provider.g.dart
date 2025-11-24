// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(habitRepository)
const habitRepositoryProvider = HabitRepositoryProvider._();

final class HabitRepositoryProvider
    extends
        $FunctionalProvider<HabitRepository, HabitRepository, HabitRepository>
    with $Provider<HabitRepository> {
  const HabitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitRepositoryHash();

  @$internal
  @override
  $ProviderElement<HabitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HabitRepository create(Ref ref) {
    return habitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitRepository>(value),
    );
  }
}

String _$habitRepositoryHash() => r'99f3d3542a631d09990307fc2ea4cbf419f2f7bc';

@ProviderFor(Habits)
const habitsProvider = HabitsProvider._();

final class HabitsProvider extends $AsyncNotifierProvider<Habits, List<Habit>> {
  const HabitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitsHash();

  @$internal
  @override
  Habits create() => Habits();
}

String _$habitsHash() => r'b393850108d0676e0d5ed4fd45f4935d2bbed380';

abstract class _$Habits extends $AsyncNotifier<List<Habit>> {
  FutureOr<List<Habit>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Habit>>, List<Habit>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Habit>>, List<Habit>>,
              AsyncValue<List<Habit>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
