import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/terminal_entity.dart';
import '../../domain/repositories/terminal_repository.dart';

class TerminalViewModel extends ChangeNotifier {
  static const String _tag = 'TerminalViewModel';
  final TerminalRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  bool isSubmitted = false;
  String? savedTerminalId;
  Map<String, dynamic>? terminalDetails;

  TerminalViewModel({required TerminalRepository repository})
      : _repository = repository;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    errorMessage = message;
    isLoading = false;
    notifyListeners();
    AppLogger.error(_tag, message);
  }

  void _setSuccess(String message, String terminalId) {
    successMessage = message;
    savedTerminalId = terminalId;
    isSubmitted = true;
    isLoading = false;
    notifyListeners();
    AppLogger.success(_tag, message);
  }

  Future<void> createTerminalProfile(TerminalEntity entity) async {
    errorMessage = null;
    successMessage = null;
    _setLoading(true);

    AppLogger.info(_tag, 'Starting terminal profiling: ${entity.terminalId}');

    try {
      await _repository.createTerminalProfile(entity);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.terminalIdKey, entity.terminalId);

      _setSuccess('Terminal profiled successfully', entity.terminalId);
    } on Failure catch (f) {
      _setError(f.message);
    } catch (e) {
      AppLogger.error(_tag, 'Unexpected error during terminal profiling', e);
      _setError('Unexpected error occurred');
    }
  }

  Future<void> loadTerminalDetails(String terminalId) async {
    _setLoading(true);

    try {
      terminalDetails = await _repository.getTerminalProfile(terminalId);
      isLoading = false;
      notifyListeners();
      AppLogger.info(_tag, 'Terminal details loaded');
    } catch (e) {
      AppLogger.error(_tag, 'Failed to load terminal details', e);
      isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    isLoading = false;
    errorMessage = null;
    successMessage = null;
    isSubmitted = false;
    savedTerminalId = null;
    terminalDetails = null;
    notifyListeners();
  }
}
