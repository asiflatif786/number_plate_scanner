import 'package:flutter/foundation.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';

class SplashViewModel extends ChangeNotifier {
  static const String _tag = 'SplashVM';

  bool _isLoading = true;
  String? _routeDecision;

  bool get isLoading => _isLoading;
  String? get routeDecision => _routeDecision;

  Future<void> checkSession() async {
    AppLogger.logInfo(_tag, 'Session check started');

    try {
      final session = await SessionManager.instance;
      final valid = session.hasValidSession();

      if (valid) {
        final role = session.userRole;
        if (role == 'Admin') {
          _routeDecision = '/admin-dashboard';
          AppLogger.logInfo(_tag, 'Valid session — Admin → /admin-dashboard');
        } else {
          _routeDecision = '/agent-dashboard';
          AppLogger.logInfo(_tag, 'Valid session — Agent → /agent-dashboard');
        }
      } else {
        _routeDecision = '/login';
        AppLogger.logInfo(_tag, 'No valid session → /login');
      }
    } catch (e) {
      _routeDecision = '/login';
      AppLogger.logWarning(_tag, 'Session check failed → /login (${e.toString()})');
    }

    _isLoading = false;
    notifyListeners();
  }
}
