/// Device permissions the template knows how to request.
///
/// Android note: `photos` needs no permission when the system photo picker is
/// used (the only gallery path of `MediaService`); `microphone` needs
/// `RECORD_AUDIO` in the app manifest, which an app adds only when it records.
enum AppPermission { camera, photos, microphone }

/// Outcome of a status check or a request, independent of the plugin.
enum AppPermissionResult {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited;

  /// True when the app can use the resource now (full or limited access).
  bool get isUsable => this == granted || this == limited;
}
