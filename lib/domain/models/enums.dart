/// Type of habit tracking
enum HabitType {
  /// Simple yes/no completion
  binary,

  /// Count-based (e.g., "drink 8 glasses of water")
  /// Planned for Phase 2
  count,

  /// Weekly frequency (e.g., "exercise 3x per week")
  /// Planned for Phase 2
  weekly,
}

/// How a habit completion was recorded
enum CompletionSource {
  /// User tapped in the app
  manual,

  /// Added from notification action
  notification,

  /// Quick-complete from widget
  widget,

  /// Added through history editing
  historyEdit,
}

/// Days of the week for scheduling
enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}
