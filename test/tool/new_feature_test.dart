import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The logic lives in tool/lib, outside lib/, so it cannot be imported as a package.
// ignore: always_use_package_imports, avoid_relative_lib_imports
import '../../tool/lib/new_feature_logic.dart';

// The real template, rendered into a temporary project.
final _template = Directory('.fttemplates/feature').absolute;

const _enJson = '{\n  "hello": "Hello"\n}\n';
const _arJson = '{\n  "hello": "مرحبا"\n}\n';

const _expectedFiles = [
  'lib/features/product_orders/data/models/product_orders_item.dart',
  'lib/features/product_orders/data/product_orders_repository.dart',
  'lib/features/product_orders/data/sources/product_orders_remote_source.dart',
  'lib/features/product_orders/presentation/pages/product_orders_page.dart',
  'lib/features/product_orders/presentation/widgets/product_orders_item_tile.dart',
  'lib/features/product_orders/providers/product_orders_controller.dart',
  'test/features/product_orders/data/product_orders_repository_test.dart',
  'test/features/product_orders/presentation/pages/product_orders_page_test.dart',
  'test/features/product_orders/product_orders_test_support.dart',
  'test/features/product_orders/providers/product_orders_controller_test.dart',
];

/// A minimal project: pubspec, both translation files, an empty features folder.
Directory _project(Directory temp) {
  final root = Directory('${temp.path}/app')..createSync();
  File('${root.path}/pubspec.yaml').writeAsStringSync('name: demo_app\n');
  Directory('${root.path}/assets/translations').createSync(recursive: true);
  File('${root.path}/assets/translations/en.json').writeAsStringSync(_enJson);
  File('${root.path}/assets/translations/ar.json').writeAsStringSync(_arJson);
  Directory('${root.path}/lib/features').createSync(recursive: true);
  return root;
}

/// Every file under [root], relative and sorted.
List<String> _tree(Directory root) {
  final base = root.absolute.path;
  return [
    for (final entity in root.listSync(recursive: true))
      if (entity is File) entity.path.substring(base.length + 1),
  ]..sort();
}

Future<FeatureScaffold> _run(
  Directory root, {
  String name = 'product_orders',
  bool dryRun = false,
}) => newFeature(
  root: root,
  rawName: name,
  templateRoot: _template,
  dryRun: dryRun,
);

