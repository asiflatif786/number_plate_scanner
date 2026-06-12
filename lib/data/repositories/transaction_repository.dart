import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../models/transaction_draft_model.dart';
import '../models/transaction_model.dart';
import '../models/verify_result_model.dart';

class TransactionRepository {
  static const String _tag = 'TransactionRepo';

  // After approve/decline completes, payment_processing_viewmodel.dart
  // calls TransactionLogStore().saveTransaction(transaction) — this is the
  // only write point into the local transaction log.

  Future<ApiResponse<Map<String, dynamic>>> createTransaction(
    TransactionDraftModel draft,
    String paymentMethod, {
    String payerName = '',
    String payerPhone = '',
  }) async {
    final session = await SessionManager.instance;
    final terminalId = session.terminalId;

    AppLogger.logInfo(_tag,
        'Creating transaction: ${draft.vehicle.vehicleLicense} ($paymentMethod)');

    final payload = {
      'action': ApiConstants.actionCreateTransaction,
      'payer_name': payerName.isNotEmpty
          ? payerName
          : draft.vehicle.customerName,
      'payer_phone': payerPhone.isNotEmpty
          ? payerPhone
          : (draft.vehicle.phoneNumber ?? ''),
      'payer_email': draft.payerEmail,
      'amount': draft.vehicle.price.amount.toStringAsFixed(2),
      'fee': draft.vehicle.price.serviceFee.toStringAsFixed(2),
      'payment_method': paymentMethod,
      'terminal_id': terminalId ?? '',
      'vehicle_license': draft.vehicle.vehicleLicense,
      'vehicle_type': draft.vehicle.vehicleType,
      'transaction_type': draft.vehicle.transactionType,
      'origin_state': draft.originState.toUpperCase(),
      'origin_lga': draft.originLga.toUpperCase(),
      if (draft.isCompleteTrip)
        'destination_state': draft.destinationState.toUpperCase(),
      if (draft.isCompleteTrip)
        'destination_lga': draft.destinationLga.toUpperCase(),
    };

    final response = await ApiClient.instance.post(payload);

    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> approveTransaction(
    String transactionReference,
  ) async {
    AppLogger.logInfo(_tag, 'Approving transaction: $transactionReference');

    final payload = {
      'action': ApiConstants.actionApproveTransaction,
      'transaction_reference': transactionReference,
    };

    final response = await ApiClient.instance.post(payload);

    if (response.success) {
      AppLogger.logInfo(_tag, 'Transaction approved: $transactionReference');
      return ApiResponse.success(true, response.message);
    }

    AppLogger.logError(_tag,
        'Approval failed: $transactionReference — ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> declineTransaction(
    String transactionReference,
  ) async {
    AppLogger.logInfo(_tag, 'Declining transaction: $transactionReference');

    final payload = {
      'action': ApiConstants.actionDeclineTransaction,
      'transaction_reference': transactionReference,
    };

    final response = await ApiClient.instance.post(payload);

    if (response.success) {
      AppLogger.logInfo(_tag, 'Transaction declined: $transactionReference');
      return ApiResponse.success(true, response.message);
    }

    AppLogger.logError(_tag,
        'Decline failed: $transactionReference — ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<VerifyResultModel>> verifyTransaction(
    String transactionReference,
  ) async {
    AppLogger.logInfo(_tag, 'Verifying transaction: $transactionReference');

    final payload = {
      'action': ApiConstants.actionVerifyTransaction,
      'transaction_reference': transactionReference,
    };

    final response = await ApiClient.instance.post(payload);

    if (response.success && response.data != null) {
      final result =
          VerifyResultModel.fromJson(response.data!);
      return ApiResponse.success(result, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
