/// Device permissions the template knows how to request.
///
/// Android note: `photos` needs no permission when the system photo picker is
/// used (the only gallery path of `MediaService`); `microphone` needs
/// `RECORD_AUDIO` in the app manifest, which an app adds only when it records.
/// `notifications` is `POST_NOTIFICATIONS` on Android 13+ and the alert, badge
/// and sound prompt on iOS (the notification service reads its state from here).
enum AppPermission { camera, photos, microphone, notifications }

/// Outcome of a status check or a request, independent of the plugin.
enum AppPermissionResult {
  granted,

  /// iOS provisional notifications: delivered quietly, no prompt.
  provisional,
  denied,
  permanentlyDenied,
  restricted,
  limited;

  /// True when the app can use the resource now (full, limited or quiet access).
  bool get isUsable =>
      this == granted || this == limited || this == provisional;
}