void main() {
  late Directory root;

  setUp(() {
    final temp = Directory.systemTemp.createTempSync('new_feature_test_');
    addTearDown(() => temp.deleteSync(recursive: true));
    root = _project(temp);
  });

  group('name casing', () {
    test('builds every spelling of a snake_case name', () {
      final name = featureNameOf('product_orders');
      expect(name.snake, 'product_orders');
      expect(name.pascal, 'ProductOrders');
      expect(name.camel, 'productOrders');
      expect(name.kebab, 'product-orders');
      expect(name.title, 'Product Orders');
    });

    test('one word and digits', () {
      final one = featureNameOf('videos');
      expect(
        [one.pascal, one.camel, one.kebab],
        ['Videos', 'videos', 'videos'],
      );
      final digits = featureNameOf('web3_wallet');
      expect(
        [digits.pascal, digits.camel, digits.kebab],
        ['Web3Wallet', 'web3Wallet', 'web3-wallet'],
      );
    });

    test('invalid names are rejected', () {
      for (final bad in [
        '',
        'ProductOrders',
        'product-orders',
        'product orders',
        'product__orders',
        '_orders',
        'orders_',
        '1orders',
        'orders_2',
        'ordérs',
        'core',
        'class',
        'a' * 41,
      ]) {
        expect(validateFeatureName(bad), isNotEmpty, reason: '"$bad"');
        expect(() => featureNameOf(bad), throwsA(isA<NewFeatureException>()));
      }
    });
  });

  group('arguments', () {
    test('parses --name in both forms and --dry-run', () {
      final a = parseNewFeatureArgs(['--name', 'orders']);
      expect([a.name, a.dryRun], ['orders', false]);
      final b = parseNewFeatureArgs(['--dry-run', '--name=orders']);
      expect([b.name, b.dryRun], ['orders', true]);
    });

    test('reports a missing, invalid or unknown option', () {
      for (final args in [
        <String>[],
        ['--name'],
        ['--name', 'Bad Name'],
        ['--name', 'orders', '--force'],
        ['orders'],
      ]) {
        expect(
          () => parseNewFeatureArgs(args),
          throwsA(isA<NewFeatureException>()),
          reason: '$args',
        );
      }
    });
  });

  group('rendering', () {
    test('replaces every placeholder and leaves unknown ones', () {
      final name = featureNameOf('product_orders');
      expect(
        renderTemplate(
          '{{name}} {{Name}} {{nameCamel}} {{nameKebab}} {{Title}} '
              '{{package}} {{other}} _\${{Name}}Item',
          name,
          'demo_app',
        ),
        'product_orders ProductOrders productOrders product-orders '
        'Product Orders demo_app {{other}} _\$ProductOrdersItem',
      );
    });

    test('renders the file name marker', () {
      final name = featureNameOf('product_orders');
      expect(
        renderPath('lib/features/__name__/data/__name___item.dart', name),
        'lib/features/product_orders/data/product_orders_item.dart',
      );
    });

    test('adds a translation group in the repo JSON format', () {
      final out = addTranslationGroup(_enJson, 'orders', {'title': 'Orders'});
      expect(
        out,
        '{\n  "hello": "Hello",\n  "orders": {\n    "title": "Orders"\n  }\n}\n',
      );
      expect(
        () => addTranslationGroup(out, 'orders', {'title': 'x'}),
        throwsA(isA<NewFeatureException>()),
      );
    });
  });

  group('file plan', () {
    test('lists the documented tree with the package from pubspec', () async {
      final scaffold = await _run(root, dryRun: true);
      expect(scaffold.files.map((f) => f.path), _expectedFiles);
      for (final file in scaffold.files.where(
        (f) => f.path.endsWith('.dart'),
      )) {
        expect(file.content, isNot(contains('{{')), reason: file.path);
        expect(file.content, isNot(contains('riverpod_core')));
      }
      final page = scaffold.files.singleWhere(
        (f) => f.path.endsWith('_page.dart') && f.path.startsWith('lib'),
      );
      expect(
        page.content,
        contains("static const routeName = '/product-orders'"),
      );
      expect(page.content, contains('LocaleKeys.productOrders_title.tr()'));
      expect(page.content, contains('AsyncValueView<List<ProductOrdersItem>>'));
      expect(
        scaffold.routeSnippet,
        contains('@TypedGoRoute<ProductOrdersRoute>'),
      );
      expect(scaffold.routeSnippet, contains('package:demo_app/'));
      expect(scaffold.nextSteps.first, contains('easy_localization:generate'));
    });

    test('the repository reads through one fetch method', () async {
      final scaffold = await _run(root, dryRun: true);
      final repository = scaffold.files.singleWhere(
        (f) => f.path.endsWith('product_orders_repository.dart'),
      );
      expect(
        RegExp(r'Future<[^>]*>+ fetch\w+\(').allMatches(repository.content),
        hasLength(1),
      );
    });

    test('templates use LocaleKeys only, never a literal key', () async {
      final scaffold = await _run(root, dryRun: true);
      for (final file in scaffold.files) {
        expect(
          RegExp('''['"][\\w.]+['"]\\.tr\\(''').hasMatch(file.content),
          isFalse,
          reason: file.path,
        );
      }
    });
  });

  group('generation', () {
    test('writes the tree and both translation files', () async {
      final scaffold = await _run(root);

      expect(
        _tree(root).where((p) => p.startsWith('lib/') || p.startsWith('test/')),
        _expectedFiles,
      );
      for (final file in scaffold.files) {
        expect(
          File('${root.path}/${file.path}').readAsStringSync(),
          file.content,
        );
      }
      for (final lang in ['ar', 'en']) {
        final json =
            jsonDecode(
                  File(
                    '${root.path}/assets/translations/$lang.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        expect(json['hello'], isNotNull);
        final group = json['productOrders'] as Map<String, dynamic>;
        expect(group.keys, ['title', 'emptyTitle', 'emptyMessage']);
        expect(group.values.every((v) => (v as String).isNotEmpty), isTrue);
      }
      final en =
          jsonDecode(
                File(
                  '${root.path}/assets/translations/en.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      expect(
        (en['productOrders'] as Map<String, dynamic>)['title'],
        'Product Orders',
      );
    });

    test('--dry-run writes nothing', () async {
      final before = _tree(root);
      await _run(root, dryRun: true);
      expect(_tree(root), before);
      expect(
        File('${root.path}/assets/translations/en.json').readAsStringSync(),
        _enJson,
      );
    });

    test('never touches routes.dart', () async {
      final routes = File('${root.path}/lib/core/router/routes.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('// routes\n');
      await _run(root);
      expect(routes.readAsStringSync(), '// routes\n');
    });
  });

  group('refusals', () {
    test('an existing feature is refused and nothing changes', () async {
      await _run(root);
      final before = {
        for (final path in _tree(root))
          path: File('${root.path}/$path').readAsStringSync(),
      };

      await expectLater(
        _run(root),
        throwsA(
          isA<NewFeatureException>().having(
            (e) => e.toString(),
            'message',
            contains('already exists'),
          ),
        ),
      );
      expect({
        for (final path in _tree(root))
          path: File('${root.path}/$path').readAsStringSync(),
      }, before);
    });

    test('an existing test folder is refused', () async {
      Directory(
        '${root.path}/test/features/product_orders',
      ).createSync(recursive: true);
      await expectLater(_run(root), throwsA(isA<NewFeatureException>()));
      expect(
        Directory('${root.path}/lib/features/product_orders').existsSync(),
        isFalse,
      );
    });

    test('an existing translation group is refused', () async {
      File(
        '${root.path}/assets/translations/en.json',
      ).writeAsStringSync('{"productOrders": {"title": "x"}}');
      await expectLater(_run(root), throwsA(isA<NewFeatureException>()));
      expect(
        Directory('${root.path}/lib/features/product_orders').existsSync(),
        isFalse,
      );
    });

    test('an invalid name is refused', () async {
      await expectLater(
        _run(root, name: 'Product-Orders'),
        throwsA(isA<NewFeatureException>()),
      );
    });

    test('a folder without pubspec.yaml is refused', () async {
      File('${root.path}/pubspec.yaml').deleteSync();
      await expectLater(_run(root), throwsA(isA<NewFeatureException>()));
    });

    test('a missing template is refused', () async {
      await expectLater(
        newFeature(root: root, rawName: 'orders'),
        throwsA(isA<NewFeatureException>()),
      );
    });
  });
}
