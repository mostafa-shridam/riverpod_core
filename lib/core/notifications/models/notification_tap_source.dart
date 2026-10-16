/// Where a notification tap came from.
enum NotificationTapSource {
  /// Push tapped while the app was in the background.
  pushOpened,

  /// Push tapped while the app was terminated (cold start).
  pushInitial,

  /// Local notification tapped while the app was running.
  localTap,

  /// Local notification tapped while the app was terminated (cold start).
  localLaunch,
}
