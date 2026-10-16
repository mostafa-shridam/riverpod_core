/// Operating-system permission to show notifications.
enum NotificationPermissionState {
  granted,

  /// iOS provisional: delivered quietly, without alert or sound.
  provisional,

  /// Not granted; the system prompt can still be shown.
  denied,

  /// Only the system settings can change it (also used for restricted).
  permanentlyDenied;

  /// True when notifications can be delivered.
  bool get isAllowed => this == granted || this == provisional;
}
