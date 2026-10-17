import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The logic lives in tool/lib, outside lib/, so it cannot be imported as a package.
// ignore: always_use_package_imports, avoid_relative_lib_imports
import '../../tool/lib/rename_app_logic.dart';

const _fixtures = 'test/tool/fixtures';

const _request = RenameRequest(
  name: 'My App',
  id: 'com.company.myapp',
  package: 'my_app',
);

// 'acme_app' sorts before 'flutter', so the renamed import block must be re-sorted.
const _acmeRequest = RenameRequest(
  name: 'Acme App',
  id: 'com.acme.app',
  package: 'acme_app',
);

/// Copies the fixture tree into [destination], dropping the `.fixture` suffix.
Future<void> _copyFixtures(Directory destination) async {
  final source = Directory(_fixtures).absolute;
  await for (final entity in source.list(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    var relative = entity.path.substring(source.path.length + 1);
    relative = relative.substring(0, relative.length - '.fixture'.length);
    final target = File('${destination.path}/$relative');
    target.parent.createSync(recursive: true);
    await target.writeAsBytes(await entity.readAsBytes());
  }
}

/// Every file in [root] mapped to its text, keyed by project-relative path.
Future<Map<String, String>> _snapshot(Directory root) async {
  final files = <String, String>{};
  final base = root.absolute;
  await for (final entity in base.list(recursive: true)) {
    if (entity is File) {
      final relative = entity.path.substring(base.path.length + 1);
      files[relative] = await entity.readAsString();
    }
  }
  return files;
}

void main() {
  late Directory project;

  setUp(() async {
    final temp = await Directory.systemTemp.createTemp('rename_app_test_');
    addTearDown(() => temp.delete(recursive: true));
    project = Directory('${temp.path}/app');
    await _copyFixtures(project);
  });

  group('renameApp on a fixture project', () {
    test('updates every target file', () async {
      await renameApp(root: project, request: _request);

      String read(String path) =>
          File('${project.path}/$path').readAsStringSync();

      expect(read('pubspec.yaml'), contains('name: my_app\n'));
      expect(read('pubspec.yaml'), contains('description: "My App"'));
      expect(read('README.md'), startsWith('# My App\n'));
      expect(
        read('android/app/build.gradle.kts'),
        allOf(
          contains('namespace = "com.company.myapp"'),
          contains('applicationId = "com.company.myapp"'),
        ),
      );
      expect(
        read('android/app/src/main/AndroidManifest.xml'),
        contains('android:label="My App"'),
      );
      expect(
        read('ios/Runner/Info.plist'),
        allOf(
          contains('<key>CFBundleDisplayName</key>\n\t<string>My App</string>'),
          contains('<key>CFBundleName</key>\n\t<string>my_app</string>'),
        ),
      );
      final pbxproj = read('ios/Runner.xcodeproj/project.pbxproj');
      expect(
        pbxproj,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.company.myapp;'),
      );
      expect(
        pbxproj,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.company.myapp.RunnerTests;'),
      );
      expect(pbxproj, isNot(contains('com.example.riverpodCore')));
      expect(read('env/dev.env.example'), startsWith('APP_NAME=My App\n'));
      expect(read('env/prod.env.example'), startsWith('APP_NAME=My App\n'));
      expect(read('env/prod.env'), startsWith('APP_NAME=My App\n'));
      expect(
        read('env/prod.env'),
        contains('API_BASE_URL=https://api.example.com'),
      );
    });

    test(
      'rewrites the deep-link scheme from the package, keeps the host',
      () async {
        await renameApp(root: project, request: _request);

        String read(String path) =>
            File('${project.path}/$path').readAsStringSync();

        final manifest = read('android/app/src/main/AndroidManifest.xml');
        expect(manifest, contains('<data android:scheme="my-app"/>'));
        expect(
          manifest,
          contains('<data android:scheme="https" android:host="example.com"/>'),
        );
        expect(
          read('ios/Runner/Info.plist'),
          contains('<string>my-app</string>'),
        );
        expect(
          read('ios/Runner/Runner.entitlements'),
          contains('applinks:example.com'),
        );
        final config = read('lib/core/router/deep_link.dart');
        expect(config, contains("const deepLinkScheme = 'my-app';"));
        expect(config, contains("const deepLinkHost = 'example.com';"));
      },
    );

    test('--host rewrites the https host in all three places', () async {
      await renameApp(
        root: project,
        request: const RenameRequest(
          name: 'My App',
          id: 'com.company.myapp',
          package: 'my_app',
          host: 'links.company.com',
        ),
      );

      String read(String path) =>
          File('${project.path}/$path').readAsStringSync();

      expect(
        read('android/app/src/main/AndroidManifest.xml'),
        contains('android:scheme="https" android:host="links.company.com"'),
      );
      expect(
        read('ios/Runner/Runner.entitlements'),
        contains('applinks:links.company.com'),
      );
      expect(
        read('lib/core/router/deep_link.dart'),
        contains("const deepLinkHost = 'links.company.com';"),
      );
    });

    test('the custom scheme never keeps an underscore', () {
      expect(_request.scheme, 'my-app');
      expect(
        const RenameRequest(
          name: 'A',
          id: 'com.a.b',
          package: 'shop_cart_app',
        ).scheme,
        'shop-cart-app',
      );
    });

    test(
      'rewrites package imports in lib, test and integration_test',
      () async {
        await renameApp(root: project, request: _request);

        expect(
          File('${project.path}/lib/main.dart').readAsStringSync(),
          contains("import 'package:my_app/src/theme.dart';"),
        );
        expect(
          File('${project.path}/test/app_smoke.dart').readAsStringSync(),
          contains("import 'package:my_app/main.dart';"),
        );
        expect(
          File('${project.path}/integration_test/flow.dart').readAsStringSync(),
          contains("import 'package:my_app/main.dart';"),
        );
      },
    );

    test(
      're-sorts import blocks when the new package changes their order',
      () async {
        await renameApp(root: project, request: _acmeRequest);

        final output = File(
          '${project.path}/lib/ordering.dart',
        ).readAsStringSync();
        expect(
          output,
          "import 'dart:async';\n"
          '\n'
          "import 'package:acme_app/main.dart';\n"
          "import 'package:acme_app/src/theme.dart';\n"
          "import 'package:flutter/material.dart';\n"
          '\n'
          "import 'helpers.dart';\n"
          '\n'
          "part 'ordering.g.dart';\n",
        );
        // Sorting an already-sorted block again changes nothing.
        expect(sortDirectives(output), output);
      },
    );

    test('moves MainActivity.kt to the folder of the new package', () async {
      final changes = await renameApp(root: project, request: _request);

      final moved = File(
        '${project.path}/android/app/src/main/kotlin/com/company/myapp/MainActivity.kt',
      );
      expect(
        moved.readAsStringSync(),
        startsWith('package com.company.myapp\n'),
      );
      expect(
        File(
          '${project.path}/android/app/src/main/kotlin/com/example/riverpod_core/MainActivity.kt',
        ).existsSync(),
        isFalse,
      );
      // Empty folders of the old package are removed; com/ stays because the new package lives under it.
      expect(
        Directory(
          '${project.path}/android/app/src/main/kotlin/com/example',
        ).existsSync(),
        isFalse,
      );
      expect(
        Directory(
          '${project.path}/android/app/src/main/kotlin/com/company/myapp',
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory('${project.path}/android/app/src/main/kotlin').existsSync(),
        isTrue,
      );
      expect(
        changes.map((c) => c.path),
        contains(
          'android/app/src/main/kotlin/com/company/myapp/MainActivity.kt',
        ),
      );
    });

    test('leaves build output and git metadata untouched', () async {
      final before = await _snapshot(project);

      await renameApp(root: project, request: _request);

      final after = await _snapshot(project);
      expect(after['build/generated.dart'], before['build/generated.dart']);
      expect(after['.git/config'], before['.git/config']);
    });

    test(
      'leaves no riverpod_core in the project outside build and git',
      () async {
        await renameApp(root: project, request: _request);

        final files = await _snapshot(project);
        final leftovers = [
          for (final entry in files.entries)
            if (!entry.key.startsWith('build/') &&
                !entry.key.startsWith('.git/') &&
                (entry.value.contains('riverpod_core') ||
                    entry.value.contains('riverpod-core')))
              entry.key,
        ];
        expect(leftovers, isEmpty);
      },
    );

    test('dry run reports the same changes and writes nothing', () async {
      final before = await _snapshot(project);

      final dryChanges = await renameApp(
        root: project,
        request: _request,
        dryRun: true,
      );

      expect(await _snapshot(project), before);
      expect(dryChanges, isNotEmpty);

      final wetChanges = await renameApp(root: project, request: _request);
      expect(
        wetChanges.map((c) => c.path).toList(),
        dryChanges.map((c) => c.path).toList(),
      );
    });

    test('a second run with the same values changes nothing', () async {
      await renameApp(root: project, request: _request);
      final afterFirst = await _snapshot(project);

      await expectLater(
        renameApp(root: project, request: _request),
        throwsA(
          isA<RenameException>().having(
            (e) => e.problems.single,
            'problem',
            contains('nothing to rename'),
          ),
        ),
      );
      expect(await _snapshot(project), afterFirst);
    });

    test('refuses to overwrite an existing MainActivity.kt', () async {
      final existing = File(
        '${project.path}/android/app/src/main/kotlin/com/company/myapp/MainActivity.kt',
      )..createSync(recursive: true);
      existing.writeAsStringSync('// keep me\n');
      final before = await _snapshot(project);

      await expectLater(
        renameApp(root: project, request: _request),
        throwsA(isA<RenameException>()),
      );
      expect(await _snapshot(project), before);
    });

    test('a directory without pubspec.yaml is rejected', () async {
      final empty = Directory('${project.parent.path}/empty')..createSync();

      await expectLater(
        renameApp(root: empty, request: _request),
        throwsA(
          isA<RenameException>().having(
            (e) => e.problems.single,
            'problem',
            contains('No pubspec.yaml'),
          ),
        ),
      );
    });
  });

  group('invalid input is rejected before anything is written', () {
    test('bad values are reported by validateRename', () {
      final cases = <RenameRequest, String>{
        const RenameRequest(name: '', id: 'com.a.b', package: 'a'): '--name',
        const RenameRequest(name: 'My "App"', id: 'com.a.b', package: 'a'):
            '--name',
        const RenameRequest(name: ' My App', id: 'com.a.b', package: 'a'):
            'start or end with a space',
        const RenameRequest(name: 'App', id: 'myapp', package: 'a'): '--id',
        const RenameRequest(name: 'App', id: 'com.Company.app', package: 'a'):
            '--id',
        const RenameRequest(
          name: 'App',
          id: 'com.company.my_app',
          package: 'a',
        ): '--id',
        const RenameRequest(name: 'App', id: 'com.1company.app', package: 'a'):
            '--id',
        const RenameRequest(name: 'App', id: 'com.a.b', package: 'My_App'):
            '--package',
        const RenameRequest(name: 'App', id: 'com.a.b', package: 'my-app'):
            '--package',
      };
      for (final entry in cases.entries) {
        expect(
          validateRename(entry.key),
          anyElement(contains(entry.value)),
          reason: '${entry.key.name} / ${entry.key.id} / ${entry.key.package}',
        );
      }
    });

    test('a bad --host is reported', () {
      for (final host in [
        'https://a.com',
        'a.com/path',
        'A.com',
        'localhost',
      ]) {
        expect(
          validateRename(
            RenameRequest(name: 'App', id: 'com.a.b', package: 'a', host: host),
          ),
          anyElement(contains('--host')),
          reason: host,
        );
      }
    });

    test('a valid request has no problems', () {
      expect(validateRename(_request), isEmpty);
    });

    test('renameApp throws and leaves the tree untouched', () async {
      final before = await _snapshot(project);

      await expectLater(
        renameApp(
          root: project,
          request: const RenameRequest(
            name: 'My App',
            id: 'myapp',
            package: 'my_app',
          ),
        ),
        throwsA(isA<RenameException>()),
      );
      expect(await _snapshot(project), before);
    });
  });

  group('parseRenameArgs', () {
    test('space-separated options, package derived from the name', () {
      final options = parseRenameArgs(const [
        '--name',
        'My App',
        '--id',
        'com.company.myapp',
      ]);

      expect(options.dryRun, isFalse);
      expect(options.request.name, 'My App');
      expect(options.request.id, 'com.company.myapp');
      expect(options.request.package, 'my_app');
    });

    test('equals-form options, explicit package, dry run', () {
      final options = parseRenameArgs(const [
        '--name=My App',
        '--id=com.company.myapp',
        '--package=shop',
        '--dry-run',
      ]);

      expect(options.dryRun, isTrue);
      expect(options.request.package, 'shop');
    });

    test('--host is parsed in both forms', () {
      expect(
        parseRenameArgs(const [
          '--name',
          'A',
          '--id',
          'com.a.b',
          '--host',
          'links.a.com',
        ]).request.host,
        'links.a.com',
      );
      expect(
        parseRenameArgs(const [
          '--name=A',
          '--id=com.a.b',
          '--host=links.a.com',
        ]).request.host,
        'links.a.com',
      );
      expect(
        parseRenameArgs(const ['--name', 'A', '--id', 'com.a.b']).request.host,
        isNull,
      );
    });

    test('missing --id, unknown options and a bare flag are rejected', () {
      expect(
        () => parseRenameArgs(const ['--name', 'My App']),
        throwsA(
          isA<RenameException>().having(
            (e) => e.problems,
            'problems',
            contains('--id is required (e.g. com.company.myapp).'),
          ),
        ),
      );
      expect(
        () => parseRenameArgs(const ['--name', 'A', '--id', 'a.b', '--oops']),
        throwsA(isA<RenameException>()),
      );
      expect(
        () => parseRenameArgs(const ['--name']),
        throwsA(isA<RenameException>()),
      );
    });

    test('a name with no ASCII letters needs an explicit --package', () {
      expect(
        () => parseRenameArgs(const ['--name', '日本', '--id', 'com.a.b']),
        throwsA(
          isA<RenameException>().having(
            (e) => e.problems.single,
            'problem',
            contains('--package is required'),
          ),
        ),
      );
    });
  });

  group('sortDirectives', () {
    test('sorts dart, package and relative groups within each run', () {
      const input =
          "import 'local.dart';\n"
          "import 'package:z/z.dart';\n"
          "import 'dart:io';\n"
          "import 'package:a/a.dart';\n";

      expect(
        sortDirectives(input),
        "import 'dart:io';\n"
        '\n'
        "import 'package:a/a.dart';\n"
        "import 'package:z/z.dart';\n"
        '\n'
        "import 'local.dart';\n",
      );
    });

    test('keeps a comment with the directive it describes', () {
      const input =
          "import 'package:z/z.dart';\n"
          '// needed for the gradient\n'
          "import 'package:a/a.dart'\n"
          '    show A;\n';

      expect(
        sortDirectives(input),
        '// needed for the gradient\n'
        "import 'package:a/a.dart'\n"
        '    show A;\n'
        "import 'package:z/z.dart';\n",
      );
    });

    test('package imports form one alphabetical list across blank lines', () {
      const input =
          "import 'package:flutter/material.dart';\n"
          '\n'
          "import 'package:demo_app/main.dart';\n"
          '\n'
          "import 'helpers.dart';\n";

      expect(
        sortDirectives(input),
        "import 'package:demo_app/main.dart';\n"
        "import 'package:flutter/material.dart';\n"
        '\n'
        "import 'helpers.dart';\n",
      );
    });

    test('a comment and multi-line show clause stay in the sorted list', () {
      const input =
          "import 'package:flutter/material.dart';\n"
          '// show: keeps the name unambiguous\n'
          "import 'package:cached/cached.dart'\n"
          '    show Cached;\n'
          "import 'package:demo_app/main.dart';\n";

      expect(
        sortDirectives(input),
        '// show: keeps the name unambiguous\n'
        "import 'package:cached/cached.dart'\n"
        '    show Cached;\n'
        "import 'package:demo_app/main.dart';\n"
        "import 'package:flutter/material.dart';\n",
      );
    });

    test('imports come before exports, and part lines end the block', () {
      const input =
          "export 'b.dart';\n"
          "export 'a.dart';\n"
          '\n'
          "import 'package:z/z.dart';\n"
          "import 'package:a/a.dart';\n"
          '\n'
          "part 'x.g.dart';\n"
          "import 'package:q/q.dart';\n";

      expect(
        sortDirectives(input),
        "import 'package:a/a.dart';\n"
        "import 'package:z/z.dart';\n"
        '\n'
        "export 'a.dart';\n"
        "export 'b.dart';\n"
        '\n'
        "part 'x.g.dart';\n"
        "import 'package:q/q.dart';\n",
      );
    });

    test('leaves unsorted code lines alone and is idempotent', () {
      const input =
          'void main() {}\n'
          "import 'package:z/z.dart';\n"
          "import 'package:a/a.dart';\n";
      final once = sortDirectives(input);

      expect(once.startsWith('void main() {}\n'), isTrue);
      expect(sortDirectives(once), once);
    });
  });

  group('defaultPackageName', () {
    test('derives snake_case from the display name', () {
      expect(defaultPackageName('My App'), 'my_app');
      expect(defaultPackageName('Café 2'), 'caf_2');
      expect(defaultPackageName('  --Shop-- '), 'shop');
    });

    test('prefixes names that start with a digit', () {
      expect(defaultPackageName('2 Fast'), 'app_2_fast');
    });

    test('returns empty when nothing usable is left', () {
      expect(defaultPackageName('日本'), '');
    });
  });
}
