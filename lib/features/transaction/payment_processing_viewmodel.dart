import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/local/transaction_log_store.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

enum PaymentProcessingState { processing, success, failed }

class PaymentProcessingViewModel extends ChangeNotifier {
  static const String _tag = 'PayProcVM';

  final TransactionModel pendingTransaction;
  final TransactionRepository _repository = TransactionRepository();
  final TransactionLogStore _logStore = TransactionLogStore();

  late TransactionModel transaction;
  PaymentProcessingState processingState =
      PaymentProcessingState.processing;
  String? errorMessage;

  PaymentProcessingViewModel({required this.pendingTransaction})
      : transaction = pendingTransaction {
    AppLogger.logDebug(_tag, 'Init ref: ${pendingTransaction.transactionReference}');
  }

  Future<void> init() async {
    AppLogger.logInfo(_tag, 'Processing ${transaction.transactionReference}');

    processingState = PaymentProcessingState.processing;
    errorMessage = null;
    notifyListeners();

    // TODO: integrate real payment SDK
    await Future.delayed(const Duration(seconds: 2));

    const paymentSuccessful = true;

    if (paymentSuccessful) {
      AppLogger.logInfo(_tag, 'Payment OK → approving');
      final session = await SessionManager.instance;
      final channelNumber = session.channelNumber ?? '';
      final result = await _repository.approveTransaction(
        transactionReference: transaction.transactionReference,
        channelNumber: channelNumber,
      );

      if (result.success) {
        AppLogger.logInfo(_tag, 'Approved');
        transaction = transaction.copyWith(status: 'approved');
        processingState = PaymentProcessingState.success;
      } else {
        AppLogger.logWarning(_tag, 'Approval failed: ${result.failure?.message}');
        errorMessage =
            'Payment succeeded but approval failed. Contact support with ref: ${transaction.transactionReference}';
        processingState = PaymentProcessingState.failed;
      }
    } else {
      AppLogger.logInfo(_tag, 'Payment failed → declining');
      final session = await SessionManager.instance;
      final channelNumber = session.channelNumber ?? '';
      await _repository.declineTransaction(
        transactionReference: transaction.transactionReference,
        channelNumber: channelNumber,
      );
      transaction = transaction.copyWith(status: 'declined');
      processingState = PaymentProcessingState.failed;
      errorMessage = 'Payment was not completed. Please try again.';
    }

    AppLogger.logInfo(_tag, 'Saving to local log');
    await _logStore.saveTransaction(transaction);
    AppLogger.logDebug(_tag, 'Saved, final state=$processingState');
    notifyListeners();
  }

  void proceedToReceipt(BuildContext context) {
    if (processingState != PaymentProcessingState.success) return;
    AppLogger.logDebug(_tag, '→ receipt');
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.transactionSuccess,
      arguments: transaction,
    );
  }

  void retryPayment() {
    if (processingState != PaymentProcessingState.failed) return;
    AppLogger.logDebug(_tag, 'retry');
    init();
  }

  void cancelAndGoBack(BuildContext context) {
    if (processingState != PaymentProcessingState.failed) return;
    AppLogger.logDebug(_tag, 'cancel → dashboard');
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.agentDashboard,
      (route) => false,
    );
  }
}
