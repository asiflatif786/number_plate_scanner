import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/routes.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/transaction_repository.dart';

enum TransactionMode { interState, intraState, penalty }

class TransactionCreationViewModel extends ChangeNotifier {
  static const String _tag = 'TxCreateVM';

  final VehicleModel vehicle;
  final bool hasPenalty;
  final double penaltyAmount;
  final String? paymentType; // chl-inter, chl-intra, penalty-inter, penalty-intra
  
  final LocationRepository _locationRepository = LocationRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  bool isLoading = false;
  bool isSquadCoProceeding = false;
  String? errorMessage;
  
  TransactionMode _transactionMode = TransactionMode.interState;
  TransactionMode get transactionMode => _transactionMode;

  String? selectedOriginState;
  String? selectedOriginLga;
  String? selectedDestinationState;
  String? selectedDestinationLga;
  
  // Town locations
  final TextEditingController departureTownController = TextEditingController();
  final TextEditingController destinationTownController = TextEditingController();

  List<String> states = [];
  List<String> originLgas = [];
  List<String> destinationLgas = [];
  final Map<String, String> _stateNameToId = {};
  
  String? _terminalId;
  String? _assignedState;
  String? get assignedState => _assignedState;
  String? _intraStateServiceNumber;
  String? _penaltyServiceNumber;

  final TextEditingController payerNameController = TextEditingController();
  final TextEditingController payerPhoneController = TextEditingController();
  final TextEditingController payerEmailController = TextEditingController();

  bool get isCompleteTrip => vehicle.transactionType.trim().toLowerCase() == 'complete';

  double get baseAmount => vehicle.price.amount;
  
  double get totalFee => vehicle.price.serviceFee > 0 
      ? vehicle.price.serviceFee 
      : (baseAmount * AppConstants.adminFeePercent + AppConstants.flatTransactionFee);
      
  double get totalPayable => baseAmount + totalFee + penaltyAmount;

  TransactionCreationViewModel({
    required this.vehicle,
    this.hasPenalty = false,
    this.penaltyAmount = 0.0,
    this.paymentType,
  }) {
    payerNameController.text =
        vehicle.customerName != 'N/A' ? vehicle.customerName : '';
    payerPhoneController.text = vehicle.phoneNumber ?? '';
    
    // Auto-select mode based on payment type selection
    if (paymentType == 'chl-intra' || paymentType == 'penalty-intra') {
      _transactionMode = TransactionMode.intraState;
    } else if (paymentType == 'penalty-inter') {
      _transactionMode = TransactionMode.interState;
    } else {
      _transactionMode = TransactionMode.interState;
    }
    
    _init();
  }
  
  Future<void> _init() async {
    final session = await SessionManager.instance;
    _terminalId = session.terminalId;
    _assignedState = session.assignedState;
    _intraStateServiceNumber = session.serviceNumberIntraState;
    _penaltyServiceNumber = session.serviceNumberPenalty;

    await loadStates();
    _fetchPayloadCategory();

    if (_assignedState != null && _assignedState!.isNotEmpty) {
      selectedOriginState = _assignedState;
      
      if (_transactionMode == TransactionMode.intraState) {
        selectedDestinationState = _assignedState;
        await onDestinationStateChanged(_assignedState!);
      }
      
      await onOriginStateChanged(_assignedState!);
    }
    notifyListeners();
  }

  void setTransactionMode(TransactionMode mode) {
    if (_transactionMode == mode) return;
    _transactionMode = mode;
    
    if (_assignedState != null && _assignedState!.isNotEmpty) {
      selectedOriginState = _assignedState;
      if (mode == TransactionMode.intraState) {
        selectedDestinationState = _assignedState;
        onDestinationStateChanged(_assignedState!);
      } else {
        selectedDestinationState = null;
        destinationLgas = [];
        selectedDestinationLga = null;
      }
      onOriginStateChanged(_assignedState!);
    }
    notifyListeners();
  }

  String _formatAmount(double value) => value.toStringAsFixed(2);
  String get formattedBaseAmount => _formatAmount(baseAmount);
  String get formattedTotalFee => _formatAmount(totalFee);
  String get formattedPenaltyAmount => _formatAmount(penaltyAmount);
  String get formattedTotalPayable => _formatAmount(totalPayable);

  List<Map<String, dynamic>> _payloadCategories = [];
  Map<String, dynamic>? selectedPayloadCategory;
  List<String> subCategories = [];
  String? selectedSubCategory;

  bool get hasPayloadCategories => _payloadCategories.isNotEmpty;
  List<Map<String, dynamic>> get payloadCategories => _payloadCategories;

