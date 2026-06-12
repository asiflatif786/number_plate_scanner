import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;

class RequestLogger {
  static String _maskApiKey(String apiKey) {
    if (apiKey.length <= 4) return '****';
    return '${apiKey.substring(0, 4)}****';
  }

  static void logRequest({
    required String method,
    required String url,
    required Map<String, String> headers,
    Map<String, dynamic>? body,
  }) {
    final maskedHeaders = <String, String>{};
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'api-key') {
        maskedHeaders[key] = _maskApiKey(value);
      } else {
        maskedHeaders[key] = value;
      }
    });

    debugPrint('┌─────────────────────────────────────');
    debugPrint('│ 🌐 REQUEST');
    debugPrint('│ Method : $method');
    debugPrint('│ URL    : $url');
    debugPrint('│ Headers: ${jsonEncode(maskedHeaders)}');
    debugPrint('│ Body   : ${body != null ? jsonEncode(body) : null}');
    debugPrint('└─────────────────────────────────────');
  }

  static void logResponse({
    required String url,
    required int statusCode,
    required dynamic body,
    required int durationMs,
  }) {
    debugPrint('┌─────────────────────────────────────');
    debugPrint('│ 📥 RESPONSE');
    debugPrint('│ URL        : $url');
    debugPrint('│ Status     : $statusCode');
    debugPrint('│ Duration   : ${durationMs}ms');
    debugPrint('│ Body       : ${jsonEncode(body)}');
    debugPrint('└─────────────────────────────────────');
  }
}
