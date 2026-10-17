# FIREBASE (C-30, D-042)

Crash reporting (Crashlytics) and analytics (Firebase Analytics) are real but strictly optional. The template contains NO Firebase file, key or project id. A clean clone builds and runs with Noop crash/analytics.

## What is optional, and how it decides
```
lib/core/firebase/   firebase_bootstrap.dart   FirebaseBootstrap.ensureInitialized(): Firebase.initializeApp() once, never throws,
                                               logs "Firebase not configured: crash/analytics disabled" once. firebaseAvailableProvider = the result.
                     observability_init.dart   initObservability(container): the one startup call from bootstrap().
                     collection_consent.dart   collectionConsentProvider: persisted on/off switch, applied to both vendors.
lib/core/crash/      CrashReporter (interface) | Noop | Console | FirebaseCrashReporter -> CrashBackend (Crashlytics seam)
lib/core/analytics/  AnalyticsService (interface) | Noop | Console | FirebaseAnalyticsService -> AnalyticsBackend (Analytics seam)
                     AnalyticsRouteObserver (+ analyticsRouteObserverProvider): screen views for named page routes
```
A vendor is used only when BOTH are true: the config flag is on (`ENABLE_CRASH_REPORTING` / `ENABLE_ANALYTICS`; defaults: on for prod and staging, off for dev) AND Firebase started. Otherwise Noop. `firebase_*` is imported only in `core/crash`, `core/analytics`, `core/firebase`, `core/notifications`.

`FirebasePushBackend` (notifications) goes through the same `FirebaseBootstrap`, so Firebase is initialized exactly once.

## Native: builds without Firebase files
- Android: `android/settings.gradle.kts` declares the `com.google.gms.google-services` and `com.google.firebase.crashlytics` plugins (`apply false`). `android/app/build.gradle.kts` applies them ONLY when `android/app/google-services.json` exists.
- iOS: the Runner target has a build phase "Crashlytics symbol upload (optional)". It runs `Pods/FirebaseCrashlytics/run` only when `ios/Runner/GoogleService-Info.plist` exists, the build produces a dSYM (Release/Profile) and the pod is linked. Otherwise it prints one line and succeeds.
- `google-services.json` and `GoogleService-Info.plist` are git-ignored. Never commit them.

## Add Firebase to an app
1. Create the Firebase project; register the Android app (package = `applicationId`) and the iOS app (bundle id). Enable Crashlytics and Analytics in the console.
2. FlutterFire CLI: `dart pub global activate flutterfire_cli`, then `flutterfire configure`. It writes `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` (the CLI also creates `lib/firebase_options.dart`; the template does not use it, delete it, because `Firebase.initializeApp()` reads the native files). By hand: download both files from Project settings and put them in the same two places; add the plist to the Runner target in Xcode.
3. Set `ENABLE_CRASH_REPORTING=true` / `ENABLE_ANALYTICS=true` in the `env/<flavor>.env` files you want (dev is off by default, so test crashes in a staging/prod-like run).
4. iOS: `cd ios && pod install`. Android: nothing else; the Gradle plugins switch on by themselves.

## Consent
`collectionConsentProvider` (device-level, survives logout) defaults to ON (`defaultCollectionConsent` in `collection_consent.dart`; flip it there for opt-in regions). `ref.read(collectionConsentProvider.notifier).setEnabled(value: false)` persists the choice and calls `setCollectionEnabled(false)` on Crashlytics and Analytics. The app shows its own switch (user text through `LocaleKeys`); the template ships none.
For strict opt-in, also disable auto-collection natively until the user agrees (`firebase_crashlytics_collection_enabled=false` and `firebase_analytics_collection_enabled=false` meta-data in `AndroidManifest.xml`, `FirebaseCrashlyticsCollectionEnabled`/`FIREBASE_ANALYTICS_COLLECTION_ENABLED` = NO in `Info.plist`). The template does not set them (zero config).

## Privacy
Only the opaque user id is sent (`SessionController`: set on sign-in and session restore, cleared on logout together with `AnalyticsService.reset()`). Never put emails, names, tokens or free text into events, custom keys or breadcrumbs. `FirebaseAnalyticsService` drops null params, sends bools as 1/0 and other non-String/num values as `toString()`.

## Error routing
`bootstrap()` installs `FlutterError.onError` (non-fatal), `PlatformDispatcher.onError` and the zone handler (fatal) and sends them through `CrashReporter`. Screen views: add `ref.read(analyticsRouteObserverProvider)` to the router's `observers`.

## Switch vendor (Sentry or other)
Implement `CrashReporter` and/or `AnalyticsService` for the new vendor and return it from `crashReporterProvider` / `analyticsServiceProvider` instead of the Firebase classes. No caller changes. Adding a package is a DECISION.

## Verify with a test crash
1. Run a build with the flags on and the Firebase files in place (release or profile mode on a device; Crashlytics ignores the debugger, so run without it attached).
2. From any debug-only button or a scratch snippet: `ref.read(crashReporterProvider).recordError(StateError('test'), StackTrace.current, fatal: true, reason: 'test crash')`. Non-fatal appears after the next launch, in Firebase console, Crashlytics, within minutes.
3. Analytics: `ref.read(analyticsServiceProvider).logEvent('test_event')`; use the console's DebugView (`adb shell setprop debug.firebase.analytics.app <applicationId>`) to see it live.
4. Without Firebase files the log shows "Firebase not configured: crash/analytics disabled" once and nothing is sent.

## Known limits
- Not verified against a real Firebase project in the template (no project data by design).
- Collection consent uses `shared_preferences` directly (key `settings.collectionConsent`) because `PrefKeys` belongs to the storage task; move it into `PrefsStorage` when that is free.
