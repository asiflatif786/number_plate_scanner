import 'package:flutter/material.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/bank_repository.dart';

class AddBankAccountViewModel extends ChangeNotifier {
  static const String _tag = 'AddBankVM';
  final BankRepository _repository = BankRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Track if profile was created to show next step
  bool _profileCreated = false;
  bool get profileCreated => _profileCreated;

  String? _lastEmail;
  String? get lastEmail => _lastEmail;

  Map<String, dynamic>? _customerDetails;
  Map<String, dynamic>? get customerDetails => _customerDetails;

  List<Map<String, dynamic>> _agentsList = [];
  List<Map<String, dynamic>> get agentsList => _agentsList;

  Map<String, dynamic>? _selectedAgent;
  Map<String, dynamic>? get selectedAgent => _selectedAgent;

  Future<void> fetchAgents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getAgentsForBank();

      if (response.success && response.data != null) {
        _agentsList = response.data!;
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to fetch agents';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error fetching agents', e);
      _errorMessage = 'An unexpected error occurred while fetching agents';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedAgent(Map<String, dynamic>? agent) {
    _selectedAgent = agent;
    notifyListeners();
  }

  Future<bool> createCustomerProfile({
    required String bvn,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _profileCreated = false;
    _customerDetails = null;
    notifyListeners();

    try {
      final response = await _repository.createCustomerProfile(
        bvn: bvn,
        email: email,
      );

      if (response.success) {
        _successMessage = response.message ?? 'Bank account profile created successfully';
        _profileCreated = true;
        _lastEmail = email;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to create bank account profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error creating customer profile', e);
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> generateAccount({
    required String otp,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.generateAccount(
        otp: otp,
        email: email,
      );

      if (response.success) {
        _successMessage = response.message ?? 'Bank account generated successfully';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to generate bank account';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error generating account', e);
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> regenerateOtp({
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.regenerateOtp(
        email: email,
      );

      if (response.success) {
        _successMessage = response.message ?? 'OTP regenerated successfully';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to regenerate OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error regenerating OTP', e);
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getCustomerDetails({
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _customerDetails = null;
    notifyListeners();

    try {
      final response = await _repository.getCustomerDetails(
        email: email,
      );

      if (response.success) {
        _customerDetails = response.data;
        _successMessage = response.message ?? 'Customer details retrieved successfully';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to retrieve customer details';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error getting customer details', e);
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    _profileCreated = false;
    _lastEmail = null;
    _customerDetails = null;
    _selectedAgent = null;
    clearMessages();
  }
}
