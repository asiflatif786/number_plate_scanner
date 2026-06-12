import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/routes.dart';
import '../../core/errors/failure.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../repositories/onboarding_repository.dart';

class AgentRegistrationViewModel extends ChangeNotifier {
  static const String _tag = 'AgentRegVM';

  final OnboardingRepository _repository;
  final ImagePicker _picker;

  AgentRegistrationViewModel({
    OnboardingRepository? repository,
    ImagePicker? picker,
  })  : _repository = repository ?? OnboardingRepository(),
        _picker = picker ?? ImagePicker();

  bool isLoading = false;
  String? errorMessage;

  String? selectedTitle;
  String? selectedGender;
  String? selectedMaritalStatus;
  String? selectedIdType;
  String? selectedState;
  String? selectedLga;
  String? selectedStateOfOrigin;
  String? selectedLgaOfOrigin;

  List<String> states = [];
  List<String> lgas = [];
  List<String> lgasOfOrigin = [];
  bool isLoadingStates = false;
  bool isLoadingLgas = false;
  bool isLoadingLgasOfOrigin = false;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  String? utilityBillBase64;
  String? identityDocumentBase64;
  String? passportPhotoBase64;
  String? utilityBillFileName;
  String? identityDocumentFileName;
  String? passportPhotoFileName;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final nationalityController = TextEditingController(text: 'Nigerian');
  final bvnController = TextEditingController();
  final ninController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountNameController = TextEditingController();
  final sortCodeController = TextEditingController();
  final identityNumberController = TextEditingController();
  final tinController = TextEditingController();

  // ─── Password Visibility ───

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  // ─── State/LGA Loading ───

  Future<void> loadStates() async {
    isLoadingStates = true;
    notifyListeners();

    try {
      final result = await _repository.getStates();
      if (result.success) {
        states = result.data ?? [];
      } else if (result.failure != null) {
        errorMessage = result.failure!.message;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'loadStates error', e);
    }

    isLoadingStates = false;
    notifyListeners();
  }

  void onResidentialStateChanged(String? state) {
    if (state == null || state == selectedState) return;
    selectedState = state;
    selectedLga = null;
    lgas = [];
    notifyListeners();
    _loadLgas(state);
  }

  void onOriginStateChanged(String? state) {
    if (state == null || state == selectedStateOfOrigin) return;
    selectedStateOfOrigin = state;
    selectedLgaOfOrigin = null;
    lgasOfOrigin = [];
    notifyListeners();
    _loadLgasOfOrigin(state);
  }

  Future<void> _loadLgas(String stateName) async {
    isLoadingLgas = true;
    notifyListeners();

    try {
      final result = await _repository.getLgas(stateName);
      if (result.success) {
        lgas = result.data ?? [];
      }
    } catch (e) {
      AppLogger.logError(_tag, 'loadLgas error', e);
    }

    isLoadingLgas = false;
    notifyListeners();
  }

  Future<void> _loadLgasOfOrigin(String stateName) async {
    isLoadingLgasOfOrigin = true;
    notifyListeners();

    try {
      final result = await _repository.getLgas(stateName);
      if (result.success) {
        lgasOfOrigin = result.data ?? [];
      }
    } catch (e) {
      AppLogger.logError(_tag, 'loadLgasOfOrigin error', e);
    }

    isLoadingLgasOfOrigin = false;
    notifyListeners();
  }

  // ─── Setter Helpers (called from screen) ───

  void setSelectedTitle(String? v) {
    selectedTitle = v;
    notifyListeners();
  }

  void setSelectedGender(String? v) {
    selectedGender = v;
    notifyListeners();
  }

  void setSelectedMaritalStatus(String? v) {
    selectedMaritalStatus = v;
    notifyListeners();
  }

  void setSelectedIdType(String? v) {
    selectedIdType = v;
    notifyListeners();
  }

  void setSelectedLga(String? v) {
    selectedLga = v;
    notifyListeners();
  }

  void setSelectedLgaOfOrigin(String? v) {
    selectedLgaOfOrigin = v;
    notifyListeners();
  }

