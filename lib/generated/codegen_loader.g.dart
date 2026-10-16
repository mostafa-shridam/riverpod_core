// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader {
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String, dynamic> _en = {
    "hello": "Hello",
    "arabic": "Arabic",
    "english": "English",
    "light": "Light",
    "dark": "Dark",
    "system": "System",
    "confirmButton": "Confirm",
    "cancelButton": "Cancel",
    "selectLanguage": "Select Language",
    "goodEvening": "Good Evening",
    "goodMorning": "Good Morning",
    "ds_display": {
      "imageError": "Image could not be loaded",
      "expand": "Expand",
      "collapse": "Collapse",
    },
    "ds_layout": {
      "stepOf": "Step {} of {}",
      "stepCompleted": "Completed",
      "stepCurrent": "Current step",
    },
    "ds_overlays": {
      "close": "Close",
      "cancel": "Cancel",
      "confirm": "Confirm",
      "ok": "OK",
      "done": "Done",
      "search": "Search",
      "noResults": "No results",
      "loading": "Loading",
    },
    "ds_feedback": {
      "dismiss": "Dismiss",
      "info": "Information",
      "success": "Success",
      "warning": "Warning",
      "error": "Error",
      "progress": "Progress",
    },
    "ds_buttons": {"loading": "Loading"},
    "ds_inputs": {
      "showPassword": "Show password",
      "hidePassword": "Hide password",
      "clear": "Clear",
      "searchHint": "Search",
      "otpDigitLabel": "Digit {} of {}",
      "errors": {
        "required": "This field is required",
        "invalidEmail": "Enter a valid email address",
        "passwordTooShort": "Password must be at least {} characters",
        "invalidPhone": "Enter a valid phone number",
        "phoneTooShort": "Phone number is too short",
      },
    },
    "errors": {
      "network": "No internet connection. Check your network and try again.",
      "timeout": "The request took too long. Please try again.",
      "unauthorized": "Your session has expired. Please sign in again.",
      "forbidden": "You don't have permission to do that.",
      "notFound": "We couldn't find what you were looking for.",
      "validation": "Please check the highlighted fields and try again.",
      "server": "Something went wrong on our side. Please try again later.",
      "cancelled": "The request was cancelled.",
      "unknown": "Something went wrong. Please try again.",
      "retry": "Try again",
    },
  };
  static const Map<String, dynamic> _ar = {
    "hello": "مرحبا",
    "arabic": "العربية",
    "english": "الإنجليزية",
    "light": "فاتح",
    "dark": "غامق",
    "system": "النظام",
    "confirmButton": "تأكيد",
    "cancelButton": "إلغاء",
    "selectLanguage": "اختر اللغة",
    "goodEvening": "مساء الخير",
    "goodMorning": "صباح الخير",
    "ds_display": {
      "imageError": "تعذر تحميل الصورة",
      "expand": "توسيع",
      "collapse": "طي",
    },
    "ds_layout": {
      "stepOf": "الخطوة {} من {}",
      "stepCompleted": "مكتملة",
      "stepCurrent": "الخطوة الحالية",
    },
    "ds_overlays": {
      "close": "إغلاق",
      "cancel": "إلغاء",
      "confirm": "تأكيد",
      "ok": "حسنًا",
      "done": "تم",
      "search": "بحث",
      "noResults": "لا توجد نتائج",
      "loading": "جارٍ التحميل",
    },
    "ds_feedback": {
      "dismiss": "إغلاق",
      "info": "معلومة",
      "success": "نجاح",
      "warning": "تنبيه",
      "error": "خطأ",
      "progress": "التقدم",
    },
    "ds_buttons": {"loading": "جارٍ التحميل"},
    "ds_inputs": {
      "showPassword": "إظهار كلمة المرور",
      "hidePassword": "إخفاء كلمة المرور",
      "clear": "مسح",
      "searchHint": "بحث",
      "otpDigitLabel": "الرقم {} من {}",
      "errors": {
        "required": "هذا الحقل مطلوب",
        "invalidEmail": "أدخل بريدًا إلكترونيًا صحيحًا",
        "passwordTooShort": "يجب ألا تقل كلمة المرور عن {} أحرف",
        "invalidPhone": "أدخل رقم هاتف صحيحًا",
        "phoneTooShort": "رقم الهاتف قصير جدًا",
      },
    },
    "errors": {
      "network": "لا يوجد اتصال بالإنترنت. تأكد من الشبكة وحاول مرة أخرى.",
      "timeout": "استغرق الطلب وقتًا طويلًا. حاول مرة أخرى.",
      "unauthorized": "انتهت جلستك. سجّل الدخول من جديد.",
      "forbidden": "ليست لديك صلاحية للقيام بذلك.",
      "notFound": "لم نعثر على ما تبحث عنه.",
      "validation": "راجع الحقول المحددة وحاول مرة أخرى.",
      "server": "حدث خطأ من جانبنا. حاول مرة أخرى لاحقًا.",
      "cancelled": "تم إلغاء الطلب.",
      "unknown": "حدث خطأ ما. حاول مرة أخرى.",
      "retry": "إعادة المحاولة",
    },
  };
  static const Map<String, Map<String, dynamic>> mapLocales = {
    "en": _en,
    "ar": _ar,
  };
}
