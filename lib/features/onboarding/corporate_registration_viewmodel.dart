import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/errors/failure.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../repositories/onboarding_repository.dart';

class CorporateRegistrationViewModel extends ChangeNotifier {
  static const String _tag = 'CorpRegVM';

  final OnboardingRepository _repository;

  CorporateRegistrationViewModel({OnboardingRepository? repository})
      : _repository = repository ?? OnboardingRepository();

  final nameController = TextEditingController();
  final rcNumberController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final contactAddressController = TextEditingController();
  final tinController = TextEditingController();
  final cityController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  String? selectedState;
  String? selectedLga;
  List<String> states = [];
  List<String> lgas = [];
  final Map<String, String> _stateNameToId = {};
  bool isLoadingStates = false;
  bool isLoadingLgas = false;

  Future<void> loadStates() async {
    isLoadingStates = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getStates();
      if (result.success) {
        _stateNameToId.clear();
        for (final s in result.data ?? []) {
          _stateNameToId[s.stateName] = s.stateId;
        }
        states = _stateNameToId.keys.toList();
        AppLogger.logInfo(_tag, 'Loaded ${states.length} states');
      } else if (result.failure != null) {
        errorMessage = _friendlyMessage(result.failure!);
        AppLogger.logWarning(_tag, 'Failed to load states: ${result.failure!.message}');
      }
    } catch (e) {
      errorMessage = 'Failed to load states. Pull down to retry.';
      AppLogger.logError(_tag, 'loadStates error', e);
    }

    isLoadingStates = false;
    notifyListeners();
  }

  void setSelectedLga(String? lga) {
    selectedLga = lga;
    notifyListeners();
  }

  void onStateChanged(String? state) {
    if (state == null || state == selectedState) return;
    selectedState = state;
    selectedLga = null;
    lgas = [];
    notifyListeners();
    final stateId = _stateNameToId[state];
    if (stateId != null) loadLgas(stateId);
  }

  Future<void> loadLgas(String stateId) async {
    isLoadingLgas = true;
    notifyListeners();

    try {
      final result = await _repository.getLgas(stateId);
      if (result.success) {
        lgas = result.data ?? [];
        AppLogger.logInfo(_tag, 'Loaded ${lgas.length} LGAs');
      } else if (result.failure != null) {
        errorMessage = 'Failed to load LGAs: ${_friendlyMessage(result.failure!)}';
        AppLogger.logWarning(_tag, 'Failed to load LGAs: ${result.failure!.message}');
      }
    } catch (e) {
      errorMessage = 'Failed to load LGAs. Please try again.';
      AppLogger.logError(_tag, 'loadLgas error', e);
    }

    isLoadingLgas = false;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Email address is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String value) {
    if (value.isEmpty) return 'Phone number is required';
    if (value.length < 7) return 'Phone number must be at least 7 digits';
    return null;
  }

  String _friendlyMessage(Failure failure) {
    if (failure is DuplicateFailure) {
      return failure.message.toLowerCase().contains('rc')
          ? 'A company with this RC number already exists'
          : 'This email is already registered';
    }
    if (failure is NetworkFailure) {
      return 'No internet connection. Check your network.';
    }
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> submit(BuildContext context, {bool isFromAdmin = false}) async {
    final name = nameController.text.trim();
    final rcNumber = rcNumberController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final contactAddress = contactAddressController.text.trim();
    final tin = tinController.text.trim();
    final city = cityController.text.trim();

    if (name.isEmpty) {
      errorMessage = 'Company name is required';
      notifyListeners();
      return;
    }
    if (rcNumber.isEmpty) {
      errorMessage = 'CAC Registration Number is required';
      notifyListeners();
      return;
    }
    
    // TIN is now optional
    
    final emailError = _validateEmail(email);
    if (emailError != null) {
      errorMessage = emailError;
      notifyListeners();
      return;
    }
    final phoneError = _validatePhone(phone);
    if (phoneError != null) {
      errorMessage = phoneError;
      notifyListeners();
      return;
    }
    if (address.isEmpty) {
      errorMessage = 'Registered address is required';
      notifyListeners();
      return;
    }
    if (city.isEmpty) {
      errorMessage = 'City is required';
      notifyListeners();
      return;
    }
    if (selectedState == null) {
      errorMessage = 'Please select a state';
      notifyListeners();
      return;
    }
    if (selectedLga == null) {
      errorMessage = 'Please select an LGA';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        'name': name,
        'rc_number': rcNumber,
        'tin': tin.isEmpty ? null : tin,
        'email': email,
        'phone_number': phone,
        'address': address,
        'contact_address': contactAddress,
        'city': city,
        'state': selectedState,
        'lga': selectedLga,
      };

      final result = await _repository.createCompany(payload);

      if (result.success && result.data != null) {
        final company = result.data!;

        final session = await SessionManager.instance;
        if (company.companyNumber.isNotEmpty) {
          await session.setCompanyNumber(company.companyNumber);
        }

        AppLogger.logInfo(
          _tag,
          'Company created — number: ${company.companyNumber}',
        );

        if (!context.mounted) return;
        
        if (isFromAdmin) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Company "${company.companyNumber}" created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.agentRegistration);
        }
      } else if (result.failure != null) {
        errorMessage = _friendlyMessage(result.failure!);
        AppLogger.logWarning(_tag, 'Create company failed: ${result.failure!.message}');
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
    nameController.dispose();
    rcNumberController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    contactAddressController.dispose();
    tinController.dispose();
    cityController.dispose();
    super.dispose();
  }
}
