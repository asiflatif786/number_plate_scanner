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
    
    // First fetch terminal details to ensure we have the correct terminalId
    await _fetchTerminalDetails();
    // Then fetch stats using that terminalId
    await _fetchTransactionStats();
  }

  Future<void> refresh() async {
    isRefreshing = true;
    notifyListeners();
    await _fetchTerminalDetails();
    await _fetchTransactionStats();
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
          
          // Persist to session so it's available for transactions
          final session = await SessionManager.instance;
          await session.setTerminalId(terminalId);
          await session.setSerialNumber(serialNumber);
          
          AppLogger.logInfo(_tag, 'Terminal details synced: $terminalId');
        }
      }
    } catch (e) {
      AppLogger.logError(_tag, 'fetchTerminalDetails error', e);
    }
    notifyListeners();
  }

  Future<void> _fetchTransactionStats() async {
    if (terminalId == 'N/A' || terminalId.isEmpty) {
       AppLogger.logWarning(_tag, 'Cannot fetch stats: terminalId is empty');
       return;
    }

    try {
      final response = await _txRepo.getTransactionStats(terminalId: terminalId);
      if (response.success && response.data != null) {
        final data = response.data!;
        totalTransactions = _parseInt(data['total_transactions']);
        approvedCount = _parseInt(data['approved_transactions']);
        declinedCount = _parseInt(data['declined_transactions']);
        pendingCount = _parseInt(data['pending_transactions']);
        
        AppLogger.logInfo(_tag, 'Stats updated: T:$totalTransactions A:$approvedCount P:$pendingCount D:$declinedCount');
      }
    } catch (e) {
      AppLogger.logError(_tag, 'fetchStats error', e);
    }
    notifyListeners();
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
