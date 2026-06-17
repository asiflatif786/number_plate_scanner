import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../data/models/agent_model.dart';
import '../../data/repositories/agent_repository.dart';

class ViewAgentsViewModel extends ChangeNotifier {
  static const String _tag = 'ViewAgentsVM';

  final AgentRepository _repository = AgentRepository();

  List<AgentModel> _agents = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedAgentForKyc;

  List<AgentModel> get agents => _agents;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedAgentForKyc => _selectedAgentForKyc;
  int get totalAgents => _agents.length;

  List<AgentModel> get filteredAgents {
    if (_searchQuery.isEmpty) return _agents;
    final q = _searchQuery.toLowerCase();
    return _agents.where((a) {
      return a.fullName.toLowerCase().contains(q) ||
          a.agentNumber.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> loadAgents({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getAllAgents();

      if (result.success) {
        _agents = result.data ?? [];
        AppLogger.logInfo(_tag, 'Loaded ${_agents.length} agents');
      } else {
        _errorMessage = result.failure?.message ?? 'Failed to load agents';
        AppLogger.logWarning(_tag, _errorMessage!);
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      AppLogger.logError(_tag, 'loadAgents error', e);
    }

    _isLoading = false;
    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> onRefresh() async {
    await loadAgents(refresh: true);
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkAgentKyc(String agentNumber) async {
    _selectedAgentForKyc = agentNumber;
    notifyListeners();

    try {
      final statusResult = await _repository.getAgentStatus(agentNumber: agentNumber);
      final kycResult = await _repository.getAgentKycStatus(agentNumber: agentNumber);

      _selectedAgentForKyc = null;
      notifyListeners();

      return {
        'status': statusResult.success ? statusResult.data : 'unknown',
        'kycComplete': kycResult.success ? kycResult.data : false,
      };
    } catch (e) {
      _selectedAgentForKyc = null;
      notifyListeners();
      return {'status': 'unknown', 'kycComplete': false};
    }
  }

  void navigateToAgentDetail(BuildContext context, AgentModel agent) {
    Navigator.pushNamed(context, '/agent-detail', arguments: agent);
  }

  void navigateToAddAgent(BuildContext context) {
    Navigator.pushNamed(context, '/company-verify');
  }
}
