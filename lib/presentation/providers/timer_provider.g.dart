// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the timer state for habit completion.
///
/// Auto-disposes when no longer listened to (e.g., when timer screen is popped).

@ProviderFor(HabitTimer)
const habitTimerProvider = HabitTimerProvider._();

/// Manages the timer state for habit completion.
///
/// Auto-disposes when no longer listened to (e.g., when timer screen is popped).
final class HabitTimerProvider
    extends $NotifierProvider<HabitTimer, TimerState?> {
  /// Manages the timer state for habit completion.
  ///
  /// Auto-disposes when no longer listened to (e.g., when timer screen is popped).
  const HabitTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitTimerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitTimerHash();

  @$internal
  @override
  HabitTimer create() => HabitTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimerState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimerState?>(value),
    );
  }
}

String _$habitTimerHash() => r'd4a12dcd8b2b6f3cb7d6740f200808c505c723bc';

/// Manages the timer state for habit completion.
///
/// Auto-disposes when no longer listened to (e.g., when timer screen is popped).

abstract class _$HabitTimer extends $Notifier<TimerState?> {
  TimerState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TimerState?, TimerState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimerState?, TimerState?>,
              TimerState?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
