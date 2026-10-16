import 'package:riverpod_core/core/permissions/app_permission.dart';

/// Translation keys of the permission rationale dialog (D-023). Values live in
/// `assets/translations/{ar,en}.json` under `ds_permissions`.
const permissionAllowKey = 'ds_permissions.allow';
const permissionOpenSettingsKey = 'ds_permissions.openSettings';
const permissionNotNowKey = 'ds_permissions.notNow';
const permissionSettingsHintKey = 'ds_permissions.settingsHint';

/// Title key of [permission], e.g. `ds_permissions.cameraTitle`.
String permissionTitleKey(AppPermission permission) =>
    'ds_permissions.${permission.name}Title';

/// Explanation key of [permission], e.g. `ds_permissions.cameraMessage`.
String permissionMessageKey(AppPermission permission) =>
    'ds_permissions.${permission.name}Message';
