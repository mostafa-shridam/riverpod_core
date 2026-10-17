import 'dart:io';

// The logic lives in tool/lib because it must not ship with the app.
// ignore: always_use_package_imports
import 'lib/rename_app_logic.dart';

const _usage = '''
Renames this template into a real app. Run from the project root.

  dart run tool/rename_app.dart --name "My App" --id com.company.myapp [options]

Options:
  --name <text>     display name, e.g. "My App" (required)
  --id <id>         reverse-DNS application id, e.g. com.company.myapp (required)
  --package <name> Dart package name, snake_case (default: derived from --name)
  --host <domain>   host of the https app links, e.g. links.company.com
                    (default: keep the placeholder example.com)
  --dry-run         print the changes without writing anything
  --help            show this text
''';

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.write(_usage);
    return;
  }
  try {
    final options = parseRenameArgs(args);
    final request = options.request;
    final changes = await renameApp(
      root: Directory.current,
      request: request,
      dryRun: options.dryRun,
    );
    final verb = options.dryRun ? 'Would change' : 'Changed';
    stdout.writeln(
      '$verb ${changes.length} file(s) for "${request.name}" '
      '(${request.id}, package ${request.package}):',
    );
    for (final change in changes) {
      stdout.writeln('  ${change.path} (${change.detail})');
    }
    if (!options.dryRun) {
      stdout.writeln('''
Next steps:
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  dart format .
  flutter analyze''');
    }
  } on RenameException catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
