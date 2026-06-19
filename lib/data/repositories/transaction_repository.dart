import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/logger.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  static const String _tag = 'TxRepo';

  int totalPages = 1;
  int totalTransactions = 0;

  Future<ApiResponse<TransactionModel>> createTransaction(
    Map<String, dynamic> payload,
  ) async {
    AppLogger.logInfo(
        _tag, 'Creating transaction: ${payload['transaction_reference']}');

    // POST to /api_data with action: 'create-transaction'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionCreateTransaction,
      fields: payload,
    );

    if (response.success && response.data != null) {
      final transaction = TransactionModel.fromJson(response.data!);
      AppLogger.logInfo(_tag, 'Created: ${transaction.transactionReference}');
      return ApiResponse.success(transaction, response.message);
    }

    AppLogger.logWarning(_tag, 'Creation failed: ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> approveTransaction({
    required String transactionReference,
  }) async {
    AppLogger.logInfo(_tag, 'Approving: $transactionReference');

    // POST to /api_data with action: 'approve-transaction'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionApproveTransaction,
      fields: {
        'transaction_reference': transactionReference,
      },
    );

    if (response.success) {
      AppLogger.logInfo(_tag, 'Approved: $transactionReference');
      return ApiResponse.success(true, response.message);
    }

    AppLogger.logWarning(_tag, 'Approval failed: ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> declineTransaction({
    required String transactionReference,
  }) async {
    AppLogger.logInfo(_tag, 'Declining: $transactionReference');

    // POST to /api_data with action: 'decline-transaction'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionDeclineTransaction,
      fields: {
        'transaction_reference': transactionReference,
      },
    );

    if (response.success) {
      AppLogger.logInfo(_tag, 'Declined: $transactionReference');
      return ApiResponse.success(true, response.message);
    }

    AppLogger.logWarning(_tag, 'Decline failed: ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<TransactionModel>> verifyTransaction({
    required String transactionReference,
  }) async {
    AppLogger.logInfo(_tag, 'Verifying: $transactionReference');

    // POST to /api_data with action: 'verify-transaction'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionVerifyTransaction,
      fields: {
        'transaction_reference': transactionReference,
      },
    );

    if (response.success && response.data != null) {
      final transaction = TransactionModel.fromJson(response.data!);
      return ApiResponse.success(transaction, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<List<TransactionModel>>> listTransactions({
    int page = 1,
    String? statusFilter,
  }) async {
    AppLogger.logInfo(_tag,
        'Listing transactions (page $page, status: ${statusFilter ?? 'all'})');

    // POST to /api_data with action: 'list-transactions'
    final response = await ApiClient.instance.tmsPost(
      'list-transactions',
      fields: {
        'page': page.toString(),
        if (statusFilter != null) 'status': statusFilter,
      },
    );

    if (response.success && response.data != null) {
      totalPages = response.data!['total_pages'] as int? ?? 1;
      totalTransactions = response.data!['total'] as int? ?? 0;
      final raw = response.data!['data_list'] as List<dynamic>? ?? [];
      final transactions = raw
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.logInfo(_tag,
          'Loaded ${transactions.length} transactions (page $page/$totalPages)');
      return ApiResponse.success(transactions, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> invalidateTransaction({
    required String transactionReference,
  }) async {
    AppLogger.logInfo(_tag, 'Invalidating: $transactionReference');

    final response = await ApiClient.instance.tmsPost(
      'invalidate-transaction',
      fields: {
        'transaction_reference': transactionReference,
      },
    );

    if (response.success) {
      AppLogger.logInfo(_tag, 'Invalidated: $transactionReference');
      return ApiResponse.success(true, response.message);
    }

    AppLogger.logWarning(
        _tag, 'Invalidation failed: ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> abandonTransaction({
    required String transactionReference,
  }) async {
    AppLogger.logInfo(_tag, 'Abandoning: $transactionReference');

    final response = await ApiClient.instance.tmsPost(
      'abandon-transaction',
      fields: {
        'transaction_reference': transactionReference,
      },
    );

    if (response.success) {
      AppLogger.logInfo(_tag, 'Abandoned: $transactionReference');
      return ApiResponse.success(true, response.message);
    }

    AppLogger.logWarning(_tag, 'Abandon failed: ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }
}
