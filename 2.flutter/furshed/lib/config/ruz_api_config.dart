import 'package:flutter/foundation.dart';

/// Базовый URL API ruz.fa.ru.
/// На Web / при CORS: `dart run first/flutter_application_1/server.dart`
/// и запуск с `--dart-define=USE_PROXY=true`.
class RuzApiConfig {
  static const bool useProxy =
      bool.fromEnvironment('USE_PROXY', defaultValue: false);

  static bool get shouldUseProxy => kIsWeb || useProxy;

  static String get origin =>
      shouldUseProxy ? 'http://localhost:3000' : 'https://ruz.fa.ru';

  static String searchUrl(String type, String term) =>
      '$origin/${shouldUseProxy ? 'search' : 'api/search'}?type=$type&term=${Uri.encodeQueryComponent(term)}';

  static String scheduleUrl(String type, String id, String start, String finish) =>
      '$origin/${shouldUseProxy ? 'schedule' : 'api/schedule'}/$type/$id?start=$start&finish=$finish';
}
