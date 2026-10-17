# NOTIFICATIONS

Push (FCM) and local notifications, one system, no singletons, no Firestore. Code: `lib/core/notifications/`, `lib/core/device/`.

## Architecture
```
notifications/
├── notification_service.dart           NotificationService: the facade (initialize, permission, settings, login/logout hooks)
├── notification_service_provider.dart  notificationServiceProvider, notificationLogoutProvider
├── notification_providers.dart         backend seams, permission flow, registrar, pushAvailableProvider
├── models/       NotificationPayload, NotificationTap, PushMessage, LocalNotification, ScheduledNotification, ...
├── channels/     notification_channels.dart (THE channel table), notification_categories.dart (iOS)
├── local/        LocalNotificationBackend (+ flutter_local_notifications impl), LocalNotificationService, NotificationBadge, TimezoneBackend
├── push/         PushBackend (+ firebase_messaging impl), PushService, PushTokenManager, background handler, MessageDeduplicator
├── permission/   notification permission state mapping (`notificationStateOf`); the request itself goes through the shared `PermissionService` (`AppPermission.notifications`)
├── registration/ PushTokenRegistrar (interface), Noop (default), Dio example (disabled)
├── routing/      NotificationRouter (+ provider): every tap -> typed route
└── settings/     NotificationSettings + NotificationSettingsController (user switches)
device/           DeviceInfo, DeviceInfoSource (+ device_info_plus impl), deviceInfoProvider
```
Rules: every plugin sits behind a small `*Backend` interface exposed as a provider (`localNotificationBackendProvider`, `pushBackendProvider`, `notificationPermissionBackendProvider`, `timezoneBackendProvider`); tests override them with the fakes in `test/helpers/fake_notification_backends.dart`, so no platform channel is ever needed. There is no `X.instance`.

Startup: `bootstrap` calls `notificationServiceProvider.initialize()` (never throws, never prompts). Order: load settings, init local (time zone, cold-start tap; channels are NOT created here, translations are not loaded yet), init push (Firebase, background handler, foreground listeners, initial message). A failing part is logged and the rest keeps working.

## Firebase is optional
`Firebase.initializeApp()` fails when the app has no `google-services.json` / `GoogleService-Info.plist`. Then push is off: one log line ("Push is disabled"), `pushAvailableProvider` is false, topics/token calls are no-ops, local notifications and everything else work. Hide push-only UI with `ref.watch(pushAvailableProvider)`.

The template NEVER writes to Firestore or any Firebase database. The device and token go to YOUR backend through `PushTokenRegistrar`.

## Payload contract
Send the same keys in the FCM `data` map and in a local notification payload:
```json
{
  "type": "myEvents",
  "id": "42",
  "url": "https://example.com/promo",
  "channel": "high_priority"
}
```
| key | meaning |
|---|---|
| `type` + `id` | open a typed route. Both required. `type` is mapped by `routeForDeepLink` (`lib/core/router/routes.dart`); an unknown type is ignored (and falls through to `url` if present). Add your types there. |
| `url` | open an external `http`/`https` page when there is no route. Other schemes are ignored. |
| `channel` | Android channel id for a foreground push (`general`, `high_priority`, `silent`, `reminders`). Unknown or missing = `general`. The notification block's `android.channel_id` wins when set. |
| anything else | kept in `NotificationPayload.extra`, untouched. |

Message kinds: notification+data (shown by the system in background, by us in foreground), data-only (never shown; foreground ones arrive on `notificationService.silentMessages`, background ones in `firebaseMessagingBackgroundHandler`).

Example FCM HTTP v1 body:
```json
{ "message": { "token": "<fcm token>",
  "notification": { "title": "Order shipped", "body": "Tap to track it" },
  "data": { "type": "myEvents", "id": "42" },
  "android": { "notification": { "channel_id": "general" } } } }
```

## Taps and routing
`NotificationRouter.handle(tap)` is the one door. Sources: push opened (background), push initial (cold start), local tap, local launch (cold start). A tap resolves to a typed route (opened with `router.go`), else a safe url (external browser), else it is ignored. Taps that arrive before the app router is attached or before the user is signed in are queued (newest 5) and replayed in order after sign-in. Presses of action buttons (`actionId` set, for example the iOS inline reply) are not navigation: listen on `notificationService.actions`.

