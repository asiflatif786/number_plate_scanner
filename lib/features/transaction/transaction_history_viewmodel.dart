import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/local/transaction_log_store.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionHistoryViewModel extends ChangeNotifier {
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
      _applyFilters();
    } catch (_) {
      errorMessage = 'Failed to load transaction history';
      allTransactions = [];
      filteredTransactions = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
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

    filteredTransactions = result;
    notifyListeners();
  }

  void onStatusFilterChanged(String? status) {
    selectedStatus = status;
    _applyFilters();
  }

  void onDateRangeChanged(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    _applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void clearFilters() {
    selectedStatus = null;
    startDate = null;
    endDate = null;
    searchQuery = '';
    _applyFilters();
  }

  void onTransactionTapped(
      BuildContext context, TransactionModel transaction) {
    Navigator.pushNamed(
      context,
      AppRoutes.transactionDetail,
      arguments: transaction,
    );
  }

  Future<void> verifyStatus(
      BuildContext context, TransactionModel transaction) async {
    final result = await _repository
        .verifyTransaction(transaction.transactionReference);

    if (!context.mounted) return;

    if (result.success && result.data != null) {
      final v = result.data!;
      if (v.status != transaction.status) {
        await _logStore.updateStatus(
            transaction.transactionReference, v.status);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Could not verify status. Check connection.')),
      );
    }
  }
}
