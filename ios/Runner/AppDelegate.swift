import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Set from Dart through the `riverpod_core/secure_screen` channel.
  private var secureScreenEnabled = false
  private var coverView: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Foreground presentation and taps of local notifications
    // (flutter_local_notifications).
    UNUserNotificationCenter.current().delegate = self
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(showCover),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(hideCover),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "SecureScreen") {
      let channel = FlutterMethodChannel(
        name: "riverpod_core/secure_screen",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { [weak self] call, result in
        if call.method == "setSecure" {
          self?.secureScreenEnabled = (call.arguments as? Bool) ?? false
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }

  // iOS cannot block screenshots; it can hide the content in the app switcher
  // snapshot by covering the window while the app is not active.
  @objc private func showCover() {
    guard secureScreenEnabled, coverView == nil else { return }
    let window = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    guard let window = window else { return }
    let cover = UIView(frame: window.bounds)
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    cover.backgroundColor = .systemBackground
    window.addSubview(cover)
    coverView = cover
  }

  @objc private func hideCover() {
    coverView?.removeFromSuperview()
    coverView = nil
  }
}
