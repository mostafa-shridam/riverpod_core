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
    AppStatusType.info => 'showcase.overlays.info'.tr(),
    AppStatusType.success => 'showcase.overlays.success'.tr(),
    AppStatusType.warning => 'showcase.overlays.warning'.tr(),
    AppStatusType.error => 'showcase.overlays.error'.tr(),
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
      message: 'showcase.overlays.chose'.tr(args: ['$choice']),
      type: AppStatusType.success,
    );
  }

  Future<void> _modalSheet() => showAppBottomSheet<void>(
    context: context,
    title: 'showcase.overlays.sheetTitle'.tr(),
    showCloseButton: true,
    builder: (_) => Text('showcase.overlays.sheetBody'.tr()),
  );

  Future<void> _actionSheet() async {
    final choice = await AppActionSheet.show<String>(
      context: context,
      title: 'showcase.overlays.actionTitle'.tr(),
      message: 'showcase.overlays.actionMessage'.tr(),
      actions: [
        AppSheetAction(
          label: 'showcase.overlays.share'.tr(),
          value: 'share',
          icon: Icons.share_rounded,
        ),
        AppSheetAction(
          label: 'showcase.overlays.edit'.tr(),
          value: 'edit',
          icon: Icons.edit_rounded,
        ),
        AppSheetAction(
          label: 'showcase.overlays.delete'.tr(),
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
      title: 'showcase.overlays.selectionTitle'.tr(),
      searchable: true,
      options: [
        for (var i = 1; i <= 8; i++)
          AppSelectionOption<int>(
            value: i,
            label: 'showcase.selection.option'.tr(args: ['$i']),
          ),
      ],
    );
    _result(choice);
  }

  Future<void> _formSheet() => AppFormSheet.show<void>(
    context: context,
    title: 'showcase.overlays.formTitle'.tr(),
    primaryLabel: 'showcase.overlays.save'.tr(),
    onPrimary: (sheetContext) => Navigator.of(sheetContext).pop(),
    content: (_) => AppTextField(label: 'showcase.overlays.formField'.tr()),
  );

  Future<void> _alert(AppStatusType type) => AppAlertDialog.show(
    context: context,
    type: type,
    title: _typeName(type),
    message: 'showcase.overlays.alertMessage'.tr(),
  );

  Future<void> _confirm({required bool destructive}) async {
    final ok = await AppConfirmDialog.show(
      context: context,
      title: 'showcase.overlays.confirmTitle'.tr(),
      message: 'showcase.overlays.confirmMessage'.tr(),
      isDestructive: destructive,
    );
    _result(ok ? 'showcase.overlays.confirmed'.tr() : null);
  }

  Future<void> _inputDialog() async {
    final text = await AppInputDialog.show(
      context: context,
      title: 'showcase.overlays.inputTitle'.tr(),
      message: 'showcase.overlays.inputMessage'.tr(),
      label: 'showcase.overlays.inputLabel'.tr(),
    );
    _result(text);
  }

  Future<void> _loadingOverlay() async {
    final close = AppLoadingDialog.show(
      context: context,
      message: 'showcase.overlays.loadingMessage'.tr(),
    );
    await Future<void>.delayed(_loadingTime);
    close();
  }

  void _snackbar(AppStatusType type) => showAppSnackbar(
    context,
    message: 'showcase.overlays.snackbarMessage'.tr(args: [_typeName(type)]),
    type: type,
    replaceCurrent: true,
  );

  void _toast(AppToastPosition position) => showAppToast(
    context,
    message: 'showcase.overlays.toastMessage'.tr(),
    position: position,
    replaceCurrent: true,
  );

  @override
  Widget build(BuildContext context) {
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-overlays'),
      title: 'showcase.sections.overlays'.tr(),
      children: [
        ShowcaseGroup(
          label: 'showcase.overlays.sheets'.tr(),
          children: [
            _button(
              'showcase.overlays.modalSheet'.tr(),
              _modalSheet,
              key: const ValueKey('open-modal-sheet'),
            ),
            _button(
              'showcase.overlays.actionSheet'.tr(),
              _actionSheet,
              key: const ValueKey('open-action-sheet'),
            ),
            _button(
              'showcase.overlays.selectionSheet'.tr(),
              _selectionSheet,
              key: const ValueKey('open-selection-sheet'),
            ),
            _button(
              'showcase.overlays.formSheet'.tr(),
              _formSheet,
              key: const ValueKey('open-form-sheet'),
            ),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.overlays.dialogs'.tr(),
          children: [
            for (final type in AppStatusType.values)
              _button(
                'showcase.overlays.alertType'.tr(args: [_typeName(type)]),
                () => _alert(type),
                key: ValueKey('open-alert-${type.name}'),
              ),
            _button(
              'showcase.overlays.confirm'.tr(),
              () => _confirm(destructive: false),
              key: const ValueKey('open-confirm'),
            ),
            _button(
              'showcase.overlays.confirmDestructive'.tr(),
              () => _confirm(destructive: true),
              key: const ValueKey('open-confirm-destructive'),
            ),
            _button(
              'showcase.overlays.inputDialog'.tr(),
              _inputDialog,
              key: const ValueKey('open-input-dialog'),
            ),
            _button(
              'showcase.overlays.loadingOverlay'.tr(),
              _loadingOverlay,
              key: const ValueKey('open-loading-overlay'),
            ),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.overlays.snackbars'.tr(),
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
          label: 'showcase.overlays.toasts'.tr(),
          children: [
            _button(
              'showcase.overlays.toastTop'.tr(),
              () => _toast(AppToastPosition.top),
              key: const ValueKey('open-toast-top'),
            ),
            _button(
              'showcase.overlays.toastBottom'.tr(),
              () => _toast(AppToastPosition.bottom),
              key: const ValueKey('open-toast-bottom'),
            ),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.overlays.banner'.tr(),
          children: [
            _button(
              'showcase.overlays.toggleBanner'.tr(),
              () => setState(() => _bannerVisible = !_bannerVisible),
              key: const ValueKey('toggle-banner'),
            ),
          ],
        ),
        if (_bannerVisible)
          AppBanner(
            key: const ValueKey('showcase-banner'),
            type: AppStatusType.warning,
            title: 'showcase.overlays.bannerTitle'.tr(),
            message: 'showcase.overlays.bannerMessage'.tr(),
            actionLabel: 'showcase.overlays.bannerAction'.tr(),
            onAction: () => setState(() => _bannerVisible = false),
            onDismiss: () => setState(() => _bannerVisible = false),
          ),
      ],
    );
  }
}
