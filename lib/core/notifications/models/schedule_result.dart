/// What `schedule` did.
enum ScheduleResult {
  /// Scheduled with an exact alarm.
  exact,

  /// Scheduled inexactly: the exact-alarm permission is not granted.
  inexact,

  /// Not scheduled: the time is not in the future.
  inThePast,

  /// Not scheduled: the user turned this channel or all notifications off.
  disabled,
}
