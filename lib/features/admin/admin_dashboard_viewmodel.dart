import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../repositories/onboarding_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  static const String _tag = 'AdminDashVM';
  final OnboardingRepository _repository = OnboardingRepository();

  String adminName = '';
  String companyNumber = '';
  String currentDate = '';
  int totalCompanies = 0;
  bool isLoadingStats = false;

  Future<void> loadSession() async {
    final session = await SessionManager.instance;
    adminName =
        session.agentFullName.isNotEmpty ? session.agentFullName : 'Admin';
    companyNumber = session.companyNumber ?? 'N/A';
    currentDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    notifyListeners();
    
    await loadStats();
  }

  Future<void> loadStats() async {
    isLoadingStats = true;
    notifyListeners();

    try {
      final result = await _repository.getAllCompanies();
      if (result.success) {
        totalCompanies = result.data?.length ?? 0;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error loading admin stats', e);
    }

    isLoadingStats = false;
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
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }
}
