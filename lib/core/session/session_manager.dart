import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class SessionManager {
  static const String _tag = 'SessionManager';

  static SessionManager? _instance;
  SharedPreferences? _prefs;

  SessionManager._internal();

  static Future<SessionManager> get instance async {
    if (_instance == null) {
      _instance = SessionManager._internal();
      _instance!._prefs = await SharedPreferences.getInstance();
      AppLogger.logInfo(_tag, 'Initialized');
    }
    return _instance!;
  }

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    AppLogger.logInfo(_tag, 'Initialized');
  }

  SharedPreferences get _p {
    if (_prefs == null) {
      throw StateError('SessionManager not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ──────────────────────────────────────────────
  // Onboarding State
  // ──────────────────────────────────────────────

  bool get isOnboarded => _p.getBool(AppConstants.isOnboardedKey) ?? false;

  Future<void> setOnboarded(bool value) async {
    await _p.setBool(AppConstants.isOnboardedKey, value);
    AppLogger.logInfo(_tag, 'onboarded set to $value');
  }

  Future<void> clearOnboarding() async {
    await _p.setBool(AppConstants.isOnboardedKey, false);
    AppLogger.logInfo(_tag, 'onboarding flag cleared');
  }

  // ──────────────────────────────────────────────
  // Company Data
  // ──────────────────────────────────────────────

  String? get companyNumber => _p.getString(AppConstants.companyNumberKey);

  Future<void> setCompanyNumber(String value) async {
    await _p.setString(AppConstants.companyNumberKey, value);
    AppLogger.logInfo(_tag, 'companyNumber saved');
  }

  Future<void> clearCompanyNumber() async {
    await _p.remove(AppConstants.companyNumberKey);
    AppLogger.logInfo(_tag, 'companyNumber removed');
  }

  // ──────────────────────────────────────────────
  // Agent Data
  // ──────────────────────────────────────────────

  String? get agentNumber => _p.getString(AppConstants.agentNumberKey);

  Future<void> setAgentNumber(String value) async {
    await _p.setString(AppConstants.agentNumberKey, value);
    AppLogger.logInfo(_tag, 'agentNumber saved');
  }

  String? get agentEmail => _p.getString(AppConstants.userEmailKey);

  Future<void> setAgentEmail(String value) async {
    await _p.setString(AppConstants.userEmailKey, value);
    AppLogger.logInfo(_tag, 'agentEmail saved');
  }

  String? get agentFirstName => _p.getString(AppConstants.userFirstNameKey);

  Future<void> setAgentFirstName(String value) async {
    await _p.setString(AppConstants.userFirstNameKey, value);
    AppLogger.logInfo(_tag, 'agentFirstName saved');
  }

  String? get agentLastName => _p.getString(AppConstants.userLastNameKey);

  Future<void> setAgentLastName(String value) async {
    await _p.setString(AppConstants.userLastNameKey, value);
    AppLogger.logInfo(_tag, 'agentLastName saved');
  }

  String get agentFullName {
    final first = agentFirstName;
    final last = agentLastName;
    if (first == null && last == null) return '';
    return '${first ?? ''} ${last ?? ''}'.trim();
  }

  // ──────────────────────────────────────────────
  // Terminal Data
  // ──────────────────────────────────────────────

  String? get terminalId => _p.getString(AppConstants.terminalIdKey);

  Future<void> setTerminalId(String value) async {
    await _p.setString(AppConstants.terminalIdKey, value);
    AppLogger.logInfo(_tag, 'terminalId saved');
  }

  String? get serialNumber => _p.getString(AppConstants.serialNumberKey);

  Future<void> setSerialNumber(String value) async {
    await _p.setString(AppConstants.serialNumberKey, value);
    AppLogger.logInfo(_tag, 'serialNumber saved');
  }

  // ──────────────────────────────────────────────
  // Auth / Role
  // ──────────────────────────────────────────────

  String? get authToken => _p.getString(AppConstants.authTokenKey);

  Future<void> setAuthToken(String value) async {
    await _p.setString(AppConstants.authTokenKey, value);
    AppLogger.logInfo(_tag, 'authToken saved');
  }

  String? get userRole => _p.getString(AppConstants.userRoleKey);

  Future<void> setUserRole(String value) async {
    await _p.setString(AppConstants.userRoleKey, value);
    AppLogger.logInfo(_tag, 'userRole saved: $value');
  }

  bool get isAdmin => userRole == AppConstants.roleAdmin;
  bool get isAgent => userRole == AppConstants.roleAgent;

  // ──────────────────────────────────────────────
  // Credential Summary (for Onboarding Complete screen)
  // ──────────────────────────────────────────────

  Future<void> saveCredentialSummary({
    required String agentNumber,
    required String companyNumber,
    required String terminalId,
    String? email,
  }) async {
    await setCompanyNumber(companyNumber);
    await setAgentNumber(agentNumber);
    await setTerminalId(terminalId);
    if (email != null) await setAgentEmail(email);
    AppLogger.logInfo(_tag, 'credential summary saved');
  }

  String getCredentialSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Company No.: ${companyNumber ?? '—'}');
    buffer.writeln('Agent No.: ${agentNumber ?? '—'}');
    buffer.writeln('Terminal ID: ${terminalId ?? '—'}');
    buffer.writeln('Email: ${agentEmail ?? '—'}');
    return buffer.toString();
  }

  // ──────────────────────────────────────────────
  // Bulk Save (called after onboarding completes)
  // ──────────────────────────────────────────────

  Future<void> saveOnboardingComplete({
    String? companyNumber,
    String? agentNumber,
    String? terminalId,
    String? serialNumber,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
  }) async {
    if (companyNumber != null) await setCompanyNumber(companyNumber);
    if (agentNumber != null) await setAgentNumber(agentNumber);
    if (terminalId != null) await setTerminalId(terminalId);
    if (serialNumber != null) await setSerialNumber(serialNumber);
    if (email != null) await setAgentEmail(email);
    if (firstName != null) await setAgentFirstName(firstName);
    if (lastName != null) await setAgentLastName(lastName);
    if (role != null) await setUserRole(role);
    await setOnboarded(true);

    AppLogger.logInfo(_tag, 'onboarding complete — all fields saved');
  }

  // ──────────────────────────────────────────────
  // Channel / Service Numbers (from admin setup)
  // ──────────────────────────────────────────────

  String? get channelNumber {
    final val = _p.getString(ApiConstants.channelNumberKey);
    if (val != null && val.isNotEmpty) return val;
    return ApiConstants.defaultChannelNumber.isNotEmpty
        ? ApiConstants.defaultChannelNumber
        : null;
  }

  Future<void> setChannelNumber(String value) async {
    await _p.setString(ApiConstants.channelNumberKey, value);
    AppLogger.logInfo(_tag, 'channelNumber saved');
  }

  String? get serviceNumberValidation {
    final val = _p.getString(ApiConstants.serviceNumberValidationKey);
    if (val != null && val.isNotEmpty) return val;
    return ApiConstants.defaultValidationServiceNumber.isNotEmpty
        ? ApiConstants.defaultValidationServiceNumber
        : null;
  }

  Future<void> setServiceNumberValidation(String value) async {
    await _p.setString(ApiConstants.serviceNumberValidationKey, value);
    AppLogger.logInfo(_tag, 'serviceNumberValidation saved');
  }

  String? get serviceNumberTransaction {
    final val = _p.getString(ApiConstants.serviceNumberTransactionKey);
    if (val != null && val.isNotEmpty) return val;
    return ApiConstants.defaultTransactionServiceNumber.isNotEmpty
        ? ApiConstants.defaultTransactionServiceNumber
        : null;
  }

  Future<void> setServiceNumberTransaction(String value) async {
    await _p.setString(ApiConstants.serviceNumberTransactionKey, value);
    AppLogger.logInfo(_tag, 'serviceNumberTransaction saved');
  }

  // ──────────────────────────────────────────────
  // Clear Methods
  // ──────────────────────────────────────────────

  Future<void> clearSession() async {
    await _p.remove(AppConstants.isOnboardedKey);
    await _p.remove(AppConstants.companyNumberKey);
    await _p.remove(AppConstants.agentNumberKey);
    await _p.remove(AppConstants.terminalIdKey);
    await _p.remove(AppConstants.serialNumberKey);
    await _p.remove(AppConstants.userRoleKey);
    await _p.remove(AppConstants.userEmailKey);
    await _p.remove(AppConstants.userFirstNameKey);
    await _p.remove(AppConstants.userLastNameKey);
    await _p.remove(AppConstants.authTokenKey);
    await _p.remove(ApiConstants.channelNumberKey);
    await _p.remove(ApiConstants.serviceNumberValidationKey);
    await _p.remove(ApiConstants.serviceNumberTransactionKey);
    AppLogger.logWarning(_tag, 'session cleared — all data wiped');
  }

  Future<void> clearTransactionData() async {
    AppLogger.logInfo(_tag, 'transaction data cleared (no-op)');
  }

  // ──────────────────────────────────────────────
  // Session Check
  // ──────────────────────────────────────────────

  bool hasValidSession() {
    return isOnboarded;
  }
}
