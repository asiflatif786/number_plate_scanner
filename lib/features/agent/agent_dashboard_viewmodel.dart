import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/terminal_repository.dart';
import '../../data/repositories/bank_repository.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/models/terminal_model.dart';

class AgentDashboardViewModel extends ChangeNotifier {
  static const String _tag = 'AgentDashVM';

  final TransactionRepository _txRepo = TransactionRepository();
  final TerminalRepository _terminalRepo = TerminalRepository();
  final BankRepository _bankRepo = BankRepository();
  final AgentRepository _agentRepo = AgentRepository();

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
  String agentWalletNumber = '';
  String paymentStatus = 'INACTIVE';
  double walletBalance = 0.0;
  bool hasBankDetails = false;
  bool isBankLoading = false;
  String? bankErrorMessage;

  int totalTransactions = 0;
  int approvedCount = 0;
  int pendingCount = 0;
  int declinedCount = 0;
  bool isRefreshing = false;

  String get formattedWalletBalance =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 2).format(walletBalance);

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
      
      // Load details sequentially
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
    String? email = session.agentEmail;
    
    // Recovery Logic: If email is missing, recover it using agentNumber
    if ((email == null || email.isEmpty) && agentNumber != 'N/A' && agentNumber.isNotEmpty) {
      AppLogger.logInfo(_tag, 'Email missing in session for agent $agentNumber. Attempting recovery from profile...');
      try {
        final agentRes = await _agentRepo.getAgent(agentNumber: agentNumber);
        if (agentRes.success && agentRes.data != null) {
          email = agentRes.data!.email;
          if (email.isNotEmpty) {
            await session.setAgentEmail(email);
            AppLogger.logInfo(_tag, 'Successfully recovered agent email: $email');
          }
        }
      } catch (e) {
        AppLogger.logWarning(_tag, 'Email recovery from agent profile failed: $e');
      }
    }

    if (email == null || email.isEmpty) {
      AppLogger.logWarning(_tag, 'Bank fetch aborted: email and agentNumber are both missing from session (or recovery failed). Please re-login.');
      hasBankDetails = false;
      bankErrorMessage = 'Account session incomplete. Please log out and back in.';
      notifyListeners();
      return;
    }

    isBankLoading = true;
    bankErrorMessage = null;
    notifyListeners();

    try {
      AppLogger.logInfo(_tag, 'Fetching bank details for: $email');
      
      // Check agent existence to get wallet number
      final existRes = await _agentRepo.checkAgentExists(email);
      if (existRes.success && existRes.data != null) {
        final walletData = existRes.data!['agent_wallet'];
        if (walletData != null && walletData is Map) {
          agentWalletNumber = walletData['wallet_number']?.toString() ?? '';
          if (agentWalletNumber.isNotEmpty) {
            await session.setWalletNumber(agentWalletNumber);
          }
        }
      }

      final response = await _bankRepo.getCustomerDetails(email: email);
      
      if (response.success && response.data != null) {
        final data = response.data!;
        
        // Handle the specific data structure provided: data -> bankAccount -> bank
        final dynamic bankData = data['bankAccount'] ?? data['bank_account'];
        
        if (bankData != null && bankData is Map) {
          final bankObj = bankData['bank'] as Map?;
          bankName = (bankObj?['name'] ?? bankData['bankName'] ?? 'SAFE HAVEN MFB').toString();
          accountNumber = (bankData['accountNumber'] ?? bankData['account_number'] ?? 'Not Generated').toString();
          accountName = (bankData['accountName'] ?? bankData['account_name'] ?? data['firstName'] ?? data['name'] ?? 'N/A').toString();
          paymentStatus = (bankData['status'] ?? data['status'] ?? 'INACTIVE').toString().toUpperCase();
          
          // Extract balance
          final dynamic bal = bankData['balance'] ?? 0;
          if (bal is num) {
            walletBalance = bal.toDouble();
          } else if (bal is String) {
            walletBalance = double.tryParse(bal.replaceAll(',', '')) ?? 0.0;
          }
        } else {
          bankName = (data['bank_name'] ?? 'N/A').toString();
          accountNumber = (data['account_number'] ?? 'Not Generated').toString();
          accountName = (data['account_name'] ?? data['name'] ?? 'N/A').toString();
          paymentStatus = (data['status'] ?? 'INACTIVE').toString().toUpperCase();
        }
        
        hasBankDetails = true;
        AppLogger.logInfo(_tag, 'Bank details loaded: $accountNumber at $bankName, Status: $paymentStatus, Wallet: $agentWalletNumber, Balance: $walletBalance');
      } else {
        bankErrorMessage = response.message ?? 'Banking profile not found.';
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
