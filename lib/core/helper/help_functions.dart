import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_core/core/constants.dart';
import 'package:riverpod_core/core/design_system/tokens/app_colors.dart';
import 'package:riverpod_core/core/design_system/tokens/brand_config.dart';
import 'package:riverpod_core/core/extension/theme_extenison.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';
import 'package:riverpod_core/main.dart';
import 'package:url_launcher/url_launcher.dart';

String getLanguageCodeHelper() {
  if (kIsWeb) {
    return 'en';
  }
  final deviceLocale = Platform.localeName.split('_').first;
  for (var loc in supportedLocales) {
    if (deviceLocale == loc.languageCode) {
      return deviceLocale;
    }
  }
  return 'ar';
}

void unfocusCurrent() => FocusManager.instance.primaryFocus?.unfocus();

bool dataIsNotEmpty({List<Object?>? list, String? data}) {
  if (list != null && list.isNotEmpty) {
    return true;
  }
  if (data != null && data.isNotEmpty && data != '') {
    return true;
  }
  return false;
}

double getProgressValue({required String startAt, required String endAt}) {
  final eventTime = DateTime.parse(endAt);
  final startTime = DateTime.parse(startAt);
  final now = DateTime.now();
  final totalDuration = eventTime.difference(startTime);
  if (now.isAfter(eventTime)) return 1;

  final elapsed = now.difference(startTime);
  final progress = elapsed.inSeconds / totalDuration.inSeconds;
  return progress.clamp(0.0, 1.0);
}

String formatDateTime(String date, BuildContext context, {String? format}) {
  if (date.isEmpty) return '';

  try {
    String cleanedDate = date;
    if (date.contains('.')) {
      final parts = date.split('.');
      final fractionalSeconds = parts[1];
      if (fractionalSeconds.length > 3) {
        cleanedDate = '${parts[0]}.${fractionalSeconds.substring(0, 3)}';
      }
    }

    // 2. المحاولة الأولى باستخدام DateTime.tryParse
    DateTime? parsedDate = DateTime.tryParse(cleanedDate);

    parsedDate ??= DateTime.tryParse(date.substring(0, 19));

    if (parsedDate == null) {
      log('Failed to parse date after cleaning: $date');
      return '';
    }

    return DateFormat(
      format ?? atDateFormat,
      context.locale.languageCode,
    ).format(parsedDate);
  } catch (e) {
    log('Error in formatDateTime: $e');
    return '';
  }
}

void showSnackBar({
  required String message,
  SnackBarType type = SnackBarType.info,
  double? width,
}) {
  IconData? icon;
  Color? color;
  switch (type) {
    case SnackBarType.info:
      icon = Icons.info;
      color = AppSemanticColors.light.warning;
      break;
    case SnackBarType.success:
      icon = Icons.check_circle;
      color = AppSemanticColors.light.success;
      break;
    case SnackBarType.error:
      icon = Icons.error;
      color = ColorScheme.fromSeed(seedColor: brandSeedColor).error;
      break;
  }
  width ??= kIsWeb ? 400 : width;
  final context = scaffoldMessengerKey.currentState;
  if (context == null) return;
  context.showSnackBar(
    SnackBar(
      width: width,
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            message,
            style: context.context.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 1,
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hitTestBehavior: HitTestBehavior.translucent,
    ),
  );
}

enum SnackBarType { info, success, error }

String getWelcomMessage({required String name}) {
  final now = DateTime.now();
  final hour = now.hour;
  if (hour < 12) {
    return '${LocaleKeys.goodMorning.tr()} $name';
  } else if (hour < 18) {
    return '${LocaleKeys.goodEvening.tr()} $name';
  } else {
    return '${LocaleKeys.goodEvening.tr()} $name';
  }
}

String getDateString(BuildContext context) {
  final parsedDate = DateTime.now();
  final formatted = formatDateTime(
    parsedDate.toIso8601String(),
    context,
    format: dateOnlyFormat,
  );
  return formatted;
}

Future<DateTime?> selectDate({required BuildContext context}) async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2025),
    lastDate: DateTime(2100),
  );
  if (pickedDate != null) {
    return pickedDate;
  }
  return null;
}

Future<TimeOfDay?> selectTime({required BuildContext context}) async {
  final pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (pickedTime != null) {
    return pickedTime;
  }
  return null;
}

Future<void> myLaunchURL(String url) async {
  final uri = Uri.parse(url);
  if (dataIsNotEmpty(data: url)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
