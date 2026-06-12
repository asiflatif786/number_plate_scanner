import 'package:flutter/material.dart';

import '../../data/local/transaction_log_store.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../app/routes.dart';

enum PaymentProcessingState { processing, success, failed }

class PaymentProcessingViewModel extends ChangeNotifier {
  final TransactionModel pendingTransaction;
  final TransactionRepository _repository = TransactionRepository();
  final TransactionLogStore _logStore = TransactionLogStore();

  late TransactionModel transaction;
  PaymentProcessingState processingState =
      PaymentProcessingState.processing;
  String? errorMessage;

  PaymentProcessingViewModel({required this.pendingTransaction})
      : transaction = pendingTransaction;

  Future<void> init() async {
    processingState = PaymentProcessingState.processing;
    errorMessage = null;
    notifyListeners();

    // TODO: integrate real payment SDK
    await Future.delayed(const Duration(seconds: 2));

    final paymentSuccessful = true;

    if (paymentSuccessful) {
      final result = await _repository
          .approveTransaction(transaction.transactionReference);

      if (result.success) {
        transaction = transaction.copyWith(status: 'approved');
        processingState = PaymentProcessingState.success;
      } else {
        errorMessage =
            'Payment succeeded but approval failed. Contact support with ref: ${transaction.transactionReference}';
        processingState = PaymentProcessingState.failed;
      }
    } else {
      await _repository
          .declineTransaction(transaction.transactionReference);
      transaction = transaction.copyWith(status: 'declined');
      processingState = PaymentProcessingState.failed;
      errorMessage = 'Payment was not completed. Please try again.';
    }

    await _logStore.saveTransaction(transaction);
    notifyListeners();
  }

  void proceedToReceipt(BuildContext context) {
    if (processingState != PaymentProcessingState.success) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.transactionSuccess,
      arguments: transaction,
    );
  }

  void retryPayment() {
    if (processingState != PaymentProcessingState.failed) return;
    init();
  }

  void cancelAndGoBack(BuildContext context) {
    if (processingState != PaymentProcessingState.failed) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.agentDashboard,
      (route) => false,
    );
  }
}
