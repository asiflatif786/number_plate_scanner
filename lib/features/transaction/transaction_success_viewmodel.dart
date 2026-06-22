import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/routes.dart';
import '../../core/utils/logger.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionSuccessViewModel extends ChangeNotifier {
  static const String _tag = 'TxSuccessVM';

  /// Static reference to the active instance to allow global signaling
  static TransactionSuccessViewModel? _activeInstance;

  TransactionModel transaction;

  bool isApproving = false;
  bool isDeclining = false;
  bool isVerifying = false;
  bool isCopied = false;
  bool isSharing = false;
  
  /// Flag set when returning specifically from the payment success redirect
  bool isPaymentRedirected = false; 
  String? statusMessage;

  TransactionSuccessViewModel({required this.transaction}) {
    _activeInstance = this;
    AppLogger.logInfo(_tag,
        'Showing receipt: ${transaction.transactionReference} (${transaction.status})');
  }

  /// Global signal that the app has received a payment success redirect.
  /// Called by the deep-link route handler.
  static void signalPaymentSuccess() {
    AppLogger.logInfo(_tag, 'Global payment success signal received');
    _activeInstance?._handlePaymentRedirect();
  }

  void _handlePaymentRedirect() {
    isPaymentRedirected = true;
    statusMessage = 'Payment successful! Please click Approve to finalize.';
    notifyListeners();
    // Auto-verify to sync with server status immediately
    verifyTransaction();
  }

  @override
  void dispose() {
    if (_activeInstance == this) {
      _activeInstance = null;
    }
    super.dispose();
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
      final response = await TransactionRepository().approveTransaction(
        transactionReference: transaction.transactionReference,
      );
      if (response.success) {
        transaction = transaction.copyWith(status: 'confirmed');
        statusMessage = response.message ?? 'Transaction approved and confirmed successfully!';
        AppLogger.logInfo(_tag, '[SUCCESS] Transaction approved');
      } else {
        statusMessage = response.failure?.message ?? 'Approval failed.';
        AppLogger.logError(
            _tag, 'Approval failed: ${response.failure?.message}');
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Approval error', e);
      statusMessage = 'Error during approval: $e';
    }
    isApproving = false;
    notifyListeners();
  }

  Future<void> declineTransaction() async {
    isDeclining = true;
    statusMessage = null;
    notifyListeners();
    try {
      final response = await TransactionRepository().declineTransaction(
        transactionReference: transaction.transactionReference,
      );
      if (response.success) {
        transaction = transaction.copyWith(status: 'declined');
        statusMessage = response.message ?? 'Transaction declined!';
        AppLogger.logInfo(_tag, '[SUCCESS] Transaction declined');
      } else {
        statusMessage = response.failure?.message ?? 'Decline failed.';
        AppLogger.logError(
            _tag, 'Decline failed: ${response.failure?.message}');
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Decline error', e);
      statusMessage = 'Error during decline: $e';
    }
    isDeclining = false;
    notifyListeners();
  }

  Future<void> verifyTransaction() async {
    isVerifying = true;
    statusMessage = null;
    notifyListeners();
    try {
      final response = await TransactionRepository().verifyTransaction(
        transactionReference: transaction.transactionReference,
      );
      if (response.success && response.data != null) {
        final verified = response.data!;
        // Use merge to preserve local form data and only update status/ref
        transaction = transaction.merge(verified);
        
        final status = transaction.status.toLowerCase();
        if (status == 'approved' || status == 'paid' || status == 'success' || status == 'successful') {
          statusMessage = 'Payment Detected! You can now finalize the transaction.';
        } else if (status == 'confirmed') {
          statusMessage = 'Transaction has already been confirmed.';
        } else {
          statusMessage = 'Payment status: ${transaction.status.toUpperCase()}';
        }
        AppLogger.logInfo(_tag, '[SUCCESS] Transaction verified: ${transaction.status}');
      } else {
        statusMessage = 'Payment not yet detected. Please wait a moment and try again.';
        AppLogger.logWarning(_tag, 'Verification returned no data or failed');
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
