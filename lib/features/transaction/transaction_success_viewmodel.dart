import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/session/session_manager.dart';
import '../../app/routes.dart';
import '../../core/utils/logger.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionSuccessViewModel extends ChangeNotifier {
  static const String _tag = 'TxSuccessVM';

  TransactionModel transaction;

  bool isApproving = false;
  bool isDeclining = false;
  bool isVerifying = false;
  bool isCopied = false;
  bool isSharing = false;
  String? statusMessage;

  TransactionSuccessViewModel({required this.transaction}) {
    AppLogger.logInfo(_tag,
        'Showing receipt: ${transaction.transactionReference} (${transaction.status})');
  }

  String _buildReceiptText() {
    final t = transaction;
    final sb = StringBuffer();
    sb.writeln('══════════════════════════════════════');
    sb.writeln('   CONSOLIDATED HAULAGE LEVY — RECEIPT');
    sb.writeln('══════════════════════════════════════');
    sb.writeln();
    sb.writeln('Transaction Ref:  ${t.transactionReference}');
    sb.writeln('Status:           ${t.status.toUpperCase()}');
    sb.writeln('Date:             ${t.createdAt}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('CUSTOMER DETAILS');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Name:             ${t.customerName}');
    sb.writeln('Vehicle:          ${t.vehicleLicense}');
    final tripType =
        t.transactionType == 'single' ? 'Single Trip' : 'Complete Trip';
    sb.writeln('Trip Type:        $tripType');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('ROUTE');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('From:  ${t.originLga}, ${t.originState}');
    sb.writeln('To:    ${t.destinationLga}, ${t.destinationState}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('PAYMENT');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Base Amount:      ${t.formattedAmount}');
    sb.writeln('Service Fee:      ${t.formattedServiceFee}');
    sb.writeln('Total Paid:       ${t.formattedTotal}');
    sb.writeln('Method:           ${t.paymentMethodDisplay}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('PROCESSED BY');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Agent:            ${t.agentNumber}');
    sb.writeln('Terminal:         ${t.terminalId}');
    sb.writeln('──────────────────────────────────────');
    sb.writeln();
    sb.writeln(' Thank you for using Consolidated Haulage Levy');
    return sb.toString();
  }

  Future<void> copyReceipt() async {
    try {
      await Clipboard.setData(ClipboardData(text: _buildReceiptText()));
      isCopied = true;
      AppLogger.logDebug(_tag, 'Receipt copied');
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 2500));
      isCopied = false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> shareReceipt() async {
    try {
      isSharing = true;
      notifyListeners();
      AppLogger.logDebug(_tag, 'Sharing receipt');
      await Share.share(
        _buildReceiptText(),
        subject: 'Consolidated Haulage Levy Receipt - ${transaction.transactionReference}',
      );
    } catch (_) {}
    isSharing = false;
    notifyListeners();
  }

  Future<void> approveTransaction() async {
    isApproving = true;
    statusMessage = null;
    notifyListeners();
    try {
      final session = await SessionManager.instance;
      final channelNumber = session.channelNumber ?? '';
      final response = await TransactionRepository().approveTransaction(
        transactionReference: transaction.transactionReference,
        channelNumber: channelNumber,
      );
      if (response.success) {
        transaction = transaction.copyWith(status: 'approved');
        statusMessage = 'Transaction approved.';
        AppLogger.logInfo(_tag, '[SUCCESS] Transaction approved');
      } else {
        statusMessage = response.failure?.message ?? 'Approval failed.';
        AppLogger.logError(
            _tag, 'Approval failed: ${response.failure?.message}');
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Approval error', e);
    }
    isApproving = false;
    notifyListeners();
  }

  Future<void> declineTransaction() async {
    isDeclining = true;
    statusMessage = null;
    notifyListeners();
    try {
      final session = await SessionManager.instance;
      final channelNumber = session.channelNumber ?? '';
      final response = await TransactionRepository().declineTransaction(
        transactionReference: transaction.transactionReference,
        channelNumber: channelNumber,
      );
      if (response.success) {
        transaction = transaction.copyWith(status: 'declined');
        statusMessage = 'Transaction declined.';
        AppLogger.logInfo(_tag, '[SUCCESS] Transaction declined');
      } else {
        statusMessage = response.failure?.message ?? 'Decline failed.';
        AppLogger.logError(
            _tag, 'Decline failed: ${response.failure?.message}');
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Decline error', e);
    }
    isDeclining = false;
    notifyListeners();
  }

  Future<void> verifyTransaction() async {
    isVerifying = true;
    statusMessage = null;
    notifyListeners();
    try {
      final session = await SessionManager.instance;
      final channelNumber = session.channelNumber ?? '';
      final response = await TransactionRepository().verifyTransaction(
        transactionReference: transaction.transactionReference,
        channelNumber: channelNumber,
      );
      if (response.success && response.data != null) {
        final verified = response.data!;
        transaction = verified.transactionReference.isEmpty
            ? transaction.copyWith(status: verified.status)
            : verified;
        statusMessage = 'Verified: ${transaction.status.toUpperCase()}';
        AppLogger.logInfo(_tag, '[SUCCESS] Transaction verified');
      } else {
        statusMessage = response.failure?.message ?? 'Verification failed.';
        AppLogger.logError(
            _tag, 'Verification failed: ${response.failure?.message}');
      }
    } catch (e) {
      statusMessage = 'Verification error. Please try again.';
      AppLogger.logError(_tag, 'Verification error', e);
    }
    isVerifying = false;
    notifyListeners();
  }

  void newTransaction(BuildContext context) {
    AppLogger.logDebug(_tag, '→ new transaction');
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.vehicleSearch,
      ModalRoute.withName(AppRoutes.agentDashboard),
    );
  }

  void goToDashboard(BuildContext context) {
    AppLogger.logDebug(_tag, '→ dashboard');
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.agentDashboard,
      (route) => false,
    );
  }
}