  Future<void> _fetchPayloadCategory() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.jrbPayloadCategory));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List raw = (body is List) ? body : (body['data'] is List ? body['data'] : []);
        _payloadCategories = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        notifyListeners();
      }
    } catch (e) { AppLogger.logWarning(_tag, 'Payload fetch failed: $e'); }
  }

  void selectPayloadCategory(Map<String, dynamic> category) {
    selectedPayloadCategory = category;
    selectedSubCategory = null;
    final items = category['items'];
    subCategories = (items is List) ? items.map((e) => e.toString()).toList() : [];
    notifyListeners();
  }

  void selectSubCategory(String sub) {
    selectedSubCategory = sub;
    notifyListeners();
  }

  Future<void> loadStates() async {
    isLoading = true;
    notifyListeners();
    final result = await _locationRepository.getStates();
    if (result.success && result.data != null) {
      _stateNameToId.clear();
      for (final s in result.data!) {
        _stateNameToId[s.stateName] = s.stateId;
      }
      states = _stateNameToId.keys.toList();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> onOriginStateChanged(String state) async {
    selectedOriginState = state;
    selectedOriginLga = null;
    originLgas = [];
    notifyListeners();
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
    final stateId = _stateNameToId[state];
    if (stateId == null) return;
    final result = await _locationRepository.getLgas(stateId);
    if (result.success && result.data != null) {
      destinationLgas = result.data!.map((l) => l.lgaName).toList();
    }
    notifyListeners();
  }

  void onOriginLgaChanged(String? lga) { selectedOriginLga = lga; notifyListeners(); }
  void onDestinationLgaChanged(String? lga) { selectedDestinationLga = lga; notifyListeners(); }
  void clearError() { errorMessage = null; notifyListeners(); }

  String generateTransactionReference() => 'TXN${DateTime.now().millisecondsSinceEpoch}';

  bool _validate() {
    if (payerNameController.text.trim().isEmpty) { errorMessage = 'Payer name is required'; notifyListeners(); return false; }
    if (payerPhoneController.text.trim().length != 11) { errorMessage = 'Phone number must be 11 digits'; notifyListeners(); return false; }
    if (selectedOriginState == null) { errorMessage = 'Please select origin state'; notifyListeners(); return false; }
    if (selectedOriginLga == null) { errorMessage = 'Please select origin LGA'; notifyListeners(); return false; }
    if (selectedDestinationState == null || selectedDestinationLga == null) { errorMessage = 'Please select destination state and LGA'; notifyListeners(); return false; }
    if (_transactionMode == TransactionMode.intraState && (departureTownController.text.trim().isEmpty || destinationTownController.text.trim().isEmpty)) {
      errorMessage = 'Town names are required for intra-state'; notifyListeners(); return false;
    }
    if (selectedPayloadCategory == null) {
      errorMessage = 'Please select a payload category';
      notifyListeners();
      return false;
    }
    return true;
  }

  Map<String, dynamic> _prepareTmsPayload(String ref, SessionManager session, String email, {String paymentMethod = 'transfer'}) {
    final transactionType = vehicle.transactionType.trim().toLowerCase().contains('single') ? 'single' : 'complete';
    
    Map<String, dynamic>? payloadObject;
    if (selectedPayloadCategory != null) {
      payloadObject = {
        'subcategory': selectedSubCategory ?? selectedPayloadCategory!['name'],
        'haulage_category': selectedPayloadCategory!['name'],
        'haulage_category_id': selectedPayloadCategory!['id'],
      };
    }

    String transactionState;
    if (paymentType != null && paymentType!.startsWith('penalty')) {
       transactionState = paymentType == 'penalty-intra' ? 'Intra State' : 'Inter State';
    } else {
       transactionState = _transactionMode == TransactionMode.intraState ? 'Intra State' : 'Inter State';
    }

    String? serviceNumber;
    if (hasPenalty) {
      serviceNumber = _penaltyServiceNumber ?? session.serviceNumberTransaction;
    } else if (_transactionMode == TransactionMode.intraState) {
      serviceNumber = _intraStateServiceNumber ?? session.serviceNumberTransaction;
    } else {
      serviceNumber = session.serviceNumberTransaction;
    }

    final transactionDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final totalAmountValue = baseAmount + penaltyAmount;

    return <String, dynamic>{
      'payer_name': payerNameController.text.trim(),
      'payer_phone': payerPhoneController.text.trim(),
      'payer_email': email,
      'amount': totalAmountValue,
      'fee': totalFee,
      'payment_method': paymentMethod,
      'terminal_id': session.terminalId ?? '',
      'vehicle_license': vehicle.vehicleLicense,
      'vehicle_type': vehicle.vehicleType,
      'transaction_type': transactionType,
      'transaction_state': transactionState,
      'origin_state': selectedOriginState,
      'origin_lga': selectedOriginLga,
      'destination_state': selectedDestinationState,
      'destination_lga': selectedDestinationLga,
      'origin_location': departureTownController.text.trim(),
      'destination_location': destinationTownController.text.trim(),
      'payload': payloadObject != null ? [payloadObject] : [], // Ensure this is always an array
      'transaction_reference': ref,
      'service_number': serviceNumber,
      'channel_number': session.channelNumber,
      'transaction_date': transactionDate,
    };
  }

  Future<void> proceedWithStandardPayment(BuildContext context) async {
    errorMessage = null; // Clear old error
    if (!_validate()) return;
    isLoading = true;
    notifyListeners();

    try {
      final session = await SessionManager.instance;
      final email = payerEmailController.text.trim().isNotEmpty 
          ? payerEmailController.text.trim() 
          : (session.agentEmail ?? 'customer@example.com');
      
      final transactionRef = generateTransactionReference();
      final tmsPayload = _prepareTmsPayload(transactionRef, session, email, paymentMethod: ApiConstants.paymentMethodTransfer);

      final result = await _transactionRepository.createTransaction(tmsPayload);

      if (result.success && result.data != null) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context, 
            AppRoutes.transactionDetail, 
            arguments: result.data
          );
        }
      } else {
        errorMessage = result.failure?.message ?? 'Failed to create transaction';
        AppLogger.logWarning(_tag, 'Transaction failed: $errorMessage');
      }
    } catch (e) {
      errorMessage = e.toString();
      AppLogger.logError(_tag, 'Exception in proceedWithStandardPayment', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    payerNameController.dispose();
    payerPhoneController.dispose();
    payerEmailController.dispose();
    departureTownController.dispose();
    destinationTownController.dispose();
    super.dispose();
  }
}
