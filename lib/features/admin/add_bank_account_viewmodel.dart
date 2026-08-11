import 'package:flutter/material.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/logger.dart';
import '../../data/models/agent_model.dart';
import '../../data/models/company_model.dart';
import '../../data/repositories/bank_repository.dart';

enum BankAccountStage {
  agentSelection,
  vendorConfirmation,
  bankProfileCreation,
  otpVerification
}

class AddBankAccountViewModel extends ChangeNotifier {
  static const String _tag = 'AddBankVM';
  final BankRepository _repository = BankRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  BankAccountStage _stage = BankAccountStage.agentSelection;
  BankAccountStage get stage => _stage;

  bool _vendorExists = false;
  bool get vendorExists => _vendorExists;

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
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to fetch agents';
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error fetching agents', e);
      _errorMessage = 'An unexpected error occurred while fetching agents';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedAgent(Map<String, dynamic>? agent) {
    _selectedAgent = agent;
    _vendorExists = false;
    _errorMessage = null;
    _successMessage = null;
    _customerDetails = null;
    
    if (agent != null) {
      _stage = BankAccountStage.vendorConfirmation;
    } else {
      _stage = BankAccountStage.agentSelection;
    }
    notifyListeners();
  }

  void setFromCompany(CompanyModel company) {
    _selectedAgent = {
      'company_number': company.rcNumber,
      'first_name': company.name,
      'last_name': '',
      'email': company.email,
      'phone_number': company.phoneNumber,
      'address': company.address,
      'city': company.city,
      'state': company.state,
      'lga': company.lga,
    };
    _vendorExists = false;
    _errorMessage = null;
    _successMessage = null;
    _customerDetails = null;
    _stage = BankAccountStage.vendorConfirmation;
    notifyListeners();
  }

  void setFromAgent(AgentModel agent) {
    _selectedAgent = {
      'company_number': agent.companyNumber,
      'first_name': agent.firstName,
      'last_name': agent.lastName,
      'email': agent.email,
      'phone_number': agent.phoneNumber,
      'address': agent.address,
      'city': agent.city,
      'state': agent.state,
      'lga': agent.lga,
      'bvn': agent.bvn,
    };
    _vendorExists = false;
    _errorMessage = null;
    _successMessage = null;
    _customerDetails = null;
    _stage = BankAccountStage.vendorConfirmation;
    notifyListeners();
  }

  Future<bool> confirmAccount() async {
    if (_selectedAgent == null) return false;
    
    final rcNumber = _selectedAgent!['company_number']?.toString() ?? '';
    if (rcNumber.isEmpty) {
      _errorMessage = 'Selected record has no RC/Company number';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final checkResponse = await _repository.getVendorDetail(rcNumber);

      if (checkResponse.success) {
        _vendorExists = true;
        _customerDetails = checkResponse.data;
        _successMessage = 'Vendor account verified.';
        // We stay on the current stage as per user request to only show success message
        notifyListeners();
        return true;
      } else {
        _vendorExists = false;
        _errorMessage = checkResponse.failure?.message ?? 'Vendor account not found. Please create it.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error in confirmAccount', e);
      _errorMessage = 'An unexpected error occurred while verifying account';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createVendorAccount() async {
    if (_selectedAgent == null) return false;

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final createResponse = await _repository.createVendorAccount(_selectedAgent!);

      if (createResponse.success) {
        _vendorExists = true;
        _customerDetails = createResponse.data;
        _successMessage = createResponse.message ?? 'Vendor account created successfully';
        // Stay on current stage - don't automatically jump to bank profile creation
        notifyListeners();
        return true;
      } else {
        _errorMessage = createResponse.failure?.message ?? 'Failed to create vendor account';
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error in createVendorAccount', e);
      _errorMessage = 'An unexpected error occurred while creating account';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAgentBank(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.addAgentBank(data);

      if (response.success) {
        _successMessage = response.message ?? 'Agent added to payment system successfully';
        // Stay on current screen/stage
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to add agent to payment system';
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error in addAgentBank', e);
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBankProfile({
    required String bvn,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.createBankProfile(
        bvn: bvn,
        email: email,
      );

      if (response.success) {
        _successMessage = response.message ?? 'Bank profile created. OTP sent.';
        _lastEmail = email;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to create bank profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error creating bank profile', e);
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
        _successMessage = response.message ?? 'Details retrieved successfully';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to retrieve details';
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
    _stage = BankAccountStage.agentSelection;
    _vendorExists = false;
    _lastEmail = null;
    _customerDetails = null;
    _selectedAgent = null;
    clearMessages();
  }
}
