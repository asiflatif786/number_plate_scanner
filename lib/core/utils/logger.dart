import 'package:flutter/foundation.dart';

class AppLogger {
  static void debug(String tag, String message) {
    debugPrint('🐛 [DEBUG] [$tag] $message');
  }

  static void info(String tag, String message) {
    debugPrint('ℹ️ [INFO] [$tag] $message');
  }

  static void success(String tag, String message) {
    debugPrint('✅ [SUCCESS] [$tag] $message');
  }

  static void warning(String tag, String message) {
    debugPrint('⚠️ [WARNING] [$tag] $message');
  }

  static void error(String tag, String message, [Object? error]) {
    debugPrint('❌ [ERROR] [$tag] $message');
    if (error != null) debugPrint('   └── $error');
  }

  static void request(String method, String url, Map<String, dynamic>? body) {
    debugPrint('🌐 [REQUEST] $method $url');
    if (body != null) debugPrint('   └── Body: $body');
  }

  static void response(String url, int statusCode, dynamic body) {
    debugPrint('📥 [RESPONSE] $url → $statusCode');
    debugPrint('   └── Body: $body');
  }
}
