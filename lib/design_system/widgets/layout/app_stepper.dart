import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/tokens/app_tokens.dart';
import 'package:riverpod_core/design_system/widgets/layout/layout_strings.dart';

/// One step of an [AppStepper].
class AppStep {
  const AppStep({required this.title, this.subtitle, this.content});

  final String title;
  final String? subtitle;

  /// Shown under the title while the step is current (vertical axis only).
  final Widget? content;
}

/// Progress through ordered steps. Steps before [currentStep] are completed
/// (check mark), the current one is highlighted. The stepper draws no
/// continue/back buttons: compose `AppButton`s in the step content or around
/// the stepper.
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.axis = Axis.vertical,
    this.onStepTapped,
  }) : assert(currentStep >= 0);

  final List<AppStep> steps;
  final int currentStep;
  final Axis axis;
  final ValueChanged<int>? onStepTapped;

  static const double _marker = 32;

  @override
  Widget build(BuildContext context) {
    assert(currentStep < steps.length, 'currentStep is out of range');
    return axis == Axis.vertical
        ? _buildVertical(context)
        : _buildHorizontal(context);
  }

  String _semanticLabel(int i) {
    final position = dsLayoutStepOfKey.tr(
      args: ['${i + 1}', '${steps.length}'],
    );
    final state = i < currentStep
        ? dsLayoutStepCompletedKey.tr()
        : i == currentStep
        ? dsLayoutStepCurrentKey.tr()
        : '';
    return [
      position,
      steps[i].title,
      state,
    ].where((s) => s.isNotEmpty).join(', ');
  }

  Widget _markerFor(BuildContext context, int i) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    // The marker grows with the text scale so the number never clips.
    final marker = MediaQuery.textScalerOf(context).scale(_marker);
    final done = i < currentStep;
    final current = i == currentStep;
    final background = done || current
        ? scheme.primary
        : scheme.surfaceContainerHighest;
    final foreground = done || current
        ? scheme.onPrimary
        : scheme.onSurfaceVariant;
    return AnimatedContainer(
      duration: tokens.durations.normal,
      width: marker,
      height: marker,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: current
            ? Border.all(
                color: scheme.primaryContainer,
                width: tokens.spacing.xs,
              )
            : null,
      ),
      child: done
          ? Icon(Icons.check, size: 18, color: foreground)
          : Text(
              '${i + 1}',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: foreground),
            ),
    );
  }

  TextStyle? _titleStyle(BuildContext context, int i) {
    final theme = Theme.of(context);
    return theme.textTheme.titleSmall?.copyWith(
      color: i <= currentStep
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant,
      fontWeight: i == currentStep ? FontWeight.w700 : null,
    );
  }

  Widget _buildVertical(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, step) in steps.indexed)
          Semantics(
            container: true,
            button: onStepTapped != null,
            label: _semanticLabel(i),
            excludeSemantics: true,
            onTap: onStepTapped == null ? null : () => onStepTapped!(i),
            child: InkWell(
              onTap: onStepTapped == null ? null : () => onStepTapped!(i),
              borderRadius: BorderRadius.circular(tokens.radius.md),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        _markerFor(context, i),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              width: tokens.spacing.xxs,
                              margin: EdgeInsets.symmetric(
                                vertical: tokens.spacing.xs,
                              ),
                              color: i < currentStep
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: tokens.spacing.md),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          bottom: i < steps.length - 1 ? tokens.spacing.lg : 0,
                          top: tokens.spacing.xs,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title, style: _titleStyle(context, i)),
                            if (step.subtitle != null)
                              Text(
                                step.subtitle!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            AnimatedSize(
                              duration: tokens.durations.normal,
                              curve: Curves.easeOut,
                              alignment: AlignmentDirectional.topStart,
                              child: i == currentStep && step.content != null
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                        top: tokens.spacing.md,
                                      ),
                                      child: step.content,
                                    )
                                  : const SizedBox(width: double.infinity),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, step) in steps.indexed)
          Expanded(
            child: Semantics(
              container: true,
              button: onStepTapped != null,
              label: _semanticLabel(i),
              excludeSemantics: true,
              onTap: onStepTapped == null ? null : () => onStepTapped!(i),
              child: InkWell(
                onTap: onStepTapped == null ? null : () => onStepTapped!(i),
                borderRadius: BorderRadius.circular(tokens.radius.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _line(
                            visible: i > 0,
                            active: i <= currentStep,
                            scheme: scheme,
                            tokens: tokens,
                          ),
                        ),
                        _markerFor(context, i),
                        Expanded(
                          child: _line(
                            visible: i < steps.length - 1,
                            active: i < currentStep,
                            scheme: scheme,
                            tokens: tokens,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.spacing.xs,
                      ),
                      child: Text(
                        step.title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: _titleStyle(context, i),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _line({
    required bool visible,
    required bool active,
    required ColorScheme scheme,
    required AppTokens tokens,
  }) {
    return Container(
      height: tokens.spacing.xxs,
      color: !visible
          ? Colors.transparent
          : active
          ? scheme.primary
          : scheme.outlineVariant,
    );
  }
}
