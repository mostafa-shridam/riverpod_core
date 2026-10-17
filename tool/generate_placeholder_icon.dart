// Draws the generic placeholder app icon (no brand) with plain Dart, so no
// image tooling is needed. Run from the project root:
//
//   dart run tool/generate_placeholder_icon.dart
//
// Writes `assets/images/app_icon.png` (background + glyph, 1024 px) and
// `assets/images/app_icon_foreground.png` (glyph on transparency, for the
// Android adaptive icon and the splash). The background color is the
// `brandSeedColor` of `lib/core/design_system/tokens/brand_config.dart`.
// An app replaces both PNGs with its own artwork; this script is only the
// template's way to ship something neutral.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const _size = 1024;
const _samples = 4; // 4 x 4 supersampling for smooth edges.

// Glyph: a ring with a dot in the middle. It stays inside the central 66% of
// the canvas, the safe zone of an Android adaptive icon.
const _ringOuter = 280.0;
const _ringInner = 210.0;
const _dot = 110.0;

void main() {
  final seed = _readSeedColor();
  final background = [(seed >> 16) & 0xFF, (seed >> 8) & 0xFF, seed & 0xFF];
  const glyph = [255, 255, 255];

  final coverage = _glyphCoverage();
  _writePng(
    'assets/images/app_icon.png',
    _compose(coverage, glyph: glyph, background: background),
  );
  _writePng(
    'assets/images/app_icon_foreground.png',
    _compose(coverage, glyph: glyph),
  );
  stdout.writeln(
    'Wrote assets/images/app_icon.png and app_icon_foreground.png',
  );
}

/// `0xRRGGBB` of `brandSeedColor`.
int _readSeedColor() {
  final source = File(
    'lib/core/design_system/tokens/brand_config.dart',
  ).readAsStringSync();
  final match = RegExp(
    r'brandSeedColor\s*=\s*Color\(0xFF([0-9A-Fa-f]{6})\)',
  ).firstMatch(source);
  if (match == null) {
    stderr.writeln('brandSeedColor not found in brand_config.dart');
    exit(1);
  }
  return int.parse(match.group(1)!, radix: 16);
}

/// Glyph coverage (0..255) per pixel.
Uint8List _glyphCoverage() {
  final result = Uint8List(_size * _size);
  const center = _size / 2;
  for (var y = 0; y < _size; y++) {
    for (var x = 0; x < _size; x++) {
      var hits = 0;
      for (var sy = 0; sy < _samples; sy++) {
        for (var sx = 0; sx < _samples; sx++) {
          final dx = x + (sx + 0.5) / _samples - center;
          final dy = y + (sy + 0.5) / _samples - center;
          final distance = math.sqrt(dx * dx + dy * dy);
          if (distance <= _dot ||
              (distance >= _ringInner && distance <= _ringOuter)) {
            hits++;
          }
        }
      }
      result[y * _size + x] = hits * 255 ~/ (_samples * _samples);
    }
  }
  return result;
}

/// RGBA pixels. With a [background] the result is opaque; without, the
/// glyph color carries the coverage as alpha.
Uint8List _compose(
  Uint8List coverage, {
  required List<int> glyph,
  List<int>? background,
}) {
  final rgba = Uint8List(_size * _size * 4);
  for (var i = 0; i < coverage.length; i++) {
    final a = coverage[i];
    if (background == null) {
      rgba[i * 4] = glyph[0];
      rgba[i * 4 + 1] = glyph[1];
      rgba[i * 4 + 2] = glyph[2];
      rgba[i * 4 + 3] = a;
    } else {
      for (var c = 0; c < 3; c++) {
        rgba[i * 4 + c] = (glyph[c] * a + background[c] * (255 - a)) ~/ 255;
      }
      rgba[i * 4 + 3] = 255;
    }
  }
  return rgba;
}

void _writePng(String path, Uint8List rgba) {
  final raw = BytesBuilder();
  for (var y = 0; y < _size; y++) {
    raw
      ..addByte(0) // filter: none
      ..add(Uint8List.sublistView(rgba, y * _size * 4, (y + 1) * _size * 4));
  }
  final header = ByteData(13)
    ..setUint32(0, _size)
    ..setUint32(4, _size)
    ..setUint8(8, 8) // bit depth
    ..setUint8(9, 6); // color type: RGBA
  final png = BytesBuilder()
    ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    ..add(_chunk('IHDR', header.buffer.asUint8List()))
    ..add(_chunk('IDAT', ZLibEncoder(level: 9).convert(raw.toBytes())))
    ..add(_chunk('IEND', const []));
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(png.toBytes());
}

Uint8List _chunk(String type, List<int> data) {
  final body = [...type.codeUnits, ...data];
  final out = ByteData(12 + data.length)..setUint32(0, data.length);
  final bytes = out.buffer.asUint8List()..setRange(4, 4 + body.length, body);
  out.setUint32(8 + data.length, _crc32(body));
  return bytes;
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}
