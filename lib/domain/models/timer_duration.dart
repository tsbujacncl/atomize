/// Predefined timer duration options for habit completion.
enum TimerDurationOption {
  oneMinute(60, '1 min'),
  twoMinutes(120, '2 min'),
  fiveMinutes(300, '5 min'),
  tenMinutes(600, '10 min'),
  fifteenMinutes(900, '15 min'),
  thirtyMinutes(1800, '30 min');

  /// Duration in seconds
  final int seconds;

  /// Human-readable label
  final String label;

  const TimerDurationOption(this.seconds, this.label);

  /// Get the option matching the given seconds, or default to 2 minutes.
  static TimerDurationOption fromSeconds(int? seconds) {
    if (seconds == null) return twoMinutes;
    return TimerDurationOption.values.firstWhere(
      (option) => option.seconds == seconds,
      orElse: () => twoMinutes,
    );
  }

  /// Default timer duration in seconds (2 minutes)
  static const int defaultDuration = 120;
}