## Local notifications
`ref.read(notificationServiceProvider).local`:
`show` (returns the id, or null when the channel/master switch is off), `showNotification` (full model: big text, big picture file path, group key, iOS badge, category), `showGroupSummary` (Android stacked group), `schedule`, `scheduleDaily`, `scheduleWeekly`, `cancel`, `cancelAll`, `pending`, `requestExactAlarmPermission`, `canScheduleExact`. `service.badge` sets the iOS icon badge.

Scheduling: exact alarm only when the Android 12+ exact-alarm permission is granted (`SCHEDULE_EXACT_ALARM` is declared; `USE_EXACT_ALARM` is NOT, Google Play restricts it to alarm/calendar apps). Otherwise it falls back to an inexact alarm that may be a few minutes late; `schedule` returns `ScheduleResult.exact` or `.inexact` so the UI can offer `requestExactAlarmPermission()`. A time in the past returns `inThePast` and schedules nothing. Repeats use the device time zone (`flutter_native_timezone_latest` + `timezone`, UTC fallback) and survive reboot (boot receiver in the manifest). Scheduled notifications are cancelled on logout and when the master switch goes off; the app re-schedules what it needs after the user turns notifications on.

Channels: ONE table, `channels/notification_channels.dart` (`general`, `high_priority`, `silent`, `reminders`, in two groups). Channel names and descriptions are `LocaleKeys` under `notifications`, resolved when the channel is created; `syncChannelLabels()` re-creates them in the current language (done by `NotificationLabelSync`, mounted in `App`, after translations load on the first frame and on every language change, and again at sign-in). Never rename a shipped channel id: users keep per-channel settings. Small icon: `android/.../drawable/ic_notification.xml` (replace per app); accent color: `brandSeedColor`.

iOS categories/actions: `NotificationCategories.message` (inline reply + mark as read), registered at init and re-registered with localized titles by `syncChannelLabels()`.

## Permission
`service.ensurePermission(context)` (through the shared `PermissionService`): granted/provisional returns; denied shows the rationale first when Android advises it, then the system prompt (Android 13 `POST_NOTIFICATIONS`; iOS alert + badge + sound); permanently denied shows the rationale with "open settings". `service.requestProvisionalPermission()` (iOS quiet delivery, no prompt, needs push). OS state for the UI: `notificationPermissionStateProvider` (invalidate it when the app resumes from settings). `service.openSystemSettings()` opens the app's settings page.

Rationale UI: the flow takes a `NotificationRationalePresenter` from `notificationRationalePresenterProvider` (null = no explanation step). The shared design-system dialog is keyed by `AppPermission`, which has no `notifications` value yet (D-039).

## User settings
`notificationSettingsControllerProvider` (`NotificationSettings`): master switch = `PrefsStorage.notificationsEnabled`; per-channel switches = the list of disabled channel ids at `user.notifications.disabledChannels` (user-scoped: logout clears them). `service.setEnabled(enabled:, context:)` and `service.setChannelEnabled(id, enabled:)` persist and apply: master off cancels scheduled notifications, unregisters the token from your backend and stops iOS foreground presentation; master on (with a context) asks for the permission first and stays off if declined.

## Token registration and logout
Implement `PushTokenRegistrar` (`register(PushTokenRegistration)`, `unregister(token)`) for your API and override `pushTokenRegistrarProvider`. A Dio example with the endpoint in one constant (`pushTokenEndpoint`) is `DioPushTokenRegistrar`, DISABLED by default (default = `NoopPushTokenRegistrar`):
```dart
pushTokenRegistrarProvider.overrideWith((ref) => DioPushTokenRegistrar(ref.watch(dioProvider)))
```
The service follows `SessionController`: signed in registers the current token (and every refresh); failures are logged and retried at the next sign-in, refresh or switch change. The device facts sent come from `deviceInfoProvider` (platform, model, OS version, random per-install id; no hardware ids).

Logout: the auth feature MUST call, and await, the hook before wiping credentials, because the unregister call needs the session:
```dart
await ref.read(notificationLogoutProvider)();   // unregister on server, delete FCM token, cancel scheduled, clear badge
await clearUserData(...);                       // then the existing wipe
```
(An unannounced sign-out, for example an expired session, still deletes the token and cancels scheduled notifications locally.)

Topics: `service.push.subscribeToTopic('news')` / `unsubscribeFromTopic`. Topic subscriptions die with `deleteToken`, so re-subscribe user topics after sign-in.

