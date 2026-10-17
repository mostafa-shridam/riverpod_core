# DEEP LINKS (C-31)

Two kinds of link open the app on a typed route:

| Kind | Example | Needs |
|---|---|---|
| https app link | `https://example.com/videos/abc` | domain you own, `assetlinks.json`, `apple-app-site-association` |
| custom scheme | `riverpod-core://videos/abc` | nothing on a server (works in dev, no verification) |

Both resolve to `type/id`, mapped by `routeForDeepLink` (`lib/core/router/routes.dart`, shared with notifications, NOTIFICATIONS.md). Mapped today: `items` and `myEvents` (item detail), `videos` (video detail, dev and staging only: D-028 redirects prod to home). Add a type there, add a test row in `test/core/router/deep_link_test.dart`.

## Where host and scheme live
The placeholders are `example.com` and `riverpod-core`. They are written in four places that must agree (guard test: `test/tool/native_setup_test.dart`):

| File | Entry |
|---|---|
| `lib/core/router/deep_link.dart` | `deepLinkHost`, `deepLinkScheme` (the one Dart place) |
| `android/app/src/main/AndroidManifest.xml` | two `intent-filter`s on `MainActivity` + `flutter_deeplinking_enabled` |
| `ios/Runner/Info.plist` | `CFBundleURLTypes` scheme + `FlutterDeepLinkingEnabled` |
| `ios/Runner/Runner.entitlements` | `applinks:<host>` |

`dart run tool/rename_app.dart --name "My App" --id com.company.myapp [--host links.company.com]` updates all four: the scheme becomes the package name with `_` as `-` (a URI scheme cannot hold an underscore: `Uri.parse('my_app://x')` throws, so Flutter could not even read such a link). Without `--host` the host stays `example.com`. `routeForAppLink` also accepts the underscore spelling of the scheme (`riverpod_core://...`) so a hand-written link still resolves.

## How the app handles a link
No plugin: Flutter hands the link to go_router (`flutter_deeplinking_enabled`). An https link's path already is a route path (`/videos/abc`). go_router matches only the path of a custom-scheme link, so `deepLinkRedirect` (first step of the router redirect) rewrites `riverpod-core://videos/abc` to `/videos/abc`; an unmapped custom link goes home. The session/onboarding redirect then runs as for any location.

Known limit: a link that arrives while the user is signed out or in onboarding lands on login/onboarding and is NOT replayed after sign-in (notification taps are: NOTIFICATIONS.md). Suggested follow-up task.

## Android App Links (https)
1. Replace the host in the four places (or run the rename tool with `--host`).
2. Host `https://<host>/.well-known/assetlinks.json` (HTTP 200, `application/json`, no redirect):
```json
[{ "relation": ["delegate_permission/common.handle_all_urls"],
   "target": { "namespace": "android_app", "package_name": "com.company.myapp",
               "sha256_cert_fingerprints": ["<SHA-256 of the signing certificate>"] } }]
```
Fingerprints: the upload key and, with Play App Signing, the app signing key from Play Console (Setup > App signing). Debug builds use the debug keystore fingerprint (`./gradlew signingReport`).
3. `android:autoVerify="true"` is already on the https filter. Check: `adb shell pm get-app-links com.company.myapp`; test: `adb shell am start -a android.intent.action.VIEW -d "https://<host>/videos/abc"`.

## iOS Universal Links (https)
1. The entitlement `applinks:<host>` is in `Runner.entitlements`. It needs the Associated Domains capability on the App ID and a provisioning profile that has it. A free personal team cannot sign it: remove that entry from the entitlements file for device runs with such an account (the custom scheme keeps working), or use a paid team.
2. Host `https://<host>/.well-known/apple-app-site-association` (no extension, `application/json`, no redirect):
```json
{ "applinks": { "details": [ { "appIDs": ["<TEAM_ID>.com.company.myapp"],
  "components": [ { "/": "/videos/*" }, { "/": "/items/*" } ] } ] } }
```
3. Test: `xcrun simctl openurl booted "https://<host>/videos/abc"` (simulator) or tap the link in Notes/Messages on a device. Universal links do not fire when typed in Safari's address bar.

## Custom scheme test
- Android: `adb shell am start -a android.intent.action.VIEW -d "riverpod-core://videos/abc"`
- iOS simulator: `xcrun simctl openurl booted "riverpod-core://videos/abc"`

A custom scheme is not exclusive (another app can claim it), so never carry secrets or sign-in tokens in it.

## Not verified here
Link opening on a real device, domain verification and the entitlement on a signed build need a real domain and Apple/Google accounts. The template tests cover the mapping, the router and the file agreement only.
