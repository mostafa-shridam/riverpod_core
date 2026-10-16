import 'dart:io';

// Pure rename logic behind `tool/rename_app.dart`. It lives in tool/, outside lib/,
// so the app never ships it. Every rewrite is a string transform; [renameApp]
// applies them to a project tree.

/// The values that identify the renamed app.
class RenameRequest {
  const RenameRequest({
    required this.name,
    required this.id,
    required this.package,
  });

  /// Display name, e.g. "My App".
  final String name;

  /// Reverse-DNS application id, e.g. com.company.myapp.
  final String id;

  /// Dart package name, snake_case, e.g. my_app.
  final String package;
}

/// What the command line asked for.
class RenameOptions {
  const RenameOptions({required this.request, required this.dryRun});

  final RenameRequest request;
  final bool dryRun;
}

/// One file the rename writes or moves. [detail] says what changed in it.
class RenameChange {
  const RenameChange({required this.path, required this.detail});

  final String path;
  final String detail;
}

/// Thrown for invalid input, a missing project, or a rename that would change nothing.
class RenameException implements Exception {
  const RenameException(this.problems);

  final List<String> problems;

  @override
  String toString() => problems.join('\n');
}

// Names are limited to characters that need no escaping in XML, Gradle or YAML.
final _namePattern = RegExp(r'^[\p{L}\p{N} ._-]+$', unicode: true);

// Lowercase only, no underscores: iOS bundle ids reject them.
final _idPattern = RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$');
final _packagePattern = RegExp(r'^[a-z][a-z0-9_]*$');

const _kotlinRoot = 'android/app/src/main/kotlin';
const _ignoredDirs = {'build', '.dart_tool', '.git'};

/// Returns every problem with [request]; empty when it is valid.
List<String> validateRename(RenameRequest request) {
  final problems = <String>[];
  if (request.name.isEmpty) {
    problems.add('--name is required (display name, e.g. "My App").');
  } else if (!_namePattern.hasMatch(request.name)) {
    problems.add(
      '--name may contain only letters, digits, spaces, "." "_" and "-"; '
      'got "${request.name}".',
    );
  } else if (request.name != request.name.trim()) {
    problems.add('--name must not start or end with a space.');
  }
  if (!_idPattern.hasMatch(request.id)) {
    problems.add(
      '--id must be reverse-DNS with lowercase letters and digits and at '
      'least two segments, e.g. com.company.myapp; got "${request.id}".',
    );
  }
  if (!_packagePattern.hasMatch(request.package)) {
    problems.add(
      '--package must be snake_case and start with a letter, e.g. my_app; '
      'got "${request.package}".',
    );
  }
  return problems;
}

/// Derives a snake_case Dart package name from a display name, e.g. "My App" → my_app.
/// Returns '' when nothing usable is left (for example, a name with no ASCII letters).
String defaultPackageName(String name) {
  var package = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  if (package.isEmpty) {
    return '';
  }
  if (RegExp(r'^[0-9]').hasMatch(package)) {
    package = 'app_$package';
  }
  return package;
}

/// Parses `--name`, `--id`, `--package` (each as `--x value` or `--x=value`) and `--dry-run`.
/// The package defaults to [defaultPackageName] of the name.
RenameOptions parseRenameArgs(List<String> args) {
  String? name;
  String? id;
  String? package;
  var dryRun = false;
  final problems = <String>[];

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--dry-run') {
      dryRun = true;
      continue;
    }
    final equals = arg.indexOf('=');
    final flag = equals == -1 ? arg : arg.substring(0, equals);
    if (!const {'--name', '--id', '--package'}.contains(flag)) {
      problems.add('Unknown option "$arg".');
      continue;
    }
    final String value;
    if (equals != -1) {
      value = arg.substring(equals + 1);
    } else if (i + 1 < args.length) {
      value = args[++i];
    } else {
      problems.add('$flag needs a value.');
      continue;
    }
    if (flag == '--name') {
      name = value.trim();
    } else if (flag == '--id') {
      id = value.trim();
    } else {
      package = value.trim();
    }
  }

  if (name == null || name.isEmpty) {
    problems.add('--name is required (display name, e.g. "My App").');
  }
  if (id == null || id.isEmpty) {
    problems.add('--id is required (e.g. com.company.myapp).');
  }
  if (package == null && name != null && name.isNotEmpty) {
    package = defaultPackageName(name);
    if (package.isEmpty) {
      problems.add('--package is required: it cannot be derived from "$name".');
    }
  }
  if (problems.isNotEmpty) {
    throw RenameException(problems);
  }
  return RenameOptions(
    request: RenameRequest(name: name!, id: id!, package: package!),
    dryRun: dryRun,
  );
}