## Platform setup checklist
Firebase (once per app; the template builds without it):
1. Create the Firebase project; add the Android app (package name = `applicationId`) and the iOS app (bundle id).
2. Download `google-services.json` to `android/app/` and `GoogleService-Info.plist` to `ios/Runner/` (add it to the Runner target in Xcode). Both are git-ignored: NEVER commit them. Keep `*.example` files only.
3. Android: the Google Services Gradle plugin must be applied (`com.google.gms.google-services`) once the json exists; `android/app/build.gradle.kts` applies it automatically when the json exists (see FIREBASE.md).
4. iOS: Apple Developer, Keys, create an APNs Auth Key (`.p8`); in Firebase, Project settings, Cloud Messaging, upload the key with the Key ID and Team ID.
5. iOS capabilities: Runner target, Signing & Capabilities: "Push Notifications" and "Background Modes" with "Remote notifications". The repo already has `Runner.entitlements` (`aps-environment` = `development`, referenced in the project) and `UIBackgroundModes` = `remote-notification`. For App Store/TestFlight builds the value must be `production` (Xcode switches it at archive time when the capability is enabled; verify).
6. iOS: the Podfile needs the permission_handler macro `PERMISSION_NOTIFICATIONS=1`.
7. Run on a REAL iPhone: the simulator does not receive remote pushes reliably and has no APNs token.

Already in the repo: Android manifest (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, boot/scheduled/action receivers, default channel id `general`, default icon `ic_notification`), `AppDelegate` sets the `UNUserNotificationCenter` delegate (foreground and taps of local notifications), core library desugaring (required by flutter_local_notifications).

## Testing from the Firebase console
1. Run the app on a device with Firebase configured; get the token from your backend (the app never logs it) or temporarily print `await ref.read(pushBackendProvider).token()` in a debug build.
2. Firebase console, Engage, Messaging, "Create your first campaign" or "New campaign", Notification; "Send test message", paste the token.
3. Notification title/body for a visible message. Under "Additional options", "Custom data" add `type` = `myEvents` and `id` = `42` (and optionally `channel` = `high_priority`).
4. Test the three states: foreground (shown by the app on Android, by the system on iOS), background (tap: opens the route), terminated (swipe the app away, send, tap: opens the route after splash and sign-in).
5. Data-only: use the HTTP v1 API (no `notification` block); nothing is shown; foreground ones appear on `silentMessages`.

## Troubleshooting
| Symptom | Check |
|---|---|
| `pushAvailableProvider` false | the log line "Push is disabled": missing/misplaced google-services files, or Google Services plugin not applied |
| No token on iOS | real device, APNs key uploaded, Push capability on, permission granted (`apns-token-not-set` right after launch is normal; the refresh stream delivers it) |
| Nothing shown on Android 13+ | permission denied: `notificationPermissionStateProvider`; call `ensurePermission` |
| Foreground push not shown on Android | master switch or the channel switched off (`NotificationSettings`); the foreground path shows it through a local notification |
| Foreground push shown twice on iOS | only the system should present it; `showForegroundWithLocal` is false on iOS |
| Scheduled notification late | exact alarms not allowed: `schedule` returned `inexact`; offer `requestExactAlarmPermission()`; battery optimisation can delay too |
| Scheduled notification wrong hour | the device time zone: if the platform cannot report it the backend falls back to UTC; check the device's automatic time zone setting |
| Tap does nothing | unknown `type` in `routeForDeepLink`, missing `id`, or the user is not signed in (the tap is queued and replays after sign-in) |
| Channel names show keys | channels were created before translations loaded; `NotificationLabelSync` (in `App`) re-creates them after load and on language change, so check it is mounted |
| Changed channel importance has no effect | Android never changes an existing channel's importance; use a new channel id or reinstall |

## Known limits
- `firebase_messaging` 17: the token calls are the deprecated `getToken`/`onTokenRefresh`/`deleteToken`, used on purpose in `firebase_push_backend.dart` only (the replacement `register()` yields an installation id, not the FCM token servers send to).
- Push images (`imageUrl`) are not downloaded for foreground notifications; big pictures take a local file path.
- Background action buttons that must not open the app are not wired (all iOS actions use the foreground option); the plugin's background callback is not registered.
- The iOS badge is set with a silent local notification; the count lives in memory (`NotificationBadge.set` with an absolute number after a restart).