  // ─── Document Picking ───

  Future<void> pickDocumentFromSource(
      String documentType, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (bytes.length > 5 * 1024 * 1024) {
        errorMessage = 'Image too large. Please choose a smaller image.';
        notifyListeners();
        return;
      }

      final base64Str = base64Encode(bytes);

      switch (documentType) {
        case 'utility_bill':
          utilityBillBase64 = base64Str;
          utilityBillFileName = image.name;
        case 'identity_document':
          identityDocumentBase64 = base64Str;
          identityDocumentFileName = image.name;
        case 'passport_photo':
          passportPhotoBase64 = base64Str;
          passportPhotoFileName = image.name;
      }

      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to pick image. Please try again.';
      AppLogger.logError(_tag, 'pickDocument error', e);
      notifyListeners();
    }
  }

  // ─── Error ───

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  // ─── Validation Helpers ───

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email address is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) return 'Phone number is required';
    if (value.length < 11) return 'Phone number must be 11 digits';
    return null;
  }

  String _friendlyMessage(Failure failure) {
    final msg = failure.message.toLowerCase();
    if (failure is DuplicateFailure) {
      if (msg.contains('email')) return 'This email is already registered as an agent';
      if (msg.contains('phone')) return 'This phone number is already registered';
      if (msg.contains('bvn')) return 'This BVN is already registered';
      return failure.message;
    }
    if (failure is NetworkFailure) {
      return 'No internet connection. Check your network.';
    }
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Something went wrong. Please try again.';
  }

  // ─── Submit ───

  Future<void> submit(BuildContext context) async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final phone = phoneController.text.trim();
    final dob = dateOfBirthController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();
    final nationality = nationalityController.text.trim();
    final bvn = bvnController.text.trim();
    final nin = ninController.text.trim();
    final bankName = bankNameController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    final accountName = accountNameController.text.trim();
    final sortCode = sortCodeController.text.trim();
    final identityNumber = identityNumberController.text.trim();
    final tin = tinController.text.trim();

    // Field validations
    if (selectedTitle == null) {
      errorMessage = 'Please select a title';
      notifyListeners(); return;
    }
    if (firstName.isEmpty) {
      errorMessage = 'First name is required';
      notifyListeners(); return;
    }
    if (lastName.isEmpty) {
      errorMessage = 'Last name is required';
      notifyListeners(); return;
    }
    if (selectedGender == null) {
      errorMessage = 'Please select a gender';
      notifyListeners(); return;
    }
    if (selectedMaritalStatus == null) {
      errorMessage = 'Please select a marital status';
      notifyListeners(); return;
    }
    if (dob.isEmpty) {
      errorMessage = 'Date of birth is required';
      notifyListeners(); return;
    }

    final emailError = _validateEmail(email);
    if (emailError != null) {
      errorMessage = emailError; notifyListeners(); return;
    }

    final phoneError = _validatePhone(phone);
    if (phoneError != null) {
      errorMessage = phoneError; notifyListeners(); return;
    }

    if (password.isEmpty) {
      errorMessage = 'Password is required';
      notifyListeners(); return;
    }
    if (password.length < 6) {
      errorMessage = 'Password must be at least 6 characters';
      notifyListeners(); return;
    }
    if (confirmPassword.isEmpty) {
      errorMessage = 'Please confirm your password';
      notifyListeners(); return;
    }
    if (password != confirmPassword) {
      errorMessage = 'Passwords do not match';
      notifyListeners(); return;
    }
    if (address.isEmpty) {
      errorMessage = 'Residential address is required';
      notifyListeners(); return;
    }
    if (city.isEmpty) {
      errorMessage = 'City is required';
      notifyListeners(); return;
    }
    if (selectedState == null) {
      errorMessage = 'Please select a residential state';
      notifyListeners(); return;
    }
    if (selectedLga == null) {
      errorMessage = 'Please select a residential LGA';
      notifyListeners(); return;
    }
    if (selectedStateOfOrigin == null) {
      errorMessage = 'Please select a state of origin';
      notifyListeners(); return;
    }
    if (selectedLgaOfOrigin == null) {
      errorMessage = 'Please select an LGA of origin';
      notifyListeners(); return;
    }
    if (bvn.isEmpty) {
      errorMessage = 'BVN is required';
      notifyListeners(); return;
    }
    if (bvn.length != 11) {
      errorMessage = 'BVN must be exactly 11 digits';
      notifyListeners(); return;
    }
    if (nin.isEmpty) {
      errorMessage = 'NIN is required';
      notifyListeners(); return;
    }
    if (nin.length != 11) {
      errorMessage = 'NIN must be exactly 11 digits';
      notifyListeners(); return;
    }
    if (selectedIdType == null) {
      errorMessage = 'Please select an ID type';
      notifyListeners(); return;
    }
    if (identityNumber.isEmpty) {
      errorMessage = 'Identity number is required';
      notifyListeners(); return;
    }
    if (bankName.isEmpty) {
      errorMessage = 'Bank name is required';
      notifyListeners(); return;
    }
    if (accountNumber.isEmpty) {
      errorMessage = 'Account number is required';
      notifyListeners(); return;
    }
    if (accountNumber.length != 10) {
      errorMessage = 'Account number must be exactly 10 digits';
      notifyListeners(); return;
    }
    if (accountName.isEmpty) {
      errorMessage = 'Account name is required';
      notifyListeners(); return;
    }
    if (utilityBillBase64 == null) {
      errorMessage = 'Utility bill image is required';
      notifyListeners(); return;
    }
    if (identityDocumentBase64 == null) {
      errorMessage = 'Identity document image is required';
      notifyListeners(); return;
    }
    if (passportPhotoBase64 == null) {
      errorMessage = 'Passport photo is required';
      notifyListeners(); return;
    }

    // Get company number from session
    final session = await SessionManager.instance;
    final companyNumber = session.companyNumber;

    if (companyNumber == null || companyNumber.isEmpty) {
      errorMessage = 'Company registration not found. Please restart onboarding';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        'title': selectedTitle,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone_number': phone,
        'date_of_birth': dob,
        'gender': selectedGender,
        'marital_status': selectedMaritalStatus,
        'nationality': nationality,
        'address': address,
        'city': city,
        'state': selectedState,
        'lga': selectedLga,
        'state_of_origin': selectedStateOfOrigin,
        'lga_of_origin': selectedLgaOfOrigin,
        'bvn': bvn,
        'nin': nin,
        'id_type': selectedIdType,
        'identity_number': identityNumber,
        if (tin.isNotEmpty) 'tin': tin,
        'bank_name': bankName,
        'account_number': accountNumber,
        'account_name': accountName,
        if (sortCode.isNotEmpty) 'sort_code': sortCode,
        'company_number': companyNumber,
        'utility_bill': utilityBillBase64,
        'identity_document': identityDocumentBase64,
        'passport_photo': passportPhotoBase64,
      };

      final result = await _repository.addAgent(payload);

      if (result.success && result.data != null) {
        final agent = result.data!;

        if (agent.agentNumber.isNotEmpty) {
          await session.setAgentNumber(agent.agentNumber);
        }
        await session.setAgentEmail(email);
        await session.setAgentFirstName(firstName);
        await session.setAgentLastName(lastName);

        AppLogger.logInfo(
          _tag, 'Agent created — number: ${agent.agentNumber}');

        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.terminalProfiling);
      } else if (result.failure != null) {
        errorMessage = _friendlyMessage(result.failure!);
        AppLogger.logWarning(
            _tag, 'Add agent failed: ${result.failure!.message}');
      } else {
        errorMessage = 'Something went wrong. Please try again.';
      }
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      AppLogger.logError(_tag, 'submit error', e);
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    cityController.dispose();
    nationalityController.dispose();
    bvnController.dispose();
    ninController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    sortCodeController.dispose();
    identityNumberController.dispose();
    tinController.dispose();
    super.dispose();
  }
}
