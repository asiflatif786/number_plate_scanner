import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/corporate_entity.dart';
import '../../domain/repositories/corporate_repository.dart';

class CorporateViewModel extends ChangeNotifier {
  static const String _tag = 'CorporateViewModel';
  final CorporateRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  String? companyNumber;
  bool isSubmitted = false;

  CorporateViewModel({required CorporateRepository repository})
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

  void _setSuccess(String message, String companyNum) {
    successMessage = message;
    companyNumber = companyNum;
    isSubmitted = true;
    isLoading = false;
    notifyListeners();
    AppLogger.success(_tag, message);
  }

  Future<void> registerCorporate(CorporateEntity entity) async {
    errorMessage = null;
    successMessage = null;
    _setLoading(true);

    AppLogger.info(_tag, 'Starting registration...');

    try {
      final number = await _repository.registerCorporate(entity);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.companyNumberKey, number);

      _setSuccess('Company registered successfully!', number);
    } on Failure catch (f) {
      _setError(f.message);
    } catch (e) {
      AppLogger.error(_tag, 'Unexpected error during registration', e);
      _setError('Unexpected error occurred');
    }
  }

  void clearState() {
    isLoading = false;
    errorMessage = null;
    successMessage = null;
    companyNumber = null;
    isSubmitted = false;
    notifyListeners();
  }
}
