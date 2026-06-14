import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionDetailViewModel extends ChangeNotifier {
  static const String _tag = 'TxDetVM';

  final TransactionRepository _repository = TransactionRepository();

  TransactionModel transaction;
  bool isVerifying = false;
  String? verifyMessage;

  TransactionDetailViewModel({required this.transaction}) {
    AppLogger.logDebug(_tag, 'Init: ${transaction.transactionReference} (${transaction.status})');
  }

  Future<void> verifyStatus() async {
    AppLogger.logInfo(_tag, 'Verify: ${transaction.transactionReference}');
    isVerifying = true;
    verifyMessage = null;
    notifyListeners();

    final session = await SessionManager.instance;
    final channelNumber = session.channelNumber;
    if (channelNumber == null) {
      verifyMessage = 'Channel number not configured.';
      isVerifying = false;
      notifyListeners();
      return;
    }

    final result = await _repository.verifyTransaction(
      transactionReference: transaction.transactionReference,
      channelNumber: channelNumber,
    );

    if (result.success && result.data != null) {
      final updated = result.data!;
      AppLogger.logInfo(_tag, 'Result: ${updated.status} (was ${transaction.status})');
      if (updated.status != transaction.status) {
        transaction = transaction.copyWith(status: updated.status);
        verifyMessage = 'Status updated to ${updated.status.toUpperCase()}';
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
}
