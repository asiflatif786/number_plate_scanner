import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';

class AgentDashboardViewModel extends ChangeNotifier {
  static const String _tag = 'AgentDashVM';

  String agentFullName = '';
  String agentNumber = '';
  String terminalId = '';
  String companyNumber = '';
  String serialNumber = '';
  String currentDate = '';
  String greeting = '';

  Future<void> loadSession() async {
    final session = await SessionManager.instance;
    agentFullName = session.agentFullName.isNotEmpty
        ? session.agentFullName
        : 'Agent';
    agentNumber = session.agentNumber ?? 'N/A';
    terminalId = session.terminalId ?? 'N/A';
    companyNumber = session.companyNumber ?? 'N/A';
    serialNumber = session.serialNumber ?? 'N/A';
    currentDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    greeting = _computeGreeting(DateTime.now().hour);
    notifyListeners();
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

  void navigateToTransactionHistory(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.transactionHistory);
  }

  void navigateToScanner(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.scanner);
  }
}