// Pure transforms: each takes a file's content and returns the renamed content.

String rewritePubspec(String content, RenameRequest request) => content
    .replaceFirst(
      RegExp(r'^name: .*$', multiLine: true),
      'name: ${request.package}',
    )
    .replaceFirst(
      RegExp(r'^description: .*$', multiLine: true),
      'description: "${request.name}"',
    );

String rewriteReadme(String content, String name) =>
    content.replaceFirst(RegExp(r'^# .*$', multiLine: true), '# $name');

String rewriteGradle(String content, String id) => content
    .replaceAllMapped(
      RegExp(r'(namespace\s*=\s*")[^"]*(")'),
      (m) => '${m[1]!}$id${m[2]!}',
    )
    .replaceAllMapped(
      RegExp(r'(applicationId\s*=\s*")[^"]*(")'),
      (m) => '${m[1]!}$id${m[2]!}',
    );

String rewriteManifest(String content, String name) => content.replaceAllMapped(
  RegExp(r'(android:label=")[^"]*(")'),
  (m) => '${m[1]!}$name${m[2]!}',
);

String rewriteKotlin(String content, String id) => content.replaceFirst(
  RegExp(r'^package .*$', multiLine: true),
  'package $id',
);

String rewritePlist(String content, RenameRequest request) => content
    .replaceAllMapped(
      RegExp(r'(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)'),
      (m) => '${m[1]!}${request.name}${m[2]!}',
    )
    .replaceAllMapped(
      RegExp(r'(<key>CFBundleName</key>\s*<string>)[^<]*(</string>)'),
      (m) => '${m[1]!}${request.package}${m[2]!}',
    );

/// The RunnerTests target gets the same id with `.RunnerTests` appended.
String rewritePbxproj(String content, String id) => content.replaceAllMapped(
  RegExp(r'(PRODUCT_BUNDLE_IDENTIFIER = )([^;]+)(;)'),
  (m) {
    final suffix = m[2]!.endsWith('.RunnerTests') ? '.RunnerTests' : '';
    return '${m[1]!}$id$suffix${m[3]!}';
  },
);

String rewriteEnvExample(String content, String name) =>
    content.replaceAllMapped(
      RegExp(r'("APP_NAME"\s*:\s*")[^"]*(")'),
      (m) => '${m[1]!}$name${m[2]!}',
    );

String rewriteDartImports(
  String content, {
  required String from,
  required String to,
}) => content.replaceAll('package:$from/', 'package:$to/');

