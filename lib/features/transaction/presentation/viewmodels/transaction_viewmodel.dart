import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/transaction_reference_generator.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  static const String _tag = 'TransactionVM';
  static const double adminFeePercent = 0.02;
  static const double fixedTransactionFee = 100.0;
  static const double vatPercent = 0.075;

  final TransactionRepository _repository;

  TransactionViewModel({required TransactionRepository repository})
      : _repository = repository;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? successMessage;
  TransactionEntity? currentTransaction;

  String basePrice = '0';

  String payerFirstName = '';
  String payerLastName = '';
  String payerPhone = '';
  String payerEmail = '';

  String selectedPaymentMethod = 'cash';
  String selectedTransactionType = 'single';

  String? vehicleLicense;
  String? vehicleType;
  String? priceName;
  String? priceType;
  String? issuingState;
  String? enumeratingState;
  String? enumeratingLga;

  String? agentNumber;
  String? terminalId;

  double get baseFee => double.tryParse(basePrice) ?? 0.0;
  double get adminFee => baseFee * adminFeePercent;
  double get transactionFee => fixedTransactionFee;
  double get vat => (baseFee + adminFee + transactionFee) * vatPercent;
  double get totalAmount => baseFee + adminFee + transactionFee + vat;

  bool get hasPayerInfo =>
      payerFirstName.isNotEmpty &&
      payerLastName.isNotEmpty &&
      payerPhone.isNotEmpty;

  Future<void> loadAgentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    agentNumber = prefs.getString(AppConstants.agentNumberKey);
    terminalId = prefs.getString(AppConstants.terminalIdKey);
    AppLogger.debug(_tag, 'Agent info loaded: agent=$agentNumber, terminal=$terminalId');
  }

  void setVehicleDetails({
    required String license,
    required String type,
    required String price,
    required String name,
    required String priceType,
    String? issuingState,
    String? enumeratingState,
    String? enumeratingLga,
  }) {
    vehicleLicense = license;
    vehicleType = type;
    basePrice = price;
    priceName = name;
    this.priceType = priceType;
    this.issuingState = issuingState;
    this.enumeratingState = enumeratingState;
    this.enumeratingLga = enumeratingLga;
    selectedTransactionType = priceType == 'complete' ? 'complete' : 'single';
    notifyListeners();
  }

  void setPayerInfo({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) {
    payerFirstName = firstName.trim();
    payerLastName = lastName.trim();
    payerPhone = phone.trim();
    payerEmail = email.trim();
    errorMessage = null;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  String? validatePayerInfo() {
    if (payerFirstName.isEmpty) return 'First name is required';
    if (payerLastName.isEmpty) return 'Last name is required';
    if (payerPhone.isEmpty) return 'Phone number is required';
    if (payerPhone.length < 11) return 'Phone number must be at least 11 digits';
    if (payerEmail.isNotEmpty && !payerEmail.contains('@')) {
      return 'Invalid email address';
    }
    return null;
  }

  void _setSubmitting(bool value) {
    isSubmitting = value;
    notifyListeners();
  }

  void _setError(String message) {
    errorMessage = message;
    isLoading = false;
    isSubmitting = false;
    notifyListeners();
    AppLogger.error(_tag, message);
  }

  void _setSuccess(String message) {
    successMessage = message;
    isLoading = false;
    isSubmitting = false;
    notifyListeners();
    AppLogger.success(_tag, message);
  }

  Future<bool> submitTransaction() async {
    final validationError = validatePayerInfo();
    if (validationError != null) {
      _setError(validationError);
      return false;
    }

    if (agentNumber == null || terminalId == null) {
      _setError('Agent or terminal info not loaded. Please re-onboard.');
      return false;
    }

    errorMessage = null;
    _setSubmitting(true);

    final transactionRef = TransactionReferenceGenerator.generate();

    try {
      final now = DateTime.now();
      final entity = TransactionEntity(
        transactionRef: transactionRef,
        vehicleLicense: vehicleLicense ?? '',
        vehicleType: vehicleType ?? '',
        price: basePrice,
        priceName: priceName ?? '',
        priceType: priceType ?? '',
        issuingState: issuingState,
        enumeratingState: enumeratingState,
        enumeratingLga: enumeratingLga,
        payerFirstName: payerFirstName,
        payerLastName: payerLastName,
        payerPhone: payerPhone,
        payerEmail: payerEmail,
        transactionType: selectedTransactionType,
        paymentMethod: selectedPaymentMethod,
        baseFee: baseFee,
        adminFee: adminFee,
        transactionFee: transactionFee,
        vat: vat,
        totalAmount: totalAmount,
        serviceNumber: ApiConstants.serviceNumber,
        channelNumber: ApiConstants.channelNumber,
        agentNumber: agentNumber!,
        terminalId: terminalId!,
        createdAt: DateFormatter.toApiFormat(now),
      );

      final result = await _repository.createTransaction(entity);
      currentTransaction = result;
      _setSuccess('Transaction created successfully!');
      return true;
    } on Failure catch (f) {
      _setError(f.message);
      return false;
    } catch (e) {
      AppLogger.error(_tag, 'Unexpected error during submission', e);
      _setError('Unexpected error occurred');
      return false;
    }
  }

  Future<bool> approveCurrentTransaction() async {
    if (currentTransaction == null) {
      _setError('No transaction to approve');
      return false;
    }

    _setSubmitting(true);
    try {
      final result =
          await _repository.approveTransaction(currentTransaction!.transactionRef);
      currentTransaction = result;
      _setSuccess('Transaction approved successfully!');
      return true;
    } on Failure catch (f) {
      _setError(f.message);
      return false;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to approve transaction', e);
      _setError('Failed to approve transaction');
      return false;
    }
  }

  Future<bool> declineCurrentTransaction() async {
    if (currentTransaction == null) {
      _setError('No transaction to decline');
      return false;
    }

    _setSubmitting(true);
    try {
      final result =
          await _repository.declineTransaction(currentTransaction!.transactionRef);
      currentTransaction = result;
      _setSuccess('Transaction declined');
      return true;
    } on Failure catch (f) {
      _setError(f.message);
      return false;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to decline transaction', e);
      _setError('Failed to decline transaction');
      return false;
    }
  }

  Future<void> abandonCurrentTransaction() async {
    if (currentTransaction == null) return;

    try {
      await _repository.abandonTransaction(currentTransaction!.transactionRef);
      AppLogger.info(_tag, 'Transaction abandoned');
    } catch (e) {
      AppLogger.error(_tag, 'Failed to abandon transaction', e);
    }
  }

  void clearState() {
    isLoading = false;
    isSubmitting = false;
    errorMessage = null;
    successMessage = null;
    currentTransaction = null;
    payerFirstName = '';
    payerLastName = '';
    payerPhone = '';
    payerEmail = '';
    selectedPaymentMethod = 'cash';
    basePrice = '0';
    vehicleLicense = null;
    vehicleType = null;
    priceName = null;
    priceType = null;
    issuingState = null;
    enumeratingState = null;
    enumeratingLga = null;
    notifyListeners();
  }
}
