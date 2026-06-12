import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  static const String _tag = 'AdminDashVM';

  String adminName = '';
  String companyNumber = '';
  String currentDate = '';

  Future<void> loadSession() async {
    final session = await SessionManager.instance;
    adminName = session.agentFullName.isNotEmpty
        ? session.agentFullName
        : 'Admin';
    companyNumber = session.companyNumber ?? 'N/A';
    currentDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
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
      AppLogger.logInfo(_tag, 'Admin logged out');
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
