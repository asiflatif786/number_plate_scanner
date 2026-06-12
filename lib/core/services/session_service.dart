import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'session_data.dart';

class SessionService {
  static const String _tag = 'SessionService';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _firstLaunchKey = 'app_first_launch';

  static SessionService? _instance;
  SharedPreferences? _prefs;

  SessionService._internal();

  static Future<SessionService> getInstance() async {
    if (_instance == null) {
      _instance = SessionService._internal();
      _instance!._prefs = await SharedPreferences.getInstance();
      AppLogger.info(_tag, 'Instance initialized');
    }
    return _instance!;
  }

  Future<void> saveOnboardingData({
    required String companyNumber,
    required String agentNumber,
    required String terminalId,
  }) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(AppConstants.companyNumberKey, companyNumber);
    await prefs.setString(AppConstants.agentNumberKey, agentNumber);
    await prefs.setString(AppConstants.terminalIdKey, terminalId);
    await prefs.setBool(_onboardingCompleteKey, true);

    AppLogger.success(_tag,
        'Onboarding data saved: company=$companyNumber agent=$agentNumber terminal=$terminalId');
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await _ensurePrefs();
    final result = prefs.getBool(_onboardingCompleteKey) ?? false;
    AppLogger.debug(_tag, 'Onboarding complete: $result');
    return result;
  }

  Future<String?> getCompanyNumber() async {
    final prefs = await _ensurePrefs();
    final value = prefs.getString(AppConstants.companyNumberKey);
    AppLogger.debug(_tag, 'Company number read: $value');
    return value;
  }

  Future<String?> getAgentNumber() async {
    final prefs = await _ensurePrefs();
    final value = prefs.getString(AppConstants.agentNumberKey);
    AppLogger.debug(_tag, 'Agent number read: $value');
    return value;
  }

  Future<String?> getTerminalId() async {
    final prefs = await _ensurePrefs();
    final value = prefs.getString(AppConstants.terminalIdKey);
    AppLogger.debug(_tag, 'Terminal ID read: $value');
    return value;
  }

  Future<SessionData> getSessionData() async {
    final prefs = await _ensurePrefs();
    final companyNumber = prefs.getString(AppConstants.companyNumberKey);
    final agentNumber = prefs.getString(AppConstants.agentNumberKey);
    final terminalId = prefs.getString(AppConstants.terminalIdKey);
    final isComplete = prefs.getBool(_onboardingCompleteKey) ?? false;

    final sessionData = SessionData(
      companyNumber: companyNumber,
      agentNumber: agentNumber,
      terminalId: terminalId,
      isComplete: isComplete,
    );

    AppLogger.info(_tag, 'Session data loaded: $sessionData');
    return sessionData;
  }

  Future<void> clearSession() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(AppConstants.companyNumberKey);
    await prefs.remove(AppConstants.agentNumberKey);
    await prefs.remove(AppConstants.terminalIdKey);
    await prefs.setBool(_onboardingCompleteKey, false);

    AppLogger.warning(_tag, 'Session cleared — all data removed');
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await _ensurePrefs();
    final result = prefs.getBool(_firstLaunchKey) ?? true;
    if (result) {
      await prefs.setBool(_firstLaunchKey, false);
    }
    AppLogger.info(_tag, 'First launch: $result');
    return result;
  }

  Future<void> validateSession() async {
    final prefs = await _ensurePrefs();
    final companyNumber = prefs.getString(AppConstants.companyNumberKey);
    final agentNumber = prefs.getString(AppConstants.agentNumberKey);
    final terminalId = prefs.getString(AppConstants.terminalIdKey);

    final missing = <String>[];
    if (companyNumber == null || companyNumber.isEmpty) {
      missing.add('company_number');
    }
    if (agentNumber == null || agentNumber.isEmpty) {
      missing.add('agent_number');
    }
    if (terminalId == null || terminalId.isEmpty) {
      missing.add('terminal_id');
    }

    if (missing.isNotEmpty) {
      await clearSession();
      AppLogger.warning(_tag,
          'Session validation failed — cleared (missing: $missing)');
    } else {
      AppLogger.success(_tag, 'Session valid');
    }
  }

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
}