/// Renames the Flutter project at [root]. Returns the changes; with [dryRun] nothing is written.
///
/// Throws [RenameException] for invalid input, a directory without pubspec.yaml,
/// a request whose values already match the tree, or a Kotlin target that exists.
/// Files that are not present are skipped.
Future<List<RenameChange>> renameApp({
  required Directory root,
  required RenameRequest request,
  bool dryRun = false,
}) async {
  final problems = validateRename(request);
  if (problems.isNotEmpty) {
    throw RenameException(problems);
  }
  if (!File(_resolve(root, 'pubspec.yaml')).existsSync()) {
    throw RenameException([
      'No pubspec.yaml in ${root.path}; run the script from the project root.',
    ]);
  }

  final oldPackage = _firstGroup(
    RegExp(r'^name: (\S+)$', multiLine: true),
    await _read(root, 'pubspec.yaml'),
  );
  final oldId = _firstGroup(
    RegExp(r'applicationId\s*=\s*"([^"]+)"'),
    await _read(root, 'android/app/build.gradle.kts'),
  );
  final oldName = _firstGroup(
    RegExp(r'android:label="([^"]*)"'),
    await _read(root, 'android/app/src/main/AndroidManifest.xml'),
  );
  if (oldPackage == request.package &&
      oldId == request.id &&
      oldName == request.name) {
    throw RenameException([
      'The app already has name "$oldName", id "$oldId" and package '
          '"$oldPackage"; nothing to rename.',
    ]);
  }

  final writes = <_Write>[];
  final moves = <_Move>[];

  Future<void> rewrite(
    String path,
    String Function(String) transform,
    String detail,
  ) async {
    if (!File(_resolve(root, path)).existsSync()) {
      return;
    }
    final before = await _read(root, path);
    final after = transform(before);
    if (after != before) {
      writes.add(_Write(path, after, detail));
    }
  }

  await rewrite(
    'pubspec.yaml',
    (c) => rewritePubspec(c, request),
    'name, description',
  );
  await rewrite('README.md', (c) => rewriteReadme(c, request.name), 'title');
  await rewrite(
    'android/app/build.gradle.kts',
    (c) => rewriteGradle(c, request.id),
    'namespace, applicationId',
  );
  await rewrite(
    'android/app/src/main/AndroidManifest.xml',
    (c) => rewriteManifest(c, request.name),
    'android:label',
  );
  await rewrite(
    'ios/Runner/Info.plist',
    (c) => rewritePlist(c, request),
    'CFBundleDisplayName, CFBundleName',
  );
  await rewrite(
    'ios/Runner.xcodeproj/project.pbxproj',
    (c) => rewritePbxproj(c, request.id),
    'PRODUCT_BUNDLE_IDENTIFIER',
  );

  for (final path in await _filesUnder(root, const [
    'lib',
    'test',
    'integration_test',
  ], (p) => p.endsWith('.dart'))) {
    await rewrite(
      path,
      (c) => rewriteDartImports(c, from: oldPackage, to: request.package),
      'package imports',
    );
  }
  for (final path in await _filesUnder(root, const [
    'env',
  ], (p) => p.endsWith('.example.json'))) {
    await rewrite(path, (c) => rewriteEnvExample(c, request.name), 'APP_NAME');
  }

  // MainActivity moves to the folder that matches the new package.
  final kotlinTarget = '$_kotlinRoot/${request.id.replaceAll('.', '/')}';
  for (final path in await _filesUnder(root, const [
    _kotlinRoot,
  ], (p) => p.endsWith('/MainActivity.kt'))) {
    final target = '$kotlinTarget/MainActivity.kt';
    final after = rewriteKotlin(await _read(root, path), request.id);
    if (target == path) {
      if (after != await _read(root, path)) {
        writes.add(_Write(path, after, 'package line'));
      }
      continue;
    }
    if (File(_resolve(root, target)).existsSync()) {
      throw RenameException([
        '$target already exists; refusing to overwrite it.',
      ]);
    }
    writes.add(_Write(target, after, 'package line, moved from $path'));
    moves.add(_Move(path, target));
  }

  if (!dryRun) {
    for (final write in writes) {
      final file = File(_resolve(root, write.path));
      file.parent.createSync(recursive: true);
      await file.writeAsString(write.content);
    }
    for (final move in moves) {
      File(_resolve(root, move.from)).deleteSync();
      _pruneEmptyKotlinDirs(root, move.from);
    }
  }

  return [
    for (final write in writes)
      RenameChange(path: write.path, detail: write.detail),
  ];
}

class _Write {
  const _Write(this.path, this.content, this.detail);

  final String path;
  final String content;
  final String detail;
}

class _Move {
  const _Move(this.from, this.to);

  final String from;
  final String to;
}

String _resolve(Directory root, String relative) =>
    root.uri.resolve(relative).toFilePath();

Future<String> _read(Directory root, String relative) async {
  final file = File(_resolve(root, relative));
  return file.existsSync() ? file.readAsString() : '';
}

String _firstGroup(RegExp pattern, String text) =>
    pattern.firstMatch(text)?.group(1) ?? '';

/// Lists files under [dirs] whose project-relative path satisfies [keep].
/// Skips build output, tool caches and git metadata.
Future<List<String>> _filesUnder(
  Directory root,
  List<String> dirs,
  bool Function(String relative) keep,
) async {
  final base = Directory(root.path).absolute.path;
  final prefix = base.endsWith(Platform.pathSeparator)
      ? base
      : '$base${Platform.pathSeparator}';
  final found = <String>[];
  for (final dir in dirs) {
    final directory = Directory(_resolve(root, dir));
    if (!directory.existsSync()) {
      continue;
    }
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }
      final relative = entity.path
          .substring(prefix.length)
          .replaceAll(Platform.pathSeparator, '/');
      if (relative.split('/').any(_ignoredDirs.contains)) {
        continue;
      }
      if (keep(relative)) {
        found.add(relative);
      }
    }
  }
  found.sort();
  return found;
}

/// Removes now-empty folders above a moved Kotlin file, up to the Kotlin source root.
void _pruneEmptyKotlinDirs(Directory root, String movedFrom) {
  var relative = movedFrom.substring(0, movedFrom.lastIndexOf('/'));
  while (relative.startsWith('$_kotlinRoot/')) {
    final directory = Directory(_resolve(root, relative));
    if (!directory.existsSync() || directory.listSync().isNotEmpty) {
      return;
    }
    directory.deleteSync();
    relative = relative.substring(0, relative.lastIndexOf('/'));
  }
}
