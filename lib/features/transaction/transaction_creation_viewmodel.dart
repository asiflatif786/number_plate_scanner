import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  double get totalFee => 0.0;
  double get totalPayable => baseAmount;

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
  }

  String _formatAmount(double value) {
    return value.toStringAsFixed(2);
  }

  String get formattedBaseAmount => _formatAmount(baseAmount);
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
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.jrbPayloadCategory))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List raw = (body is List) ? body : (body['data'] is List ? body['data'] : []);
        _payloadCategories = raw.map((e) => Map<String, dynamic>.from(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      AppLogger.logWarning(_tag, 'Payload fetch failed: $e');
    }
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

  Future<void> loadStates({int retries = 2}) async {
    isLoading = true;
    notifyListeners();

    for (int attempt = 0; attempt <= retries; attempt++) {
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
      if (attempt < retries) await Future.delayed(const Duration(seconds: 2));
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
    if (isCompleteTrip && (selectedDestinationState == null || selectedDestinationLga == null)) {
      errorMessage = 'Please select destination state and LGA';
      notifyListeners();
      return false;
    }
    return true;
  }

  Map<String, dynamic> _prepareTmsPayload(String ref, SessionManager session, String email) {
    final txType = vehicle.transactionType.trim().toLowerCase();
    final isSingle = txType == 'single';
    final now = DateTime.now();
    final transactionDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    Map<String, dynamic>? payloadObject;
    if (isSingle && selectedPayloadCategory != null) {
      payloadObject = {
        'subcategory': selectedSubCategory ?? selectedPayloadCategory!['name'],
        'haulage_category': selectedPayloadCategory!['name'],
        'haulage_category_id': selectedPayloadCategory!['id'],
      };
    }

    final metadata = <String, dynamic>{
      'channel': 'dealcity',
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
      'destination_state': selectedDestinationState,
      'destination_lga': selectedDestinationLga,
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
    final ref = generateTransactionReference();
    final email = payerEmailController.text.trim().isNotEmpty ? payerEmailController.text.trim() : (session.agentEmail ?? 'customer@example.com');
    
    final result = await _transactionRepository.createTransaction(_prepareTmsPayload(ref, session, email));

    if (result.success && result.data != null) {
      isLoading = false;
      notifyListeners();
      if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.transactionSuccess, arguments: result.data!);
    } else {
      errorMessage = result.failure?.message ?? 'Transaction failed';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> proceedWithSquadCo(BuildContext context) async {
    if (!_validate()) return;
    isSquadCoProceeding = true;
    errorMessage = null;
    notifyListeners();

    try {
      final session = await SessionManager.instance;
      final email = payerEmailController.text.trim().isNotEmpty ? payerEmailController.text.trim() : (session.agentEmail ?? 'customer@example.com');
      final userId = session.agentNumber;

      if (userId == null || session.terminalId == null) throw Exception("Session missing. Please log in again.");

      final serverUrl = Uri.parse('https://tms-local-api.justerrand.ie/squadco/post-transaction');
      final int amountInKobo = (totalPayable * 100).toInt();

      AppLogger.logInfo(_tag, 'Initializing SquadCo Proxy: $serverUrl');
      final response = await http.post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountInKobo, 
          'email': email, 
          'redirect_url': 'chl://payment-success/payment-success'
        }),
      ).timeout(const Duration(seconds: 25));

      AppLogger.logDebug(_tag, 'SquadCo Proxy Response: ${response.body}');

      if (response.statusCode != 200) throw Exception('Server error: ${response.statusCode}');

      final responseBody = jsonDecode(response.body);
      if (responseBody['success'] != true) throw Exception(responseBody['message'] ?? 'Init failed');

      final data = responseBody['data'];
      String rawUrl = (data?['checkout_url'] ?? data?['url'] ?? data?['link'] ?? '').toString();
      final String transactionRef = (data?['transaction_ref'] ?? data?['reference'] ?? '').toString();

      // Clean URL
      String cleanUrl = rawUrl.trim().replaceAll('"', '').replaceAll(r'\/', '/');
      if (cleanUrl.isEmpty) throw Exception('Invalid payment link returned from proxy');

      if (!cleanUrl.startsWith('http')) {
        cleanUrl = cleanUrl.contains('squadco.com') ? 'https://$cleanUrl' : Uri.parse('https://tms-local-api.justerrand.ie').resolve(cleanUrl).toString();
      }

      AppLogger.logInfo(_tag, 'Launching SquadCo URL: $cleanUrl');
      final checkoutUri = Uri.parse(cleanUrl);

      // 1. Create record in TMS before launching browser
      final tmsResult = await _transactionRepository.createTransaction(_prepareTmsPayload(transactionRef, session, email));

      // 2. Prepare model for display - PREVENT N/A values by merging local state with server response
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      final localModel = TransactionModel(
        transactionReference: transactionRef,
        customerName: payerNameController.text.trim(),
        vehicleLicense: vehicle.vehicleLicense,
        totalAmount: totalPayable,
        amount: baseAmount,
        serviceFee: totalFee,
        paymentMethod: 'squad',
        status: 'pending',
        terminalId: session.terminalId!,
        agentNumber: userId ?? '',
        createdAt: dateStr,
        originState: selectedOriginState ?? 'N/A',
        originLga: selectedOriginLga ?? 'N/A',
        destinationState: selectedDestinationState ?? 'N/A',
        destinationLga: selectedDestinationLga ?? 'N/A',
        transactionType: vehicle.transactionType,
      );

      // Merge results if server returned a model
      final displayModel = (tmsResult.success && tmsResult.data != null)
          ? localModel.merge(tmsResult.data!)
          : localModel;

      // 3. Navigate to Success Screen FIRST so it is waiting in the background.
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.transactionSuccess,
          arguments: displayModel,
        );
      }

      // 4. Launch external browser
      final bool launched = await launchUrl(
        checkoutUri, 
        mode: LaunchMode.externalApplication,
      );

      if (!launched) throw Exception('Could not open browser. Please ensure Chrome or another browser is installed.');

    } catch (e) {
      AppLogger.logError(_tag, 'SquadCo error', e);
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSquadCoProceeding = false;
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
