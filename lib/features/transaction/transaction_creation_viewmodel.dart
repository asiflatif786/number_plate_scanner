import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  bool isSquadCoProceeding = false;
  String? errorMessage;
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

  bool _validate() {
    final txType = vehicle.transactionType.trim().toLowerCase();
    final isSingle = txType == 'single';

    if (payerNameController.text.trim().isEmpty) {
      errorMessage = 'Payer name is required';
      notifyListeners();
      return false;
    }

    if (payerPhoneController.text.trim().length != 11) {
      errorMessage = 'Phone number must be 11 digits';
      notifyListeners();
      return false;
    }

    if (selectedOriginState == null) {
      errorMessage = 'Please select origin state';
      notifyListeners();
      return false;
    }

    if (selectedOriginLga == null) {
      errorMessage = 'Please select origin LGA';
      notifyListeners();
      return false;
    }

    if (isCompleteTrip && selectedDestinationState == null) {
      errorMessage = 'Please select destination state';
      notifyListeners();
      return false;
    }

    if (isCompleteTrip && selectedDestinationLga == null) {
      errorMessage = 'Please select destination LGA';
      notifyListeners();
      return false;
    }

    if (isSingle && selectedPayloadCategory == null) {
      errorMessage = 'Please select a payload category';
      notifyListeners();
      return false;
    }

    if (isSingle && subCategories.isNotEmpty && selectedSubCategory == null) {
      errorMessage = 'Please select a subcategory';
      notifyListeners();
      return false;
    }
    
    return true;
  }

  Map<String, dynamic> _prepareTmsPayload(String ref, SessionManager session, String email) {
    final txType = vehicle.transactionType.trim().toLowerCase();
    final isSingle = txType == 'single';
    
    final now = DateTime.now();
    final transactionDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

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
      'channel': 'dealcity',
      'channel_type': 'pos',
      'terminal_id': session.terminalId,
      'contact': payerPhoneController.text.trim(),
      'vehicle_type': vehicle.vehicleType,
      'transaction_type': vehicle.transactionType,
      'transaction_date': transactionDate,
      'amount': _formatAmount(baseAmount),
      'vehicle_license': vehicle.vehicleLicense,
      'transaction_reference': ref,
      'origin_state': selectedOriginState,
      'origin_lga': selectedOriginLga,
      'destination_state': isCompleteTrip ? selectedDestinationState : null,
      'destination_lga': isCompleteTrip ? selectedDestinationLga : null,
      'payload': payloadObject,
    };

    return <String, dynamic>{
      'transaction_reference': ref,
      'payer_name': payerNameController.text.trim(),
      'payer_phone': payerPhoneController.text.trim(),
      'payer_email': email,
      'amount': _formatAmount(baseAmount),
      'fee': _formatAmount(totalFee),
      'transaction_date': transactionDate,
      'channel_number': session.channelNumber,
      'payment_method': 'transfer',
      'terminal_id': session.terminalId,
      'service_number': session.serviceNumberTransaction,
      // Root-level fields to satisfy server validation
      'vehicle_license': vehicle.vehicleLicense,
      'vehicle_type': vehicle.vehicleType,
      'transaction_type': vehicle.transactionType,
      'origin_state': selectedOriginState,
      'origin_lga': selectedOriginLga,
      'destination_state': selectedDestinationState,
      'destination_lga': selectedDestinationLga,
      'metadata': metadata,
    };
  }

  Future<void> submit(BuildContext context) async {
    if (!_validate()) return;
    
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final session = await SessionManager.instance;
    _terminalId = session.terminalId;

    if (_terminalId == null || _terminalId!.isEmpty) {
      errorMessage = 'Session error. Terminal ID missing. Please restart or refresh the dashboard.';
      isLoading = false;
      notifyListeners();
      return;
    }

    final ref = generateTransactionReference();
    final email = payerEmailController.text.trim().isNotEmpty
        ? payerEmailController.text.trim()
        : (session.agentEmail ?? 'customer@example.com');
    final payload = _prepareTmsPayload(ref, session, email);

    AppLogger.logInfo(_tag, 'Payload ready: $ref (Type: ${vehicle.transactionType})');

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

  Future<void> proceedWithSquadCo(BuildContext context) async {
    if (!_validate()) return;

    isSquadCoProceeding = true;
    errorMessage = null;
    notifyListeners();

    AppLogger.logInfo(_tag, 'Proceeding with SquadCo for ${vehicle.vehicleLicense}');

    final session = await SessionManager.instance;
    _terminalId = session.terminalId;
    final email = payerEmailController.text.trim().isNotEmpty 
        ? payerEmailController.text.trim() 
        : session.agentEmail ?? 'customer@example.com';
    final userId = session.agentNumber;

    if (userId == null || userId.isEmpty || _terminalId == null || _terminalId!.isEmpty) {
      isSquadCoProceeding = false;
      errorMessage = "Agent/Terminal session data not available. Please refresh dashboard.";
      notifyListeners();
      return;
    }

    final serverUrl = Uri.parse('https://tms-local-api.justerrand.ie/squadco/post-transaction');

    try {
      final response = await http.post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (totalPayable * 100).toInt(), // Amount in kobo
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned error: ${response.statusCode}');
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseBody['success'] != true) {
        throw Exception(responseBody['message'] ?? 'Failed to initialize transaction');
      }

      final data = responseBody['data'] as Map<String, dynamic>;
      final checkoutUrl = data['checkout_url'] as String?;
      final transactionRef = data['transaction_ref'] as String?;

      if (checkoutUrl == null || transactionRef == null) {
        throw Exception('Missing checkout URL or transaction reference');
      }

      // Create transaction in TMS as pending using Squad's reference
      final tmsPayload = _prepareTmsPayload(transactionRef, session, email);
      
      final tmsResult = await _transactionRepository.createTransaction(tmsPayload);
      if (!tmsResult.success) {
        throw Exception('Failed to record transaction in TMS: ${tmsResult.failure?.message}');
      }
      
      final createdTransaction = tmsResult.data!;

      final uri = Uri.parse(checkoutUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        await _storeTransactionInFirebase(transactionRef, totalPayable.toInt(), userId);

        if (context.mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.transactionSuccess,
            arguments: createdTransaction,
          );
        }
      } else {
        throw Exception('Could not launch payment page');
      }
    } catch (e) {
      AppLogger.logError(_tag, 'SquadCo error', e);
      errorMessage = e.toString();
    } finally {
      isSquadCoProceeding = false;
      notifyListeners();
    }
  }

  Future<void> _storeTransactionInFirebase(String transactionId, int amount, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'id': transactionId,
        'amount': amount,
        'currency': 'NGN',
        'payment_method': 'transfer',
        'user_id': userId,
        'vehicle_license': vehicle.vehicleLicense,
        'created_at': FieldValue.serverTimestamp(),
        'status': 'pending_verification',
      });
      AppLogger.logInfo(_tag, 'Transaction stored in Firebase: $transactionId');
    } catch (e) {
      AppLogger.logError(_tag, 'Error storing transaction in Firebase', e);
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
