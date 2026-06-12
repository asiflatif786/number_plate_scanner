import 'dart:async';
import 'dart:io';
import '../utils/logger.dart';

class ConnectivityHelper {
  static const String _tag = 'ConnectivityHelper';

  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      final connected = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      AppLogger.info(_tag, connected ? 'Internet connected' : 'No internet connection');
      return connected;
    } on SocketException catch (e) {
      AppLogger.error(_tag, 'No internet connection', e);
      return false;
    } on TimeoutException {
      AppLogger.error(_tag, 'Connectivity check timed out');
      return false;
    }
  }
}
