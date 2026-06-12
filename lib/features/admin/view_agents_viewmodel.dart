import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../../data/models/agent_model.dart';

class ViewAgentsViewModel extends ChangeNotifier {
  List<AgentModel> agents = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  List<AgentModel> get filteredAgents {
    if (searchQuery.isEmpty) return agents;
    final query = searchQuery.toLowerCase();
    return agents.where((a) {
      return a.fullName.toLowerCase().contains(query) ||
          a.agentNumber.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadAgents() async {
    isLoading = true;
    notifyListeners();

    final session = await SessionManager.instance;
    final agentNumber = session.agentNumber;

    if (agentNumber != null && agentNumber.isNotEmpty) {
      final agent = AgentModel(
        id: null,
        agentNumber: agentNumber,
        title: '',
        firstName: session.agentFirstName ?? '',
        lastName: session.agentLastName ?? '',
        email: session.agentEmail ?? '',
        phoneNumber: '',
        companyNumber: session.companyNumber ?? '',
        gender: '',
        maritalStatus: '',
        dateOfBirth: '',
        address: '',
        city: '',
        state: '',
        lga: '',
        stateOfOrigin: '',
        lgaOfOrigin: '',
        nationality: '',
        bvn: '',
        nin: '',
        bankName: '',
        accountNumber: '',
        accountName: '',
        sortCode: null,
        idType: '',
        identityNumber: '',
        tin: null,
      );
      agents = [agent];
    } else {
      agents = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    notifyListeners();
  }
}
