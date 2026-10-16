import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/bottom_sheets/app_bottom_sheet.dart';
import 'package:riverpod_core/design_system/widgets/dialogs/overlays_strings.dart';

/// One choice of an [AppSelectionSheet].
@immutable
class AppSelectionOption<T> {
  const AppSelectionOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool enabled;
}

/// Single or multi choice list with optional search. Single choice pops as
/// soon as a row is tapped; multi choice pops from the sticky "done" button.
class AppSelectionSheet<T> extends StatefulWidget {
  const AppSelectionSheet({
    required this.options,
    super.key,
    this.selected = const [],
    this.multiSelect = false,
    this.searchable = false,
    this.searchHint,
    this.doneLabel,
    this.noResultsLabel,
  });

  final List<AppSelectionOption<T>> options;

  /// Values selected when the sheet opens.
  final List<T> selected;
  final bool multiSelect;
  final bool searchable;
  final String? searchHint;
  final String? doneLabel;
  final String? noResultsLabel;

  /// Opens the sheet; returns the chosen values (one for single choice), or
  /// null when dismissed.
  static Future<List<T>?> show<T>({
    required BuildContext context,
    required List<AppSelectionOption<T>> options,
    String? title,
    List<T> selected = const [],
    bool multiSelect = false,
    bool searchable = false,
    String? searchHint,
    String? doneLabel,
    String? noResultsLabel,
  }) {
    return showAppBottomSheet<List<T>>(
      context: context,
      title: title,
      showCloseButton: true,
      builder: (_) => AppSelectionSheet<T>(
        options: options,
        selected: selected,
        multiSelect: multiSelect,
        searchable: searchable,
        searchHint: searchHint,
        doneLabel: doneLabel,
        noResultsLabel: noResultsLabel,
      ),
    );
  }

  /// Convenience for single choice: returns the value or null.
  static Future<T?> showSingle<T>({
    required BuildContext context,
    required List<AppSelectionOption<T>> options,
    String? title,
    T? selected,
    bool searchable = false,
    String? searchHint,
    String? noResultsLabel,
  }) async {
    final result = await show<T>(
      context: context,
      options: options,
      title: title,
      selected: selected == null ? const [] : [selected],
      searchable: searchable,
      searchHint: searchHint,
      noResultsLabel: noResultsLabel,
    );
    return result == null || result.isEmpty ? null : result.first;
  }

  @override
  State<AppSelectionSheet<T>> createState() => _AppSelectionSheetState<T>();
}

class _AppSelectionSheetState<T> extends State<AppSelectionSheet<T>> {
  late final List<T> _selected = [...widget.selected];
  String _query = '';

  List<AppSelectionOption<T>> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.label.toLowerCase().contains(q))
        .toList();
  }

  void _tap(AppSelectionOption<T> option) {
    if (!widget.multiSelect) {
      Navigator.of(context).pop(<T>[option.value]);
      return;
    }
    setState(() {
      _selected.contains(option.value)
          ? _selected.remove(option.value)
          : _selected.add(option.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final visible = _visible;

    final list = visible.isEmpty
        ? Padding(
            padding: EdgeInsetsDirectional.all(tokens.spacing.xl),
            child: Center(
              child: Text(
                widget.noResultsLabel ?? noResultsKey.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        : ListView(
            shrinkWrap: true,
            children: [
              for (final option in visible)
                _OptionTile<T>(
                  option: option,
                  selected: _selected.contains(option.value),
                  multi: widget.multiSelect,
                  onTap: () => _tap(option),
                ),
            ],
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.searchable)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: tokens.spacing.sm),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: widget.searchHint ?? searchKey.tr(),
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radius.full),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        Flexible(child: list),
        if (widget.multiSelect)
          Padding(
            padding: EdgeInsetsDirectional.only(top: tokens.spacing.md),
            child: FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(kMinInteractiveDimension),
              ),
              onPressed: () => Navigator.of(context).pop(_selected),
              child: Text(widget.doneLabel ?? doneKey.tr()),
            ),
          ),
      ],
    );
  }
}

class _OptionTile<T> extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.multi,
    required this.onTap,
  });

  final AppSelectionOption<T> option;
  final bool selected;
  final bool multi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: !multi,
      child: ListTile(
        enabled: option.enabled,
        selected: selected,
        selectedTileColor: scheme.secondaryContainer,
        selectedColor: scheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
        ),
        leading: option.icon == null ? null : Icon(option.icon),
        title: Text(option.label),
        subtitle: option.subtitle == null ? null : Text(option.subtitle!),
        trailing: multi
            ? ExcludeSemantics(
                child: Checkbox(
                  value: selected,
                  onChanged: option.enabled ? (_) => onTap() : null,
                ),
              )
            : (selected ? const Icon(Icons.check_rounded) : null),
        onTap: onTap,
      ),
    );
  }
}
