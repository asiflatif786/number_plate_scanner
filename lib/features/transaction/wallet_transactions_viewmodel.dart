import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/wallet_transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class WalletTransactionsViewModel extends ChangeNotifier {
  static const String _tag = 'WalletTxVM';
  final TransactionRepository _repository = TransactionRepository();

  List<WalletTransactionModel> transactions = [];
  bool isLoading = false;
  String? errorMessage;

  WalletTransactionsViewModel() {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await SessionManager.instance;
      final walletNumber = session.walletNumber;

      if (walletNumber == null || walletNumber.isEmpty) {
        errorMessage = 'Wallet number not found. Please ensure you are fully registered.';
        isLoading = false;
        notifyListeners();
        return;
      }

      final result = await _repository.getCcaWalletTransactions(
        walletNumber: walletNumber,
      );

      if (result.success && result.data != null) {
        transactions = result.data!;
      } else {
        errorMessage = result.failure?.message ?? 'Failed to load transactions';
      }
    } catch (e) {
      AppLogger.logError(_tag, 'Error fetching wallet transactions', e);
      errorMessage = 'An unexpected error occurred';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
