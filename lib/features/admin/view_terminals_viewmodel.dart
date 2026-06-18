import 'package:flutter/material.dart';
import '../../data/models/terminal_model.dart';
import '../../data/models/agent_model.dart';
import '../../data/repositories/terminal_repository.dart';
import '../../core/utils/logger.dart';
import '../../app/routes.dart';

class ViewTerminalsViewModel extends ChangeNotifier {
  static const String _tag = 'ViewTerminalsVM';
  final TerminalRepository _terminalRepository = TerminalRepository();

  List<TerminalModel> _terminals = [];
  List<TerminalModel> get terminals => _terminals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadTerminals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _terminalRepository.listTerminals();

      if (response.success) {
        _terminals = response.data ?? [];
      } else {
        _errorMessage = response.failure?.message ?? 'Failed to load terminals';
        AppLogger.logWarning(_tag, 'Load terminals failed: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'An unexpected error occurred while parsing terminal data.';
      AppLogger.logError(_tag, 'Exception in loadTerminals', e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> viewAgentDetail(BuildContext context, String id) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await _terminalRepository.getTerminalDetail(id: id);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      if (response.success && response.data != null) {
        final agentData = response.data!['agent_data'];
        if (agentData != null) {
          final agent = AgentModel.fromJson(agentData);
          Navigator.pushNamed(
            context,
            AppRoutes.agentDetail,
            arguments: agent,
          );
        } else {
          _showError(context, 'No agent data found for this terminal');
        }
      } else {
        _showError(context, response.failure?.message ?? 'Failed to fetch terminal details');
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showError(context, 'An error occurred while fetching details');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
