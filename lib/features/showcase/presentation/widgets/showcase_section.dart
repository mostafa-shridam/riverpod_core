import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_section_header.dart';

/// A titled block of the gallery: a section header and its content, with
/// token spacing between the children.
class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({
    required this.title,
    required this.children,
    super.key,
    this.sectionKey,
  });

  final String title;
  final List<Widget> children;

  /// Lets tests and the page find a section without matching its title.
  final Key? sectionKey;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(title: title),
        for (final child in children)
          Padding(
            padding: EdgeInsetsDirectional.only(top: spacing.md),
            child: child,
          ),
        SizedBox(height: spacing.xl),
      ],
    );
  }
}
