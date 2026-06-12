import 'package:flutter/material.dart';

import '../../data/local/transaction_log_store.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionDetailViewModel extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  final TransactionLogStore _logStore = TransactionLogStore();

  TransactionModel transaction;
  bool isVerifying = false;
  String? verifyMessage;

  TransactionDetailViewModel({required this.transaction});

  Future<void> verifyStatus() async {
    isVerifying = true;
    verifyMessage = null;
    notifyListeners();

    final result =
        await _repository.verifyTransaction(transaction.transactionReference);

    if (result.success && result.data != null) {
      final v = result.data!;
      if (v.status != transaction.status) {
        await _logStore.updateStatus(
            transaction.transactionReference, v.status);
        transaction = transaction.copyWith(status: v.status);
        verifyMessage = 'Status updated to ${v.status.toUpperCase()}';
      } else {
        verifyMessage = 'Status confirmed: ${v.status.toUpperCase()}';
      }
    } else {
      verifyMessage = 'Could not verify. Check connection.';
    }

    isVerifying = false;
    notifyListeners();
  }
}
