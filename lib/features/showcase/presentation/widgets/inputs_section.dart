import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/inputs/app_otp_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_password_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_phone_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_search_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_text_field.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Text, password, search, OTP and phone fields in their main states.
class InputsSection extends StatelessWidget {
  const InputsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-inputs'),
      title: LocaleKeys.showcase_sections_inputs.tr(),
      children: [
        AppTextField(
          label: LocaleKeys.showcase_inputs_textLabel.tr(),
          hint: LocaleKeys.showcase_inputs_textHint.tr(),
          helper: LocaleKeys.showcase_inputs_textHelper.tr(),
          prefixIcon: const Icon(Icons.person_outline_rounded),
        ),
        AppTextField(
          label: LocaleKeys.showcase_inputs_errorLabel.tr(),
          errorText: LocaleKeys.showcase_inputs_errorText.tr(),
        ),
        AppTextField(
          label: LocaleKeys.showcase_inputs_disabledLabel.tr(),
          enabled: false,
        ),
        AppTextField(
          label: LocaleKeys.showcase_inputs_multilineLabel.tr(),
          minLines: 3,
          maxLines: 5,
          maxLength: 120,
        ),
        AppPasswordField(label: LocaleKeys.showcase_inputs_passwordLabel.tr()),
        AppSearchField(hint: LocaleKeys.showcase_inputs_searchHint.tr()),
        AppPhoneField(label: LocaleKeys.showcase_inputs_phoneLabel.tr()),
        AppOtpField(onCompleted: (_) {}),
      ],
    );
  }
}
