import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_action_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_bottom_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_form_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_selection_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_alert_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_confirm_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_input_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/app_loading_dialog.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/banner/app_banner.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_message.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_text_field.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_group.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// One button per overlay: sheets, dialogs, loading overlay, snackbars,
/// toasts and the banner.
class OverlaysSection extends StatefulWidget {
  const OverlaysSection({super.key});

  @override
  State<OverlaysSection> createState() => _OverlaysSectionState();
}

class _OverlaysSectionState extends State<OverlaysSection> {
  /// How long the demo loading overlay stays up.
  static const _loadingTime = Duration(seconds: 2);

  bool _bannerVisible = false;

  String _typeName(AppStatusType type) => switch (type) {
    AppStatusType.info => LocaleKeys.showcase_overlays_info.tr(),
    AppStatusType.success => LocaleKeys.showcase_overlays_success.tr(),
    AppStatusType.warning => LocaleKeys.showcase_overlays_warning.tr(),
    AppStatusType.error => LocaleKeys.showcase_overlays_error.tr(),
  };

  Widget _button(String label, VoidCallback onPressed, {Key? key}) {
    return AppButton(
      key: key,
      label: label,
      variant: AppButtonVariant.tonal,
      onPressed: onPressed,
    );
  }

  void _result(Object? choice) {
    if (!mounted || choice == null) return;
    showAppSnackbar(
      context,
      message: LocaleKeys.showcase_overlays_chose.tr(args: ['$choice']),
      type: AppStatusType.success,
    );
  }

  Future<void> _modalSheet() => showAppBottomSheet<void>(
    context: context,
    title: LocaleKeys.showcase_overlays_sheetTitle.tr(),
    showCloseButton: true,
    builder: (_) => Text(LocaleKeys.showcase_overlays_sheetBody.tr()),
  );

  Future<void> _actionSheet() async {
    final choice = await AppActionSheet.show<String>(
      context: context,
      title: LocaleKeys.showcase_overlays_actionTitle.tr(),
      message: LocaleKeys.showcase_overlays_actionMessage.tr(),
      actions: [
        AppSheetAction(
          label: LocaleKeys.showcase_overlays_share.tr(),
          value: 'share',
          icon: Icons.share_rounded,
        ),
        AppSheetAction(
          label: LocaleKeys.showcase_overlays_edit.tr(),
          value: 'edit',
          icon: Icons.edit_rounded,
        ),
        AppSheetAction(
          label: LocaleKeys.showcase_overlays_delete.tr(),
          value: 'delete',
          icon: Icons.delete_rounded,
          isDestructive: true,
        ),
      ],
    );
    _result(choice);
  }

  Future<void> _selectionSheet() async {
    final choice = await AppSelectionSheet.showSingle<int>(
      context: context,
      title: LocaleKeys.showcase_overlays_selectionTitle.tr(),
      searchable: true,
      options: [
        for (var i = 1; i <= 8; i++)
          AppSelectionOption<int>(
            value: i,
            label: LocaleKeys.showcase_selection_option.tr(args: ['$i']),
          ),
      ],
    );
    _result(choice);
  }

  Future<void> _formSheet() => AppFormSheet.show<void>(
    context: context,
    title: LocaleKeys.showcase_overlays_formTitle.tr(),
    primaryLabel: LocaleKeys.showcase_overlays_save.tr(),
    onPrimary: (sheetContext) => Navigator.of(sheetContext).pop(),
    content: (_) =>
        AppTextField(label: LocaleKeys.showcase_overlays_formField.tr()),
  );

  Future<void> _alert(AppStatusType type) => AppAlertDialog.show(
    context: context,
    type: type,
    title: _typeName(type),
    message: LocaleKeys.showcase_overlays_alertMessage.tr(),
  );

  Future<void> _confirm({required bool destructive}) async {
    final ok = await AppConfirmDialog.show(
      context: context,
      title: LocaleKeys.showcase_overlays_confirmTitle.tr(),
      message: LocaleKeys.showcase_overlays_confirmMessage.tr(),
      isDestructive: destructive,
    );
    _result(ok ? LocaleKeys.showcase_overlays_confirmed.tr() : null);
  }

