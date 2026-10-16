import 'dart:io';

// The logic lives in tool/lib because it must not ship with the app.
// ignore: always_use_package_imports
import 'lib/new_feature_logic.dart';

const _usage = '''
Creates a feature skeleton in lib/features and test/features. Run from the
project root.

  dart run tool/new_feature.dart --name product_orders [options]

Options:
  --name <snake_case>  feature name, e.g. product_orders (required)
  --dry-run            print the plan without writing anything
  --help               show this text
''';

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.write(_usage);
    return;
  }
  try {
    final options = parseNewFeatureArgs(args);
    final scaffold = await newFeature(
      root: Directory.current,
      rawName: options.name,
      dryRun: options.dryRun,
    );
    final verb = options.dryRun ? 'Would create' : 'Created';
    stdout.writeln(
      '$verb feature "${scaffold.name.snake}" (${scaffold.files.length} '
      'files):',
    );
    for (final file in scaffold.files) {
      stdout.writeln('  ${file.path}');
    }
    final verbKeys = options.dryRun ? 'Would add' : 'Added';
    stdout.writeln(
      '$verbKeys translation group "${scaffold.translationGroup}" to:',
    );
    for (final path in scaffold.translationFiles) {
      stdout.writeln('  $path');
    }
    stdout.writeln('''

Next steps:
  1. Translate "${scaffold.translationGroup}.title" in assets/translations/ar.json
     (it holds the English title as a placeholder) and review the other texts.
  2. Register the typed route (routes.dart is never edited by this tool):

${_indent(scaffold.routeSnippet)}
  3. Generate the code and the translation keys (see build.sh), then format:
${scaffold.nextSteps.map((c) => '       $c').join('\n')}
  4. Replace the model fields and the endpoint with the real ones, then run
     flutter analyze and flutter test.''');
  } on NewFeatureException catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

String _indent(String text) => text
    .trimRight()
    .split('\n')
    .map((line) => line.isEmpty ? line : '       $line')
    .join('\n');
