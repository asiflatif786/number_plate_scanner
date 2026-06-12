import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import 'session_data.dart';
import 'session_service.dart';

class SessionProvider extends ChangeNotifier {
  static const String _tag = 'SessionProvider';
  SessionData? _sessionData;
  bool _isLoading = false;
  bool _isInitialized = false;

  SessionData? get sessionData => _sessionData;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasValidSession => _sessionData?.isValid ?? false;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final sessionService = await SessionService.getInstance();
    await sessionService.validateSession();
    await _loadSession();

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
    AppLogger.info(_tag, 'Initialized');
  }

  Future<void> _loadSession() async {
    final sessionService = await SessionService.getInstance();
    _sessionData = await sessionService.getSessionData();
    notifyListeners();
    AppLogger.debug(_tag, 'Session loaded: ${_sessionData.toString()}');
  }

  Future<void> saveSession({
    required String companyNumber,
    required String agentNumber,
    required String terminalId,
  }) async {
    final sessionService = await SessionService.getInstance();
    await sessionService.saveOnboardingData(
      companyNumber: companyNumber,
      agentNumber: agentNumber,
      terminalId: terminalId,
    );
    await _loadSession();
    AppLogger.success(_tag, 'Session saved');
  }

  Future<void> clearSession() async {
    final sessionService = await SessionService.getInstance();
    await sessionService.clearSession();
    _sessionData = null;
    notifyListeners();
    AppLogger.warning(_tag, 'Session cleared');
  }
}
