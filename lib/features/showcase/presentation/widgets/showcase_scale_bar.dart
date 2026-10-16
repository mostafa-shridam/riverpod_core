import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/responsive/text_scale.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_slider.dart';

/// App bar bottom with the text scale slider (0.8x to 2.0x). It only reports
/// the chosen factor; the page applies it to its body.
class ShowcaseScaleBar extends StatelessWidget implements PreferredSizeWidget {
  const ShowcaseScaleBar({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    return SizedBox(
      height: kToolbarHeight,
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: spacing.lg),
        child: Row(
          children: [
            Flexible(
              flex: 0,
              child: Text(
                'showcase.textScale'.tr(),
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: AppSlider(
                value: value,
                min: minTextScale,
                max: maxTextScale,
                divisions: 12,
                valueFormatter: (v) => '${v.toStringAsFixed(1)}x',
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
