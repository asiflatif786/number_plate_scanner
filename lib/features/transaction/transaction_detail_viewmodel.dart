import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/bank_repository.dart';
import '../../data/repositories/agent_repository.dart';

class TransactionDetailViewModel extends ChangeNotifier {
  static const String _tag = 'TxDetVM';

  final TransactionRepository _repository = TransactionRepository();
  final BankRepository _bankRepo = BankRepository();
  final AgentRepository _agentRepo = AgentRepository();

  TransactionModel transaction;
  bool isVerifying = false;
  bool isProcessingPayment = false;
  bool isBankLoading = false;
  String? verifyMessage;
  String? errorMessage;

  // Bank Details for Payment
  String? bankName;
  String? accountNumber;
  String? accountName;
  String? agentWalletNumber;
  bool hasBankDetails = false;

  TransactionDetailViewModel({required this.transaction}) {
    AppLogger.logDebug(_tag, 'Init: ${transaction.transactionReference} (${transaction.status})');
    _fetchBankDetails();
    _fetchAgentWalletDetails();
  }

  Future<void> _fetchBankDetails() async {
    if (transaction.status.toLowerCase() != 'pending' && transaction.status.toLowerCase() != 'created') return;

    isBankLoading = true;
    notifyListeners();

    try {
      final session = await SessionManager.instance;
      final email = session.agentEmail;
      
      if (email != null && email.isNotEmpty) {
        final response = await _bankRepo.getCustomerDetails(email: email);
        if (response.success && response.data != null) {
          final data = response.data!;
          final dynamic bankData = data['bankAccount'] ?? data['bank_account'];
          
          if (bankData != null && bankData is Map) {
            final bankObj = bankData['bank'] as Map?;
            bankName = (bankObj?['name'] ?? bankData['bankName'] ?? 'SAFE HAVEN MFB').toString();
            accountNumber = (bankData['accountNumber'] ?? bankData['account_number'] ?? '').toString();
            accountName = (bankData['accountName'] ?? bankData['account_name'] ?? data['firstName'] ?? data['name'] ?? '').toString();
          } else {
            bankName = (data['bank_name'] ?? 'N/A').toString();
            accountNumber = (data['account_number'] ?? '').toString();
            accountName = (data['account_name'] ?? data['name'] ?? '').toString();
          }
          
          if (accountNumber != null && accountNumber!.isNotEmpty) {
            hasBankDetails = true;
          }
        }
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error fetching bank details', e);
    } finally {
      isBankLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchAgentWalletDetails() async {
    try {
      final session = await SessionManager.instance;
      
      // First try to get from session
      agentWalletNumber = session.walletNumber;
      if (agentWalletNumber != null && agentWalletNumber!.isNotEmpty) {
        notifyListeners();
      }

      final email = session.agentEmail;
      if (email != null && email.isNotEmpty) {
        final response = await _agentRepo.checkAgentExists(email);
        if (response.success && response.data != null) {
          final data = response.data!;
          final agentWallet = data['agent_wallet'];
          if (agentWallet != null && agentWallet is Map) {
            final newWalletNumber = agentWallet['wallet_number']?.toString();
            if (newWalletNumber != null && newWalletNumber != agentWalletNumber) {
              agentWalletNumber = newWalletNumber;
              await session.setWalletNumber(agentWalletNumber!);
              notifyListeners();
            }
          }
        }
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error fetching agent wallet details', e);
    }
  }

  Future<void> verifyStatus() async {
    AppLogger.logInfo(_tag, 'Verify: ${transaction.transactionReference}');
    isVerifying = true;
    verifyMessage = null;
    notifyListeners();

    final result = await _repository.verifyTransaction(
      transactionReference: transaction.transactionReference,
    );

    if (result.success && result.data != null) {
      final updated = result.data!;
      AppLogger.logInfo(_tag, 'Result: ${updated.status} (was ${transaction.status})');
      if (updated.status != transaction.status) {
        transaction = transaction.merge(updated);
        verifyMessage = 'Status updated to ${updated.status.toUpperCase()}';
        if (transaction.status.toLowerCase() != 'pending') {
          hasBankDetails = false;
        }
      } else {
        verifyMessage = 'Status confirmed: ${updated.status.toUpperCase()}';
      }
    } else {
      AppLogger.logWarning(_tag, 'Verify failed');
      verifyMessage = 'Could not verify. Check connection.';
    }

    isVerifying = false;
    notifyListeners();
  }

  Future<bool> payWithSquadCo() async {
    isProcessingPayment = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await SessionManager.instance;
      final email = transaction.customerEmail ?? session.agentEmail ?? 'customer@example.com';
      
      final response = await http.post(
        Uri.parse('https://tms-local-api.justerrand.ie/squadco/post-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (transaction.totalAmount * 100).toInt(),
          'email': email,
          'redirect_url': 'chl://payment-success',
          'metadata': {
            'transaction_reference': transaction.transactionReference,
          }
        }),
      ).timeout(const Duration(seconds: 25));

      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] != true) throw Exception(responseBody['message'] ?? 'Payment initialization failed');

      final data = responseBody['data'];
      final String checkoutUrl = (data['checkout_url'] ?? '').toString();
      
      await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isProcessingPayment = false;
      notifyListeners();
    }
  }

  Future<bool> payWithWallet() async {
    isProcessingPayment = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Strictly use agentWalletNumber for CCA transaction
      final walletToUse = agentWalletNumber;

      if (walletToUse == null || walletToUse.isEmpty) {
        errorMessage = 'Wallet number not found. Please wait for details to load or contact support.';
        isProcessingPayment = false;
        notifyListeners();
        return false;
      }

      final transactionDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
      // Payload structure aligned with the backend createCCATransaction validator
      final payload = {
        'payer_name': transaction.customerName,
        'payer_phone': transaction.customerPhone ?? '',
        'payer_email': transaction.customerEmail ?? '',
        'amount': transaction.amount,
        'fee': transaction.serviceFee,
        'payment_method': 'transfer',
        'terminal_id': transaction.terminalId,
        'vehicle_license': transaction.vehicleLicense,
        'vehicle_type': transaction.vehicleType ?? 'N/A',
        'transaction_type': transaction.transactionType.contains('single') ? 'single' : 'complete',
        'transaction_state': transaction.transactionState ?? 'Inter State',
        'transaction_ref': transaction.transactionReference, // Matches backend $request->transaction_ref
        'transaction_date': transactionDate,
        'origin_state': transaction.originState,
        'origin_lga': transaction.originLga,
        'origin_town': transaction.originTown ?? transaction.originLga, 
        'destination_state': transaction.destinationState,
        'destination_lga': transaction.destinationLga,
        'destination_town': transaction.destinationTown,
        'destination_location': transaction.destinationTown,
        'origin_location': transaction.originTown,
        'payload': transaction.rawPayload,
        'wallet_number': walletToUse,
      };

      final result = await _repository.createCcaTransaction(payload);

      if (result.success && result.data != null) {
        transaction = result.data!;
        verifyMessage = 'Wallet payment successful';
        notifyListeners();
        return true;
      } else {
        errorMessage = result.failure?.message ?? 'Wallet payment failed';
        return false;
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Wallet payment exception', e);
      errorMessage = e.toString();
      return false;
    } finally {
      isProcessingPayment = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
