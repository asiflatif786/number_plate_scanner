import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

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
  
  // Bluetooth Printing
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> devices = [];
  bool isConnected = false;
  bool isPrinting = false;

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

  TransactionHistoryViewModel() {
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    try {
      bool? isConnectedResult = await bluetooth.isConnected;
      isConnected = isConnectedResult ?? false;
      
      bluetooth.onStateChanged().listen((state) {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            isConnected = true;
            notifyListeners();
            break;
          case BlueThermalPrinter.DISCONNECTED:
            isConnected = false;
            notifyListeners();
            break;
          default:
            break;
        }
      });
    } catch (e) {
      AppLogger.logError(_tag, 'Bluetooth init error', e);
    }
  }

  Future<void> getBluetoothDevices() async {
    try {
      devices = await bluetooth.getBondedDevices();
      notifyListeners();
    } catch (e) {
      AppLogger.logError(_tag, 'Error getting bluetooth devices', e);
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      isConnected = true;
      notifyListeners();
    } catch (e) {
      AppLogger.logError(_tag, 'Connection error', e);
      _errorMessage = 'Failed to connect to printer';
      notifyListeners();
    }
  }

  Future<void> printReceipt(TransactionModel t) async {
    if (!isConnected) return;

    try {
      isPrinting = true;
      notifyListeners();

      final tripType = t.transactionType == 'single' ? 'Single Trip' : 'Complete Trip';
      
      bluetooth.write('--------------------------------\n');
      bluetooth.printCustom('CONSOLIDATED HAULAGE LEVY', 2, 1);
      bluetooth.printCustom('OFFICIAL RECEIPT', 1, 1);
      bluetooth.write('--------------------------------\n');
      bluetooth.printLeftRight('REF:', t.transactionReference, 0);
      bluetooth.printLeftRight('STATUS:', t.status.toUpperCase(), 0);
      bluetooth.printLeftRight('DATE:', t.createdAt, 0);
      bluetooth.write('--------------------------------\n');
      bluetooth.printCustom('CUSTOMER DETAILS', 1, 0);
      bluetooth.printLeftRight('NAME:', t.customerName, 0);
      bluetooth.printLeftRight('VEHICLE:', t.vehicleLicense, 0);
      bluetooth.printLeftRight('TRIP:', tripType, 0);
      bluetooth.write('--------------------------------\n');
      bluetooth.printCustom('ROUTE', 1, 0);
      bluetooth.printCustom('FROM: ${t.originLga}, ${t.originState}', 0, 0);
      bluetooth.printCustom('TO:   ${t.destinationLga}, ${t.destinationState}', 0, 0);
      bluetooth.write('--------------------------------\n');
      bluetooth.printCustom('PAYMENT', 1, 0);
      bluetooth.printLeftRight('AMOUNT:', t.formattedAmount, 0);
      bluetooth.printLeftRight('FEE:', t.formattedServiceFee, 0);
      bluetooth.printLeftRight('TOTAL:', t.formattedTotal, 1);
      bluetooth.printLeftRight('METHOD:', t.paymentMethodDisplay, 0);
      bluetooth.write('--------------------------------\n');
      bluetooth.printCustom('PROCESSED BY', 1, 0);
      bluetooth.printLeftRight('AGENT:', t.agentNumber, 0);
      bluetooth.printLeftRight('TERMINAL:', t.terminalId, 0);
      bluetooth.write('--------------------------------\n');
      
      String qrUrl = 'https://apidev.jrb-shf.com/validate-transaction?params=${t.transactionReference}';
      bluetooth.printQRcode(qrUrl, 200, 200, 1);
      
      bluetooth.printCustom('THANK YOU FOR YOUR PAYMENT', 0, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.paperCut();

      AppLogger.logInfo(_tag, 'Receipt printed successfully');
    } catch (e) {
      AppLogger.logError(_tag, 'Printing error', e);
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }

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
    _verifyingReference = transactionReference;
    notifyListeners();

    final result = await _repository.verifyTransaction(
      transactionReference: transactionReference,
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

    final result = await _repository.abandonTransaction(
      transactionReference: transactionReference,
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
