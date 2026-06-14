import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../data/models/agent_model.dart';
import '../../data/repositories/agent_repository.dart';

class AgentDetailViewModel extends ChangeNotifier {
  static const String _tag = 'AgentDetVM';

  final AgentRepository _repository = AgentRepository();

  AgentModel agent;
  String? agentStatus;
  bool? kycComplete;
  bool isLoadingStatus = false;
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

  Future<void> refreshAgent() async {
    final result = await _repository.getAgent(
      agentNumber: agent.agentNumber,
    );

    if (result.success && result.data != null) {
      agent = result.data!;
      notifyListeners();
    }
  }
}
