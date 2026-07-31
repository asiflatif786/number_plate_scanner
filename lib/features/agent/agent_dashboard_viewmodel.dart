import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/terminal_repository.dart';
import '../../data/repositories/bank_repository.dart';
import '../../data/models/terminal_model.dart';

class AgentDashboardViewModel extends ChangeNotifier {
  static const String _tag = 'AgentDashVM';

  final TransactionRepository _txRepo = TransactionRepository();
  final TerminalRepository _terminalRepo = TerminalRepository();
  final BankRepository _bankRepo = BankRepository();

  String agentFullName = '';
  String agentNumber = '';
  String terminalId = '';
  String companyNumber = '';
  String serialNumber = '';
  String terminalStatus = 'Not Configured';
  String currentDate = '';
  String greeting = '';

  // Bank Details
  String bankName = '';
  String accountNumber = '';
  String accountName = '';
  bool hasBankDetails = false;
  bool isBankLoading = false;
  String? bankErrorMessage;

  int totalTransactions = 0;
  int approvedCount = 0;
  int pendingCount = 0;
  int declinedCount = 0;
  bool isRefreshing = false;

  Future<void> loadSession() async {
    try {
      final session = await SessionManager.instance;
      agentFullName = session.agentFullName.isNotEmpty ? session.agentFullName : 'Agent';
      agentNumber = session.agentNumber ?? 'N/A';
      terminalId = session.terminalId ?? 'N/A';
      companyNumber = session.companyNumber ?? 'N/A';
      serialNumber = session.serialNumber ?? 'N/A';
      currentDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
      greeting = _computeGreeting(DateTime.now().hour);
      notifyListeners();
      
      // Load details sequentially with individual error handling
      await _fetchTerminalDetails();
      await _fetchTransactionStats();
      await _fetchBankDetails();
    } catch (e) {
      AppLogger.logError(_tag, 'loadSession error', e);
    }
  }

  Future<void> refresh() async {
    isRefreshing = true;
    notifyListeners();
    try {
      // Refreshing all details
      await _fetchTerminalDetails();
      await _fetchTransactionStats();
      await _fetchBankDetails();
    } catch (e) {
      AppLogger.logError(_tag, 'refresh error', e);
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> _fetchTerminalDetails() async {
    if (agentNumber == 'N/A' || agentNumber.isEmpty) return;
    try {
      final response = await _terminalRepo.getTerminalDetail(id: agentNumber);
      if (response.success && response.data != null) {
        final terminals = response.data!['terminals'] as List?;
        if (terminals != null && terminals.isNotEmpty) {
          final terminal = TerminalModel.fromJson(terminals.first);
          terminalId = terminal.terminalId;
          serialNumber = terminal.serialNumber;
          terminalStatus = terminal.status;
          
          final session = await SessionManager.instance;
          await session.setTerminalId(terminalId);
          await session.setSerialNumber(serialNumber);
          AppLogger.logDebug(_tag, 'Terminal synced: $terminalId');
        }
      }
    } catch (e) {
      AppLogger.logError(_tag, 'fetchTerminalDetails error', e);
    }
    notifyListeners();
  }

  Future<void> _fetchBankDetails() async {
    final session = await SessionManager.instance;
    final email = session.agentEmail;
    
    if (email == null || email.isEmpty) {
      AppLogger.logWarning(_tag, 'Bank fetch aborted: email is empty in session');
      hasBankDetails = false;
      bankErrorMessage = 'Agent email not found. Please re-login.';
      notifyListeners();
      return;
    }

    isBankLoading = true;
    bankErrorMessage = null;
    notifyListeners();

    try {
      AppLogger.logInfo(_tag, 'Fetching bank details for email: $email');
      final response = await _bankRepo.getCustomerDetails(email: email);
      
      if (response.success && response.data != null) {
        final data = response.data!;
        
        // Robust mapping for different API response structures
        bankName = (data['bank_name'] ?? data['BankName'])?.toString() ?? 'N/A';
        accountNumber = (data['account_number'] ?? data['AccountNumber'])?.toString() ?? 'Not Generated';
        accountName = (data['account_name'] ?? data['AccountName'] ?? data['name'])?.toString() ?? 'N/A';
        
        // We set hasBankDetails to true if we got a successful response with data
        // even if account number isn't fully ready yet.
        hasBankDetails = data.isNotEmpty;
        
        AppLogger.logInfo(_tag, 'Bank details loaded: $accountNumber ($bankName)');
      } else {
        bankErrorMessage = response.message ?? 'Bank account details not found.';
        hasBankDetails = false;
        AppLogger.logWarning(_tag, 'Bank API returned failure: ${response.message}');
      }
    } catch (e) {
      AppLogger.logError(_tag, 'fetchBankDetails exception', e);
      bankErrorMessage = 'Unable to load banking details.';
      hasBankDetails = false;
    } finally {
      isBankLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchTransactionStats() async {
    if (terminalId == 'N/A' || terminalId.isEmpty) return;
    try {
      final response = await _txRepo.getTransactionStats(terminalId: terminalId);
      if (response.success && response.data != null) {
        final data = response.data!;
        totalTransactions = _parseInt(data['total_transactions']);
        approvedCount = _parseInt(data['approved_transactions']);
        declinedCount = _parseInt(data['declined_transactions']);
        pendingCount = _parseInt(data['pending_transactions']);
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm == true) {
      final session = await SessionManager.instance;
      await session.clearSession();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void navigateToVehicleSearch(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.paymentTypeSelection);
  }
}
