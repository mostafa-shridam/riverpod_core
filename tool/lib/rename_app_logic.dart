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
    this.host,
  });

  /// Display name, e.g. "My App".
  final String name;

  /// Reverse-DNS application id, e.g. com.company.myapp.
  final String id;

  /// Dart package name, snake_case, e.g. my_app.
  final String package;

  /// Host of the https app links, e.g. links.company.com. Null keeps the
  /// placeholder host (ai-docs/DEEP_LINKS.md).
  final String? host;

  /// URL scheme of the app: the package with `_` as `-` (a scheme cannot
  /// contain an underscore).
  String get scheme => package.replaceAll('_', '-');
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
final _hostPattern = RegExp(
  r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$',
);

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
  if (_wellKnownSchemes.contains(request.scheme)) {
    problems.add(
      'The deep-link scheme "${request.scheme}" (from --package) is a '
      'well-known scheme the app must not claim; choose another --package.',
    );
  }
  final host = request.host;
  if (host != null && !_hostPattern.hasMatch(host)) {
    problems.add(
      '--host must be a lowercase domain name without scheme or path, e.g. '
      'links.company.com; got "$host".',
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

/// Parses `--name`, `--id`, `--package`, `--host` (each as `--x value` or `--x=value`) and `--dry-run`.
/// The package defaults to [defaultPackageName] of the name.
RenameOptions parseRenameArgs(List<String> args) {
  String? name;
  String? id;
  String? package;
  String? host;
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
    if (!const {'--name', '--id', '--package', '--host'}.contains(flag)) {
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
    } else if (flag == '--host') {
      host = value.trim();
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
    request: RenameRequest(name: name!, id: id!, package: package!, host: host),
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

// Deep links (ai-docs/DEEP_LINKS.md). The https host is only rewritten when a
// request names one; the custom scheme always follows the package.

/// Schemes the app never claims as its own and the rename never rewrites.
const _wellKnownSchemes = {'http', 'https', 'mailto', 'tel', 'sms'};

/// The deep-link `<intent-filter>`s of the manifest: a VIEW action with the
/// BROWSABLE category. `<queries>` holds `<intent>` elements, never these.
final _deepLinkFilter = RegExp(
  r'<intent-filter\b[^>]*>[\s\S]*?</intent-filter>',
);

/// `<data android:scheme="https" android:host="...">` and the custom scheme,
/// only inside the VIEW/BROWSABLE intent-filters. Everything else (`<queries>`,
/// other filters) and the well-known schemes stay as they are.
String rewriteManifestDeepLink(String content, RenameRequest request) {
  final host = request.host;
  return content.replaceAllMapped(_deepLinkFilter, (filter) {
    final block = filter[0]!;
    if (!block.contains('android.intent.action.VIEW') ||
        !block.contains('android.intent.category.BROWSABLE')) {
      return block;
    }
    var result = block.replaceAllMapped(
      RegExp(r'(android:scheme=")([^"]*)(")'),
      (m) => _wellKnownSchemes.contains(m[2])
          ? m[0]!
          : '${m[1]!}${request.scheme}${m[3]!}',
    );
    if (host != null) {
      result = result.replaceAllMapped(
        RegExp(r'(android:host=")[^"]*(")'),
        (m) => '${m[1]!}$host${m[2]!}',
      );
    }
    return result;
  });
}

/// The `CFBundleURLSchemes` entry of Info.plist.
String rewritePlistDeepLink(String content, RenameRequest request) =>
    content.replaceAllMapped(
      RegExp(
        r'(<key>CFBundleURLSchemes</key>\s*<array>\s*<string>)[^<]*(</string>)',
      ),
      (m) => '${m[1]!}${request.scheme}${m[2]!}',
    );

/// The `applinks:<host>` entry of Runner.entitlements.
String rewriteEntitlements(String content, String host) =>
    content.replaceAllMapped(
      RegExp(r'(<string>applinks:)[^<]*(</string>)'),
      (m) => '${m[1]!}$host${m[2]!}',
    );

/// The `deepLinkScheme` and (with a host) `deepLinkHost` constants.
String rewriteDeepLinkConfig(String content, RenameRequest request) {
  final result = content.replaceAllMapped(
    RegExp(r"(const deepLinkScheme = ')[^']*(')"),
    (m) => '${m[1]!}${request.scheme}${m[2]!}',
  );
  final host = request.host;
  return host == null
      ? result
      : result.replaceAllMapped(
          RegExp(r"(const deepLinkHost = ')[^']*(')"),
          (m) => '${m[1]!}$host${m[2]!}',
        );
}

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

/// Dotenv file (`KEY=value`, see D-024): sets `APP_NAME` and leaves other lines alone.
String rewriteEnvFile(String content, String name) => content.replaceFirst(
  RegExp(r'^APP_NAME=.*$', multiLine: true),
  'APP_NAME=$name',
);

/// Rewrites `package:<from>/` to `package:<to>/`, then re-sorts the directives.
/// A new package name can change the alphabetical order of an import block,
/// and `directives_ordering` rejects an unsorted block.
String rewriteDartImports(
  String content, {
  required String from,
  required String to,
}) {
  final rewritten = content.replaceAll('package:$from/', 'package:$to/');
  return rewritten == content ? content : sortDirectives(rewritten);
}

final _directiveStart = RegExp(r"^(import|export) '([^']+)'");

/// One import or export statement and the comment lines directly above it.
class _Directive {
  _Directive(this.keyword, this.uri, this.lines)
    : kind = keyword == 'import' ? 0 : 1,
      rank = uri.startsWith('dart:')
          ? 0
          : uri.startsWith('package:')
          ? 1
          : 2;

  final String keyword;
  final String uri;
  final List<String> lines;

  /// Imports before exports; then `dart:`, `package:`, relative.
  final int kind;
  final int rank;

  int compareTo(_Directive other) {
    final byKind = kind.compareTo(other.kind);
    if (byKind != 0) {
      return byKind;
    }
    final byRank = rank.compareTo(other.rank);
    return byRank != 0 ? byRank : uri.compareTo(other.uri);
  }
}

/// Sorts the import and export block the way `directives_ordering` expects.
///
/// The directives are sorted by kind (imports, then exports), rank (`dart:`,
/// `package:`, relative) and URI, with one blank line between kind/rank groups.
/// Blank lines inside the block are dropped; comments above a directive move
/// with it. Renaming `package:riverpod_core/...` to `package:demo_app/...` thus
/// moves the project imports to their alphabetical place among the other packages.
/// A block that is not plain directives and comments (for example a `part`
/// line inside it) is returned unchanged. Idempotent.
String sortDirectives(String content) {
  final lines = content.split('\n');
  final firstIndex = lines.indexWhere((l) => _directiveStart.hasMatch(l));
  if (firstIndex == -1) {
    return content;
  }
  var start = firstIndex;
  while (start > 0 && lines[start - 1].trimLeft().startsWith('//')) {
    start--;
  }

  final sections = <List<_Directive>>[];
  var section = <_Directive>[];
  var pending = <String>[];
  var end = -1;
  var i = start;
  while (i < lines.length) {
    final line = lines[i];
    final match = _directiveStart.firstMatch(line);
    if (match != null) {
      final statement = [...pending, line];
      pending = [];
      var j = i;
      while (!lines[j].trimRight().endsWith(';')) {
        j++;
        if (j >= lines.length) {
          return content;
        }
        statement.add(lines[j]);
      }
      section.add(_Directive(match.group(1)!, match.group(2)!, statement));
      end = j;
      i = j + 1;
      continue;
    }
    if (line.trim().isEmpty) {
      if (pending.isNotEmpty) {
        return content;
      }
      if (section.isNotEmpty) {
        sections.add(section);
        section = <_Directive>[];
      }
      i++;
      continue;
    }
    if (line.trimLeft().startsWith('//')) {
      pending.add(line);
      i++;
      continue;
    }
    break;
  }
  if (section.isNotEmpty) {
    sections.add(section);
  }
  if (end == -1) {
    return content;
  }

  // One alphabetical list for all directives. The lint reads every `package:`
  // import as a single sequence, so a project section cannot sit between others.
  final ordered = [for (final section in sections) ...section]
    ..sort((a, b) => a.compareTo(b));
  final rebuilt = <String>[];
  _Directive? previous;
  for (final directive in ordered) {
    if (previous != null &&
        (previous.kind != directive.kind || previous.rank != directive.rank)) {
      rebuilt.add('');
    }
    rebuilt.addAll(directive.lines);
    previous = directive;
  }
  return [
    ...lines.sublist(0, start),
    ...rebuilt,
    ...lines.sublist(end + 1),
  ].join('\n');
}

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
      oldName == request.name &&
      request.host == null) {
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
    (c) => rewriteManifestDeepLink(rewriteManifest(c, request.name), request),
    'android:label, deep-link scheme and host',
  );
  await rewrite(
    'ios/Runner/Info.plist',
    (c) => rewritePlistDeepLink(rewritePlist(c, request), request),
    'CFBundleDisplayName, CFBundleName, URL scheme',
  );
  final host = request.host;
  if (host != null) {
    await rewrite(
      'ios/Runner/Runner.entitlements',
      (c) => rewriteEntitlements(c, host),
      'associated domain',
    );
  }
  await rewrite(
    'lib/core/router/deep_link.dart',
    (c) => rewriteDeepLinkConfig(c, request),
    'deepLinkScheme, deepLinkHost',
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
  ], (p) => p.endsWith('.env') || p.endsWith('.env.example'))) {
    await rewrite(path, (c) => rewriteEnvFile(c, request.name), 'APP_NAME');
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
