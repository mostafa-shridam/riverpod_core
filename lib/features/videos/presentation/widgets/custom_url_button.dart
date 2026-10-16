import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_icon_button.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_input_dialog.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/videos/data/videos_repository.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// App bar action: paste any MP4 or HLS link and play it on the detail page.
class CustomUrlButton extends ConsumerWidget {
  const CustomUrlButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppIconButton(
      icon: Icons.add_link_rounded,
      tooltip: LocaleKeys.videos_customUrl_tooltip.tr(),
      onPressed: () async {
        final repository = ref.read(videosRepositoryProvider);
        final link = await AppInputDialog.show(
          context: context,
          title: LocaleKeys.videos_customUrl_title.tr(),
          message: LocaleKeys.videos_customUrl_message.tr(),
          label: LocaleKeys.videos_customUrl_label.tr(),
          hint: LocaleKeys.videos_customUrl_hint.tr(),
          confirmLabel: LocaleKeys.videos_customUrl_play.tr(),
          keyboardType: TextInputType.url,
          validator: (value) {
            try {
              repository.customVideo(value);
              return null;
            } on ValidationException {
              return LocaleKeys.videos_customUrl_invalid.tr();
            }
          },
        );
        if (link == null || !context.mounted) return;
        await VideoDetailRoute(
          id: customVideoId,
          url: link.trim(),
        ).push<void>(context);
      },
    );
  }
}