  Future<void> _inputDialog() async {
    final text = await AppInputDialog.show(
      context: context,
      title: LocaleKeys.showcase_overlays_inputTitle.tr(),
      message: LocaleKeys.showcase_overlays_inputMessage.tr(),
      label: LocaleKeys.showcase_overlays_inputLabel.tr(),
    );
    _result(text);
  }

  Future<void> _loadingOverlay() async {
    final close = AppLoadingDialog.show(
      context: context,
      message: LocaleKeys.showcase_overlays_loadingMessage.tr(),
    );
    await Future<void>.delayed(_loadingTime);
    close();
  }

  void _snackbar(AppStatusType type) => showAppSnackbar(
    context,
    message: LocaleKeys.showcase_overlays_snackbarMessage.tr(
      args: [_typeName(type)],
    ),
    type: type,
    replaceCurrent: true,
  );

  void _toast(AppToastPosition position) => showAppToast(
    context,
    message: LocaleKeys.showcase_overlays_toastMessage.tr(),
    position: position,
    replaceCurrent: true,
  );

  @override
  Widget build(BuildContext context) {
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-overlays'),
      title: LocaleKeys.showcase_sections_overlays.tr(),
      children: [
        ShowcaseGroup(
          label: LocaleKeys.showcase_overlays_sheets.tr(),
          children: [
            _button(
              LocaleKeys.showcase_overlays_modalSheet.tr(),
              _modalSheet,
              key: const ValueKey('open-modal-sheet'),
            ),
            _button(
              LocaleKeys.showcase_overlays_actionSheet.tr(),
              _actionSheet,
              key: const ValueKey('open-action-sheet'),
            ),
            _button(
              LocaleKeys.showcase_overlays_selectionSheet.tr(),
              _selectionSheet,
              key: const ValueKey('open-selection-sheet'),
            ),
            _button(
              LocaleKeys.showcase_overlays_formSheet.tr(),
              _formSheet,
              key: const ValueKey('open-form-sheet'),
            ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_overlays_dialogs.tr(),
          children: [
            for (final type in AppStatusType.values)
              _button(
                LocaleKeys.showcase_overlays_alertType.tr(
                  args: [_typeName(type)],
                ),
                () => _alert(type),
                key: ValueKey('open-alert-${type.name}'),
              ),
            _button(
              LocaleKeys.showcase_overlays_confirm.tr(),
              () => _confirm(destructive: false),
              key: const ValueKey('open-confirm'),
            ),
            _button(
              LocaleKeys.showcase_overlays_confirmDestructive.tr(),
              () => _confirm(destructive: true),
              key: const ValueKey('open-confirm-destructive'),
            ),
            _button(
              LocaleKeys.showcase_overlays_inputDialog.tr(),
              _inputDialog,
              key: const ValueKey('open-input-dialog'),
            ),
            _button(
              LocaleKeys.showcase_overlays_loadingOverlay.tr(),
              _loadingOverlay,
              key: const ValueKey('open-loading-overlay'),
            ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_overlays_snackbars.tr(),
          children: [
            for (final type in AppStatusType.values)
              _button(
                _typeName(type),
                () => _snackbar(type),
                key: ValueKey('open-snackbar-${type.name}'),
              ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_overlays_toasts.tr(),
          children: [
            _button(
              LocaleKeys.showcase_overlays_toastTop.tr(),
              () => _toast(AppToastPosition.top),
              key: const ValueKey('open-toast-top'),
            ),
            _button(
              LocaleKeys.showcase_overlays_toastBottom.tr(),
              () => _toast(AppToastPosition.bottom),
              key: const ValueKey('open-toast-bottom'),
            ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_overlays_banner.tr(),
          children: [
            _button(
              LocaleKeys.showcase_overlays_toggleBanner.tr(),
              () => setState(() => _bannerVisible = !_bannerVisible),
              key: const ValueKey('toggle-banner'),
            ),
          ],
        ),
        if (_bannerVisible)
          AppBanner(
            key: const ValueKey('showcase-banner'),
            type: AppStatusType.warning,
            title: LocaleKeys.showcase_overlays_bannerTitle.tr(),
            message: LocaleKeys.showcase_overlays_bannerMessage.tr(),
            actionLabel: LocaleKeys.showcase_overlays_bannerAction.tr(),
            onAction: () => setState(() => _bannerVisible = false),
            onDismiss: () => setState(() => _bannerVisible = false),
          ),
      ],
    );
  }
}
