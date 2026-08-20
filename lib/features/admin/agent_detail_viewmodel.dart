import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../data/models/agent_model.dart';
import '../../data/models/terminal_model.dart';
import '../../data/repositories/agent_repository.dart';

class AgentDetailViewModel extends ChangeNotifier {
  static const String _tag = 'AgentDetVM';

  final AgentRepository _repository = AgentRepository();

  AgentModel agent;
  String? agentStatus;
  String? paymentSystemStatus;
  Map<String, dynamic>? customerDetails;
  
  List<TerminalModel> terminals = [];
  bool isLoadingStatus = false;
  bool isLoadingTerminals = false;
  bool isLoadingExistence = false;
  bool isMappingAgent = false;
  bool isLoadingCustomerDetails = false;
  
  bool? agentExistsInPaymentSystem;
  String? errorMessage;
  String? successMessage;

  AgentDetailViewModel({required this.agent}) {
    AppLogger.logDebug(_tag, 'Init: ${agent.agentNumber}');
  }

  Future<void> loadAgentHealth() async {
    isLoadingStatus = true;
    notifyListeners();

    try {
      final statusResult = await _repository.getAgentStatus(agentNumber: agent.agentNumber);
      if (statusResult.success) {
        agentStatus = statusResult.data;
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Health check error: $e');
    }

    isLoadingStatus = false;
    notifyListeners();
  }

  Future<void> loadCustomerDetails() async {
    if (agent.email.isEmpty) return;

    isLoadingCustomerDetails = true;
    paymentSystemStatus = null;
    customerDetails = null;
    notifyListeners();

    try {
      final result = await _repository.getCustomerDetails(agent.email);
      if (result.success && result.data != null) {
        customerDetails = result.data!;
        AppLogger.logDebug(_tag, 'Customer details loaded: ${customerDetails!.keys.toList()}');
        
        final dynamic bankData = customerDetails!['bankAccount'] ?? customerDetails!['bank_account'];
        
        if (bankData != null && bankData is Map) {
          final bankAccount = Map<String, dynamic>.from(bankData);
          final rawStatus = bankAccount['status']?.toString();
          paymentSystemStatus = rawStatus?.trim().toUpperCase();
          AppLogger.logInfo(_tag, 'Extracted Payment System Status: $paymentSystemStatus for ${agent.email}');
        } else {
          AppLogger.logWarning(_tag, 'bankAccount not found in customer details for ${agent.email}');
        }
      } else {
        AppLogger.logWarning(_tag, 'Failed to fetch customer details: ${result.failure?.message}');
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Error loading customer details: $e');
    } finally {
      isLoadingCustomerDetails = false;
      notifyListeners();
    }
  }

  Future<void> checkAgentExistence() async {
    if (agent.email.isEmpty) {
      AppLogger.logWarning(_tag, 'Cannot check existence: Email is empty');
      agentExistsInPaymentSystem = false;
      notifyListeners();
      return;
    }
    
    isLoadingExistence = true;
    notifyListeners();

    try {
      final result = await _repository.checkAgentExists(agent.email);
      if (result.success && result.data != null) {
        final Map<String, dynamic> data = result.data!;
        
        String? newRc;
        int? newMtc;

        if (data.containsKey('rc_number') && data['rc_number'] != null) {
          newRc = data['rc_number'].toString();
        }
        if (data.containsKey('map_to_company') && data['map_to_company'] != null) {
          newMtc = int.tryParse(data['map_to_company'].toString());
        }

        if (data.containsKey('agent_data') && data['agent_data'] is Map) {
          final ad = data['agent_data'] as Map<String, dynamic>;
          if (ad.containsKey('rc_number') && ad['rc_number'] != null) {
            newRc = ad['rc_number'].toString();
          }
          if (ad.containsKey('map_to_company') && ad['map_to_company'] != null) {
            newMtc = int.tryParse(ad['map_to_company'].toString());
          }
        } else if (data.containsKey('corporate_id') && data['corporate_id'] != null) {
          newRc = data['corporate_id'].toString();
        }

        agent = agent.copyWith(
          rcNumber: newRc ?? agent.rcNumber,
          mapToCompany: newMtc ?? agent.mapToCompany,
        );

        agentExistsInPaymentSystem = true;
        AppLogger.logInfo(_tag, 'Agent exists in payment system. RC: ${agent.rcNumber}, MTC: ${agent.mapToCompany}');
      } else {
        agentExistsInPaymentSystem = false;
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Error checking agent existence: $e');
      agentExistsInPaymentSystem = false;
    } finally {
      isLoadingExistence = false;
      notifyListeners();
    }
  }

  Future<void> loadTerminalDetails() async {
    isLoadingTerminals = true;
    notifyListeners();

    try {
      final result = await _repository.getTerminalDetail(agentNumber: agent.agentNumber);
      if (result.success && result.data != null) {
        final data = result.data!;
        
        // Update map_to_company if present in the response
        if (data.containsKey('map_to_company')) {
          final mtc = int.tryParse(data['map_to_company'].toString()) ?? 1;
          agent = agent.copyWith(mapToCompany: mtc);
        }

        // Update RC number and map_to_company if found in agent_data
        if (data.containsKey('agent_data') && data['agent_data'] is Map) {
          final agentData = data['agent_data'] as Map<String, dynamic>;
          if (agentData.containsKey('rc_number') && agentData['rc_number'] != null) {
            final rc = agentData['rc_number'].toString();
            if (rc.isNotEmpty) {
              agent = agent.copyWith(rcNumber: rc);
              AppLogger.logInfo(_tag, 'Updated agent RC from terminal details: $rc');
            }
          }
          if (agentData.containsKey('map_to_company')) {
            final mtc = int.tryParse(agentData['map_to_company'].toString()) ?? 1;
            agent = agent.copyWith(mapToCompany: mtc);
          }
        }

        // Parse terminals
        if (data.containsKey('terminals') && data['terminals'] is List) {
          final rawTerminals = data['terminals'] as List<dynamic>;
          terminals = rawTerminals
              .map((e) => TerminalModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('terminal_data')) {
          terminals = [TerminalModel.fromJson(data['terminal_data'] as Map<String, dynamic>)];
        } else {
          terminals = [];
        }
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Error loading terminal details: $e');
    } finally {
      isLoadingTerminals = false;
      notifyListeners();
    }
  }

  Future<bool> mapAgentToCompany() async {
    if (agent.email.isEmpty || agent.rcNumber.isEmpty) {
      errorMessage = 'Agent email or RC number is missing';
      notifyListeners();
      return false;
    }

    isMappingAgent = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.mapAgentToCompany(
        email: agent.email,
        rcNumber: agent.rcNumber,
      );

      if (result.success) {
        successMessage = result.message ?? 'Agent mapped to company successfully';
        agent = agent.copyWith(mapToCompany: 1);
        isMappingAgent = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = result.failure?.message ?? 'Failed to map agent to company';
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
    } finally {
      isMappingAgent = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> refreshAgent() async {
    final result = await _repository.getAgent(
      agentNumber: agent.agentNumber,
    );

    if (result.success && result.data != null) {
      agent = result.data!;
      notifyListeners();
    }
    
    await loadAgentHealth();
    await loadTerminalDetails();
    await checkAgentExistence();
    await loadCustomerDetails();
  }
}
