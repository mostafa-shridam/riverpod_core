import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/inputs/app_otp_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_password_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_phone_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_search_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_text_field.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';

/// Text, password, search, OTP and phone fields in their main states.
class InputsSection extends StatelessWidget {
  const InputsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-inputs'),
      title: 'showcase.sections.inputs'.tr(),
      children: [
        AppTextField(
          label: 'showcase.inputs.textLabel'.tr(),
          hint: 'showcase.inputs.textHint'.tr(),
          helper: 'showcase.inputs.textHelper'.tr(),
          prefixIcon: const Icon(Icons.person_outline_rounded),
        ),
        AppTextField(
          label: 'showcase.inputs.errorLabel'.tr(),
          errorText: 'showcase.inputs.errorText'.tr(),
        ),
        AppTextField(
          label: 'showcase.inputs.disabledLabel'.tr(),
          enabled: false,
        ),
        AppTextField(
          label: 'showcase.inputs.multilineLabel'.tr(),
          minLines: 3,
          maxLines: 5,
          maxLength: 120,
        ),
        AppPasswordField(label: 'showcase.inputs.passwordLabel'.tr()),
        AppSearchField(hint: 'showcase.inputs.searchHint'.tr()),
        AppPhoneField(label: 'showcase.inputs.phoneLabel'.tr()),
        AppOtpField(onCompleted: (_) {}),
      ],
    );
  }
}
