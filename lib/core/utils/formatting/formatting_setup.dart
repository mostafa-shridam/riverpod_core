import 'package:intl/date_symbol_data_local.dart';

/// Loads `intl` date symbols for every locale. Call once in bootstrap, before
/// `runApp`, so `DateFormat` works for `ar` and `en`.
Future<void> initFormatting() => initializeDateFormatting();
