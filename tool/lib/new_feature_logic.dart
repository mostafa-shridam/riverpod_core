import 'dart:convert';
import 'dart:io';

// Pure scaffold logic behind `tool/new_feature.dart`. It lives in tool/, outside
// lib/, so the app never ships it. The template files live in
// `.fttemplates/feature`; [newFeature] renders them into a project tree.

/// The spellings of one feature name, e.g. `product_orders`.
class FeatureName {
  const FeatureName({
    required this.snake,
    required this.pascal,
    required this.camel,
    required this.kebab,
    required this.title,
  });

  /// `product_orders`: folders, files, the prefix of every file.
  final String snake;

  /// `ProductOrders`: class names.
  final String pascal;

  /// `productOrders`: provider functions and the translation group.
  final String camel;

  /// `product-orders`: the route name and the endpoint path.
  final String kebab;

  /// `Product Orders`: the English title text.
  final String title;
}

/// What the command line asked for.
class NewFeatureOptions {
  const NewFeatureOptions({required this.name, required this.dryRun});

  final String name;
  final bool dryRun;
}

/// One file the scaffold writes. [path] is relative to the project root.
class FeatureFile {
  const FeatureFile({required this.path, required this.content});

  final String path;
  final String content;
}

/// Everything [newFeature] did, or would do with `dryRun`.
class FeatureScaffold {
  const FeatureScaffold({
    required this.name,
    required this.files,
    required this.translationFiles,
    required this.translationGroup,
    required this.routeSnippet,
    required this.nextSteps,
  });

  final FeatureName name;

  /// New files (code and tests), sorted by path.
  final List<FeatureFile> files;

  /// The translation JSON files that gain the feature's key group.
  final List<String> translationFiles;

  /// The key group added to every translation file, e.g. `productOrders`.
  final String translationGroup;

  /// The typed route to paste into `lib/core/router/routes.dart`.
  final String routeSnippet;

  /// Commands to run after the scaffold, in order.
  final List<String> nextSteps;
}

/// Thrown for an invalid name, a missing project or template, or an existing
/// feature. Nothing is written when it is thrown.
class NewFeatureException implements Exception {
  const NewFeatureException(this.problems);

  final List<String> problems;

  @override
  String toString() => problems.join('\n');
}

/// Folder of the template, relative to the project root.
const templatePath = '.fttemplates/feature';

/// Translation files that receive the key group, relative to the project root.
const translationPaths = [
  'assets/translations/ar.json',
  'assets/translations/en.json',
];

/// The generation commands of `build.sh`, run after the scaffold.
const nextStepCommands = [
  'dart run easy_localization:generate --source-dir assets/translations',
  'dart run easy_localization:generate -S assets/translations -f keys '
      '-o locale_keys.g.dart',
  'dart run build_runner build --delete-conflicting-outputs',
  'dart format lib test',
];

// Segments start with a letter so that camelCase and PascalCase stay valid
// Dart identifiers.
final _namePattern = RegExp(r'^[a-z][a-z0-9]*(_[a-z][a-z0-9]*)*$');

const _maxNameLength = 40;

// Names that would shadow a core folder or a Dart keyword used as a path.
const _reservedNames = {
  'core',
  'shared',
  'generated',
  'features',
  'class',
  'enum',
  'extension',
  'import',
  'library',
  'mixin',
  'part',
  'test',
  'default',
  'new',
  'null',
  'true',
  'false',
};

/// Returns every problem with [name]; empty when it is valid.
List<String> validateFeatureName(String name) {
  final problems = <String>[];
  if (name.isEmpty) {
    problems.add('--name is required (snake_case, e.g. product_orders).');
  } else if (!_namePattern.hasMatch(name)) {
    problems.add(
      '--name must be snake_case: lowercase letters and digits, words '
      'separated by single underscores, each word starting with a letter '
      '(e.g. product_orders); got "$name".',
    );
  } else if (name.length > _maxNameLength) {
    problems.add('--name must be at most $_maxNameLength characters.');
  } else if (_reservedNames.contains(name)) {
    problems.add('--name "$name" is reserved; pick another name.');
  }
  return problems;
}

/// Builds every spelling of a valid snake_case [name].
/// Throws [NewFeatureException] when [name] is not valid.
FeatureName featureNameOf(String name) {
  final problems = validateFeatureName(name);
  if (problems.isNotEmpty) {
    throw NewFeatureException(problems);
  }
  final words = name.split('_');
  String capital(String word) => word[0].toUpperCase() + word.substring(1);
  return FeatureName(
    snake: name,
    pascal: words.map(capital).join(),
    camel: words.first + words.skip(1).map(capital).join(),
    kebab: words.join('-'),
    title: words.map(capital).join(' '),
  );
}

/// Parses `--name` (as `--name value` or `--name=value`) and `--dry-run`.
NewFeatureOptions parseNewFeatureArgs(List<String> args) {
  String? name;
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
    if (flag != '--name') {
      problems.add('Unknown option "$arg".');
      continue;
    }
    if (equals != -1) {
      name = arg.substring(equals + 1).trim();
    } else if (i + 1 < args.length) {
      name = args[++i].trim();
    } else {
      problems.add('--name needs a value.');
    }
  }

  if (name == null || name.isEmpty) {
    problems.add('--name is required (snake_case, e.g. product_orders).');
  } else {
    problems.addAll(validateFeatureName(name));
  }
  if (problems.isNotEmpty) {
    throw NewFeatureException(problems);
  }
  return NewFeatureOptions(name: name!, dryRun: dryRun);
}

