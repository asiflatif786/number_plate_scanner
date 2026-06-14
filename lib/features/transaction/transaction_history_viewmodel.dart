import 'package:flutter/material.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionHistoryViewModel extends ChangeNotifier {
  static const String _tag = 'TxHistVM';

  final TransactionRepository _repository = TransactionRepository();

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  int _currentPage = 1;
  String? _selectedStatusFilter;
  String _searchQuery = '';
  String? _verifyingReference;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  String? get selectedStatusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;
  String? get verifyingReference => _verifyingReference;
  bool get hasMorePages => _currentPage < _repository.totalPages;
  int get totalTransactions => _repository.totalTransactions;

  List<TransactionModel> get filteredTransactions {
    if (_searchQuery.isEmpty) return _transactions;
    final q = _searchQuery.toLowerCase();
    return _transactions.where((t) {
      return t.transactionReference.toLowerCase().contains(q) ||
          t.customerName.toLowerCase().contains(q) ||
          t.vehicleLicense.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    final session = await SessionManager.instance;
    final channelNumber = session.channelNumber;
    if (channelNumber == null) {
      _errorMessage = 'Channel number not configured. Please contact admin.';
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
      return;
    }

    if (refresh) {
      _transactions = [];
      _currentPage = 1;
      _isRefreshing = true;
    } else if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.listTransactions(
      channelNumber: channelNumber,
      page: _currentPage,
      statusFilter: _selectedStatusFilter,
    );

    if (result.success) {
      if (refresh || _currentPage == 1) {
        _transactions = result.data ?? [];
      } else {
        _transactions.addAll(result.data ?? []);
      }
      _currentPage++;
    } else {
      _errorMessage = result.failure?.message ?? 'Failed to load transactions';
      AppLogger.logWarning(_tag, _errorMessage!);
    }

    _isLoading = false;
    _isLoadingMore = false;
    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!hasMorePages || _isLoadingMore) return;
    await loadTransactions();
  }

  Future<void> onRefresh() async {
    await loadTransactions(refresh: true);
  }

  void onStatusFilterChanged(String? status) {
    _selectedStatusFilter = status;
    loadTransactions(refresh: true);
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> verifyTransaction(String transactionReference) async {
    final session = await SessionManager.instance;
    final channelNumber = session.channelNumber;
    if (channelNumber == null) return;

    _verifyingReference = transactionReference;
    notifyListeners();

    final result = await _repository.verifyTransaction(
      transactionReference: transactionReference,
      channelNumber: channelNumber,
    );

    if (result.success && result.data != null) {
      final updated = result.data!;
      final index =
          _transactions.indexWhere((t) => t.transactionReference == transactionReference);
      if (index != -1) {
        _transactions[index] = _transactions[index].copyWith(status: updated.status);
      }
    }

    _verifyingReference = null;
    notifyListeners();
  }

  Future<void> abandonTransaction(String transactionReference, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandon Transaction'),
        content: const Text(
          'Are you sure you want to abandon this transaction? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final session = await SessionManager.instance;
    final channelNumber = session.channelNumber;
    if (channelNumber == null) return;

    final result = await _repository.abandonTransaction(
      transactionReference: transactionReference,
      channelNumber: channelNumber,
    );

    if (result.success) {
      _transactions.removeWhere((t) => t.transactionReference == transactionReference);
      notifyListeners();
    } else {
      _errorMessage = result.failure?.message ?? 'Failed to abandon transaction';
      notifyListeners();
    }
  }
}
