import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/utils/logger.dart';
import '../../data/local/transaction_log_store.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionHistoryViewModel extends ChangeNotifier {
  static const String _tag = 'TxHistVM';

  final TransactionRepository _repository = TransactionRepository();
  final TransactionLogStore _logStore = TransactionLogStore();

  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filteredTransactions = [];
  bool isLoading = false;
  String? errorMessage;

  String? selectedStatus;
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = '';

  Future<void> loadInitial() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      allTransactions = await _logStore.getAll();
      AppLogger.logInfo(_tag, 'Loaded ${allTransactions.length} from local log');
      _applyFilters();
    } catch (e) {
      AppLogger.logWarning(_tag, 'Load error: $e');
      errorMessage = 'Failed to load transaction history';
      allTransactions = [];
      filteredTransactions = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    AppLogger.logDebug(_tag, 'Refresh');
    await loadInitial();
  }

  void _applyFilters() {
    var result = List<TransactionModel>.from(allTransactions);

    if (selectedStatus != null) {
      result = result.where((t) => t.status == selectedStatus).toList();
    }

    if (startDate != null) {
      result = result.where((t) {
        final dt = DateTime.tryParse(t.createdAt);
        return dt != null && !dt.isBefore(startDate!);
      }).toList();
    }

    if (endDate != null) {
      final endEndOfDay = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);
      result = result.where((t) {
        final dt = DateTime.tryParse(t.createdAt);
        return dt != null && !dt.isAfter(endEndOfDay);
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result.where((t) {
        return t.vehicleLicense.toLowerCase().contains(q) ||
            t.customerName.toLowerCase().contains(q);
      }).toList();
    }

    AppLogger.logDebug(_tag, 'Filters: status=$selectedStatus, search="$searchQuery" → ${result.length} results');
    filteredTransactions = result;
    notifyListeners();
  }

  void onStatusFilterChanged(String? status) {
    AppLogger.logDebug(_tag, 'Status filter: $status');
    selectedStatus = status;
    _applyFilters();
  }

  void onDateRangeChanged(DateTime? start, DateTime? end) {
    AppLogger.logDebug(_tag, 'Date range: ${start?.toIso8601String()} ~ ${end?.toIso8601String()}');
    startDate = start;
    endDate = end;
    _applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    AppLogger.logDebug(_tag, 'Clear filters');
    selectedStatus = null;
    startDate = null;
    endDate = null;
    searchQuery = '';
    _applyFilters();
  }

  void onTransactionTapped(
      BuildContext context, TransactionModel transaction) {
    AppLogger.logDebug(_tag, '→ detail: ${transaction.transactionReference}');
    Navigator.pushNamed(
      context,
      AppRoutes.transactionDetail,
      arguments: transaction,
    );
  }

  Future<void> verifyStatus(
      BuildContext context, TransactionModel transaction) async {
    AppLogger.logInfo(_tag, 'Verify: ${transaction.transactionReference}');
    final result = await _repository
        .verifyTransaction(transaction.transactionReference);

    if (!context.mounted) return;

    if (result.success && result.data != null) {
      final v = result.data!;
      AppLogger.logInfo(_tag, 'Verify result: ${v.status} (was ${transaction.status})');
      if (v.status != transaction.status) {
        await _logStore.updateStatus(
            transaction.transactionReference, v.status);
        AppLogger.logDebug(_tag, 'Status updated in log');
        await loadInitial();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Status updated: ${v.status.toUpperCase()}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Status unchanged: ${v.status.toUpperCase()}')),
        );
      }
    } else {
      AppLogger.logWarning(_tag, 'Verify failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Could not verify status. Check connection.')),
      );
    }
  }
}