/// Replaces every `{{placeholder}}` of [content] with its value for [name].
String renderTemplate(String content, FeatureName name, String package) {
  final values = {
    'name': name.snake,
    'Name': name.pascal,
    'nameCamel': name.camel,
    'nameKebab': name.kebab,
    'Title': name.title,
    'package': package,
  };
  return content.replaceAllMapped(
    RegExp(r'\{\{(\w+)\}\}'),
    (m) => values[m[1]] ?? m[0]!,
  );
}

/// Replaces the `__name__` marker of a template path.
String renderPath(String path, FeatureName name) =>
    path.replaceAll('__name__', name.snake);

/// Adds [group] (a map of key to text) at the end of the translation JSON
/// [source], in the format the repo uses (two spaces, final newline).
/// Throws [NewFeatureException] when the key group already exists.
String addTranslationGroup(
  String source,
  String groupName,
  Map<String, dynamic> group,
) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  if (json.containsKey(groupName)) {
    throw NewFeatureException([
      'The translation key group "$groupName" already exists.',
    ]);
  }
  json[groupName] = group;
  return '${const JsonEncoder.withIndent('  ').convert(json)}\n';
}

/// Creates the feature [rawName] in the project at [root], from the template
/// in [templateRoot] (default `<root>/.fttemplates/feature`). With [dryRun]
/// nothing is written; the returned plan is the same.
///
/// Never edits `routes.dart`: the typed route comes back as a snippet.
/// Throws [NewFeatureException] for an invalid name, a directory that is not
/// a project root, a missing template, or a feature that already exists.
Future<FeatureScaffold> newFeature({
  required Directory root,
  required String rawName,
  Directory? templateRoot,
  bool dryRun = false,
}) async {
  final name = featureNameOf(rawName);
  final pubspec = File(_resolve(root, 'pubspec.yaml'));
  if (!pubspec.existsSync()) {
    throw NewFeatureException([
      'No pubspec.yaml in ${root.path}; run the script from the project root.',
    ]);
  }
  final package = RegExp(
    r'^name: (\S+)$',
    multiLine: true,
  ).firstMatch(await pubspec.readAsString())?.group(1);
  if (package == null) {
    throw const NewFeatureException(['pubspec.yaml has no "name:" line.']);
  }
  final template = templateRoot ?? Directory(_resolve(root, templatePath));
  if (!template.existsSync()) {
    throw NewFeatureException([
      'Template folder ${template.path} not found; '
          'it must contain the .fttemplates/feature files.',
    ]);
  }

  final files = <FeatureFile>[];
  for (final top in const ['lib', 'test']) {
    final dir = Directory('${template.path}/$top');
    if (!dir.existsSync()) {
      continue;
    }
    await for (final entity in dir.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.tmpl')) {
        continue;
      }
      var relative = entity.path.substring(template.path.length + 1);
      relative = relative.substring(0, relative.length - '.tmpl'.length);
      files.add(
        FeatureFile(
          path: renderPath(relative, name),
          content: renderTemplate(await entity.readAsString(), name, package),
        ),
      );
    }
  }
  if (files.isEmpty) {
    throw NewFeatureException(['No template files found in ${template.path}.']);
  }
  files.sort((a, b) => a.path.compareTo(b.path));

  // Refuse before anything is written.
  final problems = <String>[];
  for (final dir in [
    'lib/features/${name.snake}',
    'test/features/${name.snake}',
  ]) {
    if (Directory(_resolve(root, dir)).existsSync()) {
      problems.add('$dir already exists; refusing to overwrite a feature.');
    }
  }
  final translations = <String, String>{};
  for (final path in translationPaths) {
    final file = File(_resolve(root, path));
    if (!file.existsSync()) {
      problems.add('$path not found.');
      continue;
    }
    final lang = path.split('/').last.replaceAll('.json', '');
    final group =
        jsonDecode(
              await File('${template.path}/translations/$lang.json.tmpl')
                  .readAsString()
                  .then((text) => renderTemplate(text, name, package)),
            )
            as Map<String, dynamic>;
    try {
      translations[path] = addTranslationGroup(
        await file.readAsString(),
        name.camel,
        group,
      );
    } on NewFeatureException catch (error) {
      problems.addAll(error.problems.map((p) => '$path: $p'));
    }
  }
  if (problems.isNotEmpty) {
    throw NewFeatureException(problems);
  }

  final snippet = renderTemplate(
    await File('${template.path}/routes_snippet.txt.tmpl').readAsString(),
    name,
    package,
  );

  if (!dryRun) {
    for (final file in files) {
      final target = File(_resolve(root, file.path));
      target.parent.createSync(recursive: true);
      await target.writeAsString(file.content);
    }
    for (final entry in translations.entries) {
      await File(_resolve(root, entry.key)).writeAsString(entry.value);
    }
  }

  return FeatureScaffold(
    name: name,
    files: files,
    translationFiles: translationPaths,
    translationGroup: name.camel,
    routeSnippet: snippet,
    nextSteps: nextStepCommands,
  );
}

String _resolve(Directory root, String relative) => '${root.path}/$relative';
