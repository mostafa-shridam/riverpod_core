# Real app screenshots (iPhone 17 Pro simulator)

Captured by `integration_test/screens_test.dart` through `flutter drive` (see `ai-docs/TESTING.md`), from the Flutter render layer, dev flavor, mock data, no Firebase files. Each file is a different screen (the test fails if two captures are identical).

| File | Screen |
|---|---|
| onboarding.png | Onboarding carousel, first slide |
| login.png | Login page |
| home.png | Home tab with the dev-only tiles (Component gallery, Videos) |
| videos-list.png | Videos reference feature, list |
| video-detail.png | Video detail with the player surface (fake player) |
| more.png | More tab |
| showcase-en-light.png / showcase-en-dark.png | Component gallery, English LTR, light / dark |
| showcase-ar-light.png / showcase-ar-dark.png | Component gallery, Arabic RTL, light / dark |

The splash is not captured: the test starts past it and the native launch screen is only the placeholder icon.
