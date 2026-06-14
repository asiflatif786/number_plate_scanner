import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/agent_model.dart';
import '../../data/repositories/agent_repository.dart';

class ViewAgentsViewModel extends ChangeNotifier {
  static const String _tag = 'ViewAgentsVM';

  final AgentRepository _repository = AgentRepository();

  List<AgentModel> _agents = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  int _currentPage = 1;
  String _searchQuery = '';
  String? _selectedAgentForKyc;

  List<AgentModel> get agents => _agents;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  String get searchQuery => _searchQuery;
  String? get selectedAgentForKyc => _selectedAgentForKyc;
  bool get hasMorePages => _currentPage < _repository.totalPages;
  int get totalAgents => _repository.totalAgents;

  List<AgentModel> get filteredAgents {
    if (_searchQuery.isEmpty) return _agents;
    final q = _searchQuery.toLowerCase();
    return _agents.where((a) {
      return a.fullName.toLowerCase().contains(q) ||
          a.agentNumber.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> loadAgents({bool refresh = false}) async {
    final session = await SessionManager.instance;
    final channelNumber = session.channelNumber;
    if (channelNumber == null) {
      _errorMessage = 'Channel number not configured.';
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
      return;
    }

    if (refresh) {
      _agents = [];
      _currentPage = 1;
      _isRefreshing = true;
    } else if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listAgents(
      channelNumber: channelNumber,
      page: _currentPage,
    );

    if (result.success) {
      if (refresh || _currentPage == 1) {
        _agents = result.data ?? [];
      } else {
        _agents.addAll(result.data ?? []);
      }
      _currentPage++;
    } else {
      _errorMessage = result.failure?.message ?? 'Failed to load agents';
      AppLogger.logWarning(_tag, _errorMessage!);
    }

    _isLoading = false;
    _isLoadingMore = false;
    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!hasMorePages || _isLoadingMore) return;
    await loadAgents();
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
    Navigator.pushNamed(context, '/agent-registration');
  }
}
