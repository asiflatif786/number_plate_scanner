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
  bool? kycComplete;
  List<TerminalModel> terminals = [];
  bool isLoadingStatus = false;
  bool isLoadingTerminals = false;
  String? errorMessage;

  AgentDetailViewModel({required this.agent}) {
    AppLogger.logDebug(_tag, 'Init: ${agent.agentNumber}');
  }

  Future<void> loadAgentHealth() async {
    isLoadingStatus = true;
    notifyListeners();

    try {
      final statusResult = await _repository.getAgentStatus(agentNumber: agent.agentNumber);
      final kycResult = await _repository.getAgentKycStatus(agentNumber: agent.agentNumber);

      if (statusResult.success) {
        agentStatus = statusResult.data;
      }
      if (kycResult.success) {
        kycComplete = kycResult.data;
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Health check error: $e');
    }

    isLoadingStatus = false;
    notifyListeners();
  }

  Future<void> loadTerminalDetails() async {
    isLoadingTerminals = true;
    notifyListeners();

    try {
      final result = await _repository.getTerminalDetail(agentNumber: agent.agentNumber);
      if (result.success && result.data != null) {
        final data = result.data!;
        
        if (data.containsKey('terminals') && data['terminals'] is List) {
          final rawTerminals = data['terminals'] as List<dynamic>;
          terminals = rawTerminals
              .map((e) => TerminalModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (data.containsKey('terminal_data')) {
          // Handle single terminal response format provided in the request
          terminals = [TerminalModel.fromJson(data['terminal_data'] as Map<String, dynamic>)];
        } else {
          terminals = [];
        }
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Error loading terminal details: $e');
    }

    isLoadingTerminals = false;
    notifyListeners();
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
  }
}
