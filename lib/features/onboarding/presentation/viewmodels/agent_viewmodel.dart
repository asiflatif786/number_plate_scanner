import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/agent_entity.dart';
import '../../domain/repositories/agent_repository.dart';

class AgentViewModel extends ChangeNotifier {
  static const String _tag = 'AgentViewModel';
  final AgentRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  String? agentNumber;
  bool isSubmitted = false;

  final List<String> titles = ['Mr', 'Mrs', 'Miss', 'Chief', 'Dr', 'Prof'];
  final List<String> genders = ['male', 'female'];
  final List<String> maritalStatuses = [
    'single',
    'married',
    'divorced',
    'widowed',
  ];
  final List<String> idTypes = [
    'Voters Card',
    'International Passport',
    'Drivers License',
  ];

  String? selectedTitle;
  String? selectedGender;
  String? selectedMaritalStatus;
  String? selectedIdType;
  String? selectedState;
  String? selectedStateOfOrigin;

  String? utilityBillBase64;
  String? identityDocumentBase64;
  String? passportPhotoBase64;
  String? utilityBillName;
  String? identityDocumentName;
  String? passportPhotoName;

  AgentViewModel({required AgentRepository repository})
      : _repository = repository;

  void setTitle(String value) {
    selectedTitle = value;
    notifyListeners();
  }

  void setGender(String value) {
    selectedGender = value;
    notifyListeners();
  }

  void setMaritalStatus(String value) {
    selectedMaritalStatus = value;
    notifyListeners();
  }

  void setIdType(String value) {
    selectedIdType = value;
    notifyListeners();
  }

  void setState(String value) {
    selectedState = value;
    notifyListeners();
  }

  void setStateOfOrigin(String value) {
    selectedStateOfOrigin = value;
    notifyListeners();
  }

  void setUtilityBill(String base64, String fileName) {
    utilityBillBase64 = base64;
    utilityBillName = fileName;
    AppLogger.info(_tag, 'Utility bill set: $fileName');
    notifyListeners();
  }

  void setIdentityDocument(String base64, String fileName) {
    identityDocumentBase64 = base64;
    identityDocumentName = fileName;
    AppLogger.info(_tag, 'Identity document set: $fileName');
    notifyListeners();
  }

  void setPassportPhoto(String base64, String fileName) {
    passportPhotoBase64 = base64;
    passportPhotoName = fileName;
    AppLogger.info(_tag, 'Passport photo set: $fileName');
    notifyListeners();
  }

  bool get allDocumentsUploaded =>
      utilityBillBase64 != null &&
      identityDocumentBase64 != null &&
      passportPhotoBase64 != null;

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

  void _setSuccess(String message, String agentNum) {
    successMessage = message;
    agentNumber = agentNum;
    isSubmitted = true;
    isLoading = false;
    notifyListeners();
    AppLogger.success(_tag, message);
  }

  Future<void> registerAgent(AgentEntity entity) async {
    errorMessage = null;
    successMessage = null;
    _setLoading(true);

    AppLogger.info(_tag, 'Starting agent registration...');

    try {
      final number = await _repository.registerAgent(entity);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.agentNumberKey, number);

      _setSuccess('Agent registered successfully!', number);
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
    agentNumber = null;
    isSubmitted = false;
    selectedTitle = null;
    selectedGender = null;
    selectedMaritalStatus = null;
    selectedIdType = null;
    selectedState = null;
    selectedStateOfOrigin = null;
    utilityBillBase64 = null;
    identityDocumentBase64 = null;
    passportPhotoBase64 = null;
    utilityBillName = null;
    identityDocumentName = null;
    passportPhotoName = null;
    notifyListeners();
  }
}
