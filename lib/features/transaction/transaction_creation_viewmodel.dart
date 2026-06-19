import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app/routes.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionCreationViewModel extends ChangeNotifier {
  static const String _tag = 'TxCreateVM';

  final VehicleModel vehicle;
  final LocationRepository _locationRepository = LocationRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  bool isLoading = false;
  String? errorMessage;
  String selectedPaymentMethod = 'card';
  String? selectedOriginState;
  String? selectedOriginLga;
  String? selectedDestinationState;
  String? selectedDestinationLga;
  List<String> states = [];
  List<String> originLgas = [];
  List<String> destinationLgas = [];
  final Map<String, String> _stateNameToId = {};
  
  String? _terminalId;

  final TextEditingController payerNameController = TextEditingController();
  final TextEditingController payerPhoneController = TextEditingController();
  final TextEditingController payerEmailController = TextEditingController();

  bool get isCompleteTrip => vehicle.transactionType.trim().toLowerCase() == 'complete';

  double get baseAmount => vehicle.price.amount;
  double get adminFee => baseAmount * AppConstants.adminFeePercent;
  double get processingFee => AppConstants.flatTransactionFee;
  double get totalFee => adminFee + processingFee;
  double get totalPayable => baseAmount + totalFee;

  TransactionCreationViewModel({required this.vehicle}) {
    payerNameController.text =
        vehicle.customerName != 'N/A' ? vehicle.customerName : '';
    payerPhoneController.text = vehicle.phoneNumber ?? '';
    _init();
  }
  
  Future<void> _init() async {
    loadStates();
    _fetchPayloadCategory();
    
    final session = await SessionManager.instance;
    _terminalId = session.terminalId;

    if (_terminalId == null || _terminalId!.isEmpty) {
      AppLogger.logWarning(_tag, 'Terminal ID missing from session during init');
    }
    
    AppLogger.logInfo(_tag, 'Session loaded: Terminal=$_terminalId');
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }

  String get formattedBaseAmount => _formatAmount(baseAmount);
  String get formattedAdminFee => _formatAmount(adminFee);
  String get formattedProcessingFee => _formatAmount(processingFee);
  String get formattedTotalFee => _formatAmount(totalFee);
  String get formattedTotalPayable => _formatAmount(totalPayable);

  List<Map<String, dynamic>> _payloadCategories = [];
  Map<String, dynamic>? selectedPayloadCategory;
  List<String> subCategories = [];
  String? selectedSubCategory;

  bool get hasPayloadCategories => _payloadCategories.isNotEmpty;
  List<Map<String, dynamic>> get payloadCategories => _payloadCategories;

  Future<void> _fetchPayloadCategory() async {
    if (_payloadCategories.isNotEmpty) return;
    AppLogger.logInfo(_tag, 'Fetching payload from JRB...');
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.jrbPayloadCategory))
          .timeout(const Duration(seconds: 10));
      AppLogger.logInfo(_tag, 'JRB status: ${response.statusCode}');
      AppLogger.logDebug(_tag, 'JRB body: ${response.body}');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List raw;
        if (body is List) {
          raw = body;
        } else if (body is Map<String, dynamic> && body['data'] is List) {
          raw = body['data'];
        } else {
          AppLogger.logWarning(_tag, 'Unexpected JRB response format');
          return;
        }
        _payloadCategories = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        AppLogger.logInfo(_tag, 'Loaded ${_payloadCategories.length} categories');
        notifyListeners();
      } else {
        AppLogger.logWarning(_tag, 'JRB returned ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Payload fetch failed: $e');
    }
  }

  void selectPayloadCategory(Map<String, dynamic> category) {
    selectedPayloadCategory = category;
    selectedSubCategory = null;
    final items = category['items'];
    if (items is List) {
      subCategories = items.map((e) => e.toString()).toList();
    } else {
      subCategories = [];
    }
    notifyListeners();
  }

  void selectSubCategory(String sub) {
    selectedSubCategory = sub;
    notifyListeners();
  }

  Future<void> loadStates({int retries = 2}) async {
    isLoading = true;
    notifyListeners();

    for (int attempt = 0; attempt <= retries; attempt++) {
      if (attempt > 0) {
        AppLogger.logInfo(_tag, 'Retrying load states (attempt $attempt)');
        await Future.delayed(const Duration(seconds: 2));
      }

      final result = await _locationRepository.getStates();
      if (result.success && result.data != null) {
        _stateNameToId.clear();
        for (final s in result.data!) {
          _stateNameToId[s.stateName] = s.stateId;
        }
        states = _stateNameToId.keys.toList();
        isLoading = false;
        notifyListeners();
        return;
      }

      AppLogger.logWarning(_tag,
          'Failed to load states (attempt $attempt): ${result.failure?.message}');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> onOriginStateChanged(String state) async {
    selectedOriginState = state;
    selectedOriginLga = null;
    originLgas = [];
    notifyListeners();

    if (state.isEmpty) return;

    final stateId = _stateNameToId[state];
    if (stateId == null) return;

    final result = await _locationRepository.getLgas(stateId);
    if (result.success && result.data != null) {
      originLgas = result.data!.map((l) => l.lgaName).toList();
    }
    notifyListeners();
  }

  Future<void> onDestinationStateChanged(String state) async {
    selectedDestinationState = state;
    selectedDestinationLga = null;
    destinationLgas = [];
    notifyListeners();

    if (state.isEmpty) return;

    final stateId = _stateNameToId[state];
    if (stateId == null) return;

    final result = await _locationRepository.getLgas(stateId);
    if (result.success && result.data != null) {
      destinationLgas = result.data!.map((l) => l.lgaName).toList();
    }
    notifyListeners();
  }

  void onPaymentMethodChanged(String method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void onOriginLgaChanged(String? lga) {
    selectedOriginLga = lga;
    notifyListeners();
  }

  void onDestinationLgaChanged(String? lga) {
    selectedDestinationLga = lga;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  String generateTransactionReference() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch.toString()}';
  }

  Future<void> submit(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final txType = vehicle.transactionType.trim().toLowerCase();
    final isSingle = txType == 'single';

    // Validations
    if (payerNameController.text.trim().isEmpty) {
      errorMessage = 'Payer name is required';
      isLoading = false;
      notifyListeners();
      return;
    }

    if (payerPhoneController.text.trim().length != 11) {
      errorMessage = 'Phone number must be 11 digits';
      isLoading = false;
      notifyListeners();
      return;
    }

    if (selectedOriginState == null) {
      errorMessage = 'Please select origin state';
      isLoading = false;
      notifyListeners();
      return;
    }

    if (selectedOriginLga == null) {
      errorMessage = 'Please select origin LGA';
      isLoading = false;
      notifyListeners();
      return;
    }

    if (isCompleteTrip && selectedDestinationState == null) {
      errorMessage = 'Please select destination state';
      isLoading = false;
      notifyListeners();
      return;
    }

    if (isCompleteTrip && selectedDestinationLga == null) {
      errorMessage = 'Please select destination LGA';
      isLoading = false;
      notifyListeners();
      return;
    }

    // Haulage category is mandatory for Single Trip as per specification
    if (isSingle && selectedPayloadCategory == null) {
      errorMessage = 'Please select a payload category';
      isLoading = false;
      notifyListeners();
      return;
    }

    if (isSingle && subCategories.isNotEmpty && selectedSubCategory == null) {
      errorMessage = 'Please select a subcategory';
      isLoading = false;
      notifyListeners();
      return;
    }

    final session = await SessionManager.instance;
    _terminalId = session.terminalId;

    if (_terminalId == null || _terminalId!.isEmpty) {
      errorMessage = 'Session error. Terminal ID missing. Please restart or refresh the dashboard.';
      isLoading = false;
      notifyListeners();
      return;
    }

    final ref = generateTransactionReference();
    final now = DateTime.now();
    // Format: YYYY-MM-DD HH:mm:ss
    final transactionDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final payerEmail = payerEmailController.text.trim().isNotEmpty
        ? payerEmailController.text.trim()
        : 'customer@example.com';

    // Build payload object for Single trips
    Map<String, dynamic>? payloadObject;
    if (isSingle && selectedPayloadCategory != null) {
      final name = selectedPayloadCategory!['name']?.toString() ?? '';
      final id = selectedPayloadCategory!['id']?.toString() ?? '';
      final subCategory = selectedSubCategory ?? name;
      
      payloadObject = {
        'subcategory': subCategory,
        'haulage_category': name,
        'haulage_category_id': id,
      };
    }

    final metadata = <String, dynamic>{
      'terminal_id': _terminalId,
      'contact': payerPhoneController.text.trim(),
      'vehicle_type': vehicle.vehicleType,
      'transaction_type': vehicle.transactionType,
      'transaction_date': transactionDate,
      'amount': _formatAmount(baseAmount),
      'vehicle_license': vehicle.vehicleLicense,
      'transaction_reference': ref,
      'origin_state': selectedOriginState?.toUpperCase(),
      'origin_lga': selectedOriginLga?.toUpperCase(),
      'destination_state': isCompleteTrip ? selectedDestinationState?.toUpperCase() : null,
      'destination_lga': isCompleteTrip ? selectedDestinationLga?.toUpperCase() : null,
      'payload': payloadObject,
    };

    final payload = <String, dynamic>{
      'transaction_reference': ref,
      'payer_name': payerNameController.text.trim(),
      'payer_phone': payerPhoneController.text.trim(),
      'payer_email': payerEmail,
      'amount': _formatAmount(baseAmount),
      'fee': _formatAmount(totalFee),
      'transaction_date': transactionDate,
      'payment_method': selectedPaymentMethod,
      'terminal_id': _terminalId,
      'vehicle_license': vehicle.vehicleLicense,
      'vehicle_type': vehicle.vehicleType,
      'transaction_type': vehicle.transactionType,
      'origin_state': selectedOriginState,
      'origin_lga': selectedOriginLga,
      'destination_state': selectedDestinationState,
      'destination_lga': selectedDestinationLga,
      'payload': payloadObject, // Ensure payload is also at top level
      'metadata': metadata,
    };

    AppLogger.logInfo(_tag, 'Payload ready: $ref (Type: $txType, Payload: ${payloadObject != null})');

    final result = await _transactionRepository.createTransaction(payload);

    if (result.success && result.data != null) {
      AppLogger.logInfo(_tag, 'Created: ${result.data!.transactionReference}');
      isLoading = false;
      notifyListeners();

      if (!context.mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.transactionSuccess,
        arguments: result.data!,
      );
    } else {
      AppLogger.logWarning(_tag, 'Creation failed: ${result.failure?.message}');
      errorMessage = result.failure?.message ?? 'Transaction creation failed';
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    payerNameController.dispose();
    payerPhoneController.dispose();
    payerEmailController.dispose();
    super.dispose();
  }
}
