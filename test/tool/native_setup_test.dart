import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/tokens/brand_config.dart';
import 'package:riverpod_core/core/router/deep_link.dart';

// The native files cannot import the Dart constants, so this test keeps the
// copies in step: deep-link host and scheme, icon files, splash color.

String _read(String path) => File(path).readAsStringSync();

String _hex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}'
        .toUpperCase();

String? _group(String source, String pattern) =>
    RegExp(pattern).firstMatch(source)?.group(1)?.toUpperCase();

void main() {
  group('deep links', () {
    test('Android manifest has the https host and the custom scheme', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      expect(
        manifest,
        contains('android:scheme="https" android:host="$deepLinkHost"'),
      );
      expect(manifest, contains('<data android:scheme="$deepLinkScheme"/>'));
      expect(manifest, contains('flutter_deeplinking_enabled'));
      expect(manifest, contains('android:autoVerify="true"'));
    });

    test(
      'iOS plist (and entitlements, when enabled) match the same host and scheme',
      () {
        final plist = _read('ios/Runner/Info.plist');
        expect(plist, contains('<string>$deepLinkScheme</string>'));
        expect(
          RegExp(
            r'<key>FlutterDeepLinkingEnabled</key>\s*<true/>',
          ).hasMatch(plist),
          isTrue,
        );
        // Not shipped: a free Apple team cannot sign it (DEEP_LINKS.md). If an
        // app adds it, it must use the same host.
        final entitlements = _read('ios/Runner/Runner.entitlements');
        if (entitlements.contains('applinks:')) {
          expect(entitlements, contains('applinks:$deepLinkHost'));
        }
      },
    );

    test('the scheme is a valid URI scheme and the host is a placeholder', () {
      expect(() => Uri.parse('$deepLinkScheme://videos/abc'), returnsNormally);
      expect(deepLinkHost, 'example.com');
    });
  });

  group('icons and splash', () {
    test('the placeholder icons are 1024 px PNG files', () {
      for (final path in [
        'assets/images/app_icon.png',
        'assets/images/app_icon_foreground.png',
      ]) {
        final bytes = Uint8List.fromList(File(path).readAsBytesSync());
        expect(bytes.sublist(1, 4), 'PNG'.codeUnits, reason: path);
        final header = ByteData.sublistView(bytes, 16, 24);
        expect(header.getUint32(0), 1024, reason: path);
        expect(header.getUint32(4), 1024, reason: path);
      }
    });

    test('splash and icon colors equal the brand seed color', () {
      final seed = _hex(brandSeedColor);
      final pubspec = _read('pubspec.yaml');
      expect(
        _group(pubspec, r'flutter_native_splash:\s*\n\s*color: "([^"]+)"'),
        seed,
      );
      expect(_group(pubspec, r'adaptive_icon_background: "([^"]+)"'), seed);
    });

    test('the generated native icon and splash files are committed', () {
      for (final path in [
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
        'android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png',
        'android/app/src/main/res/values-v31/styles.xml',
        'android/app/src/main/res/values-night-v31/styles.xml',
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });
  });
}
