import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/terminal_repository.dart';
import '../../data/models/terminal_model.dart';

class AgentDashboardViewModel extends ChangeNotifier {
  static const String _tag = 'AgentDashVM';

  final TransactionRepository _txRepo = TransactionRepository();
  final TerminalRepository _terminalRepo = TerminalRepository();

  String agentFullName = '';
  String agentNumber = '';
  String terminalId = '';
  String companyNumber = '';
  String serialNumber = '';
  String terminalStatus = 'Not Configured';
  String currentDate = '';
  String greeting = '';

  int totalTransactions = 0;
  int approvedCount = 0;
  int pendingCount = 0;
  int declinedCount = 0;
  bool isRefreshing = false;

  Future<void> loadSession() async {
    final session = await SessionManager.instance;
    agentFullName =
        session.agentFullName.isNotEmpty ? session.agentFullName : 'Agent';
    agentNumber = session.agentNumber ?? 'N/A';
    terminalId = session.terminalId ?? 'N/A';
    companyNumber = session.companyNumber ?? 'N/A';
    serialNumber = session.serialNumber ?? 'N/A';
    currentDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    greeting = _computeGreeting(DateTime.now().hour);
    notifyListeners();
    
    await Future.wait([
      _fetchTransactionStats(),
      _fetchTerminalDetails(),
    ]);
  }

  Future<void> refresh() async {
    isRefreshing = true;
    notifyListeners();
    await Future.wait([
      _fetchTransactionStats(),
      _fetchTerminalDetails(),
    ]);
    isRefreshing = false;
    notifyListeners();
  }

  Future<void> _fetchTerminalDetails() async {
    if (agentNumber == 'N/A' || agentNumber.isEmpty) return;

    try {
      final response = await _terminalRepo.getTerminalDetail(id: agentNumber);
      if (response.success && response.data != null) {
        final data = response.data!;
        final terminals = data['terminals'] as List?;
        if (terminals != null && terminals.isNotEmpty) {
          final terminal = TerminalModel.fromJson(terminals.first);
          terminalId = terminal.terminalId;
          serialNumber = terminal.serialNumber;
          terminalStatus = terminal.status;
          
          // Optionally update session if needed, but for dashboard display, updating VM state is enough
        }
      }
    } catch (e) {
      AppLogger.logError(_tag, 'fetchTerminalDetails error', e);
    }
    notifyListeners();
  }

  Future<void> _fetchTransactionStats() async {
    try {
      final session = await SessionManager.instance;
      final channel = session.channelNumber ?? '';

      if (channel.isEmpty) {
        AppLogger.logWarning(_tag, 'No channel number available for stats');
        return;
      }

      // Each call updates _txRepo.totalTransactions — save before next overwrites
      await _txRepo.listTransactions(channelNumber: channel, page: 1);
      totalTransactions = _txRepo.totalTransactions;

      await _txRepo.listTransactions(
          channelNumber: channel, page: 1, statusFilter: 'approved');
      approvedCount = _txRepo.totalTransactions;

      await _txRepo.listTransactions(
          channelNumber: channel, page: 1, statusFilter: 'pending');
      pendingCount = _txRepo.totalTransactions;

      await _txRepo.listTransactions(
          channelNumber: channel, page: 1, statusFilter: 'declined');
      declinedCount = _txRepo.totalTransactions;
    } catch (e) {
      AppLogger.logError(_tag, 'fetchStats error', e);
    }
  }

  String _computeGreeting(int hour) {
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final session = await SessionManager.instance;
      await session.clearSession();
      AppLogger.logInfo(_tag, 'Agent logged out');
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void navigateToVehicleSearch(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.vehicleSearch);
  }

  void navigateToScanner(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.scanner);
  }
}
