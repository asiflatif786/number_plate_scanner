import 'package:intl/intl.dart';

class AppLogger {
  AppLogger._();

  static final DateFormat _timestampFormat = DateFormat('HH:mm:ss.SSS');

  static String _timestamp() => _timestampFormat.format(DateTime.now());

  static void logDebug(String tag, String message) {
    _log('DEBUG', tag, message);
  }

  static void logInfo(String tag, String message) {
    _log('INFO', tag, message);
  }

  static void logWarning(String tag, String message) {
    _log('WARNING', tag, message);
  }

  static void logError(String tag, String message, [Object? error]) {
    _log('ERROR', tag, message);
    if (error != null) {
      // ignore: avoid_print
      print('${_timestamp()} [ERROR] [$tag] └── $error');
    }
  }

  static void _log(String level, String tag, String message) {
    // ignore: avoid_print
    print('${_timestamp()} [$level] [$tag] $message');
  }

  static void request(String method, String url, Map<String, dynamic>? body) {
    logInfo('HTTP', '$method $url');
    if (body != null) {
      logDebug('HTTP', 'Body: $body');
    }
  }

  static void response(String url, int statusCode, dynamic body) {
    logInfo('HTTP', '$url → $statusCode');
    logDebug('HTTP', 'Response: $body');
  }

  @Deprecated('Use logDebug instead')
  static void debug(String tag, String message) => logDebug(tag, message);

  @Deprecated('Use logInfo instead')
  static void info(String tag, String message) => logInfo(tag, message);

  @Deprecated('Use logWarning instead')
  static void warning(String tag, String message) => logWarning(tag, message);

  @Deprecated('Use logError instead')
  static void error(String tag, String message, [Object? e]) =>
      logError(tag, message, e);

  @Deprecated('Use logInfo instead')
  static void success(String tag, String message) =>
      logInfo(tag, '[SUCCESS] $message');
}
