import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_request_model.dart';
import '../models/transaction_response_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  static const String _tag = 'TransactionRepo';
  final NetworkClient _networkClient;

  TransactionRepositoryImpl({required NetworkClient networkClient})
      : _networkClient = networkClient;

  @override
  Future<TransactionEntity> createTransaction(
      TransactionEntity transaction) async {
    AppLogger.info(_tag,
        'Creating transaction: ${transaction.transactionRef} for ${transaction.vehicleLicense}');

    try {
      final json = TransactionRequestModel.toCreateJson(transaction);
      final response = await _networkClient.post(
        ApiConstants.createTransaction,
        body: json,
      );

      final responseModel = TransactionResponseModel.fromJson(response);

      if (responseModel.transaction == null) {
        AppLogger.error(_tag, 'Transaction data not found in response');
        throw const ServerFailure('Transaction data not found in response');
      }

      AppLogger.success(_tag,
          'Transaction created: ${responseModel.transaction!.transactionRef}');
      return responseModel.transaction!;
    } catch (e) {
      if (e is Failure) rethrow;
      AppLogger.error(_tag, 'Failed to create transaction', e);
      rethrow;
    }
  }

  @override
  Future<TransactionEntity> approveTransaction(
      String transactionRef) async {
    AppLogger.info(_tag, 'Approving transaction: $transactionRef');

    try {
      final response = await _networkClient.put(
        ApiConstants.approveTransaction,
        body: {
          'transaction_reference': transactionRef,
          'channel_number': ApiConstants.channelNumber,
        },
      );

      final responseModel = TransactionResponseModel.fromJson(response);

      if (responseModel.transaction == null) {
        throw const ServerFailure('Transaction data not found in response');
      }

      AppLogger.success(_tag, 'Transaction approved: $transactionRef');
      return responseModel.transaction!;
    } catch (e) {
      if (e is Failure) rethrow;
      AppLogger.error(_tag, 'Failed to approve transaction', e);
      rethrow;
    }
  }

  @override
  Future<TransactionEntity> declineTransaction(
      String transactionRef) async {
    AppLogger.info(_tag, 'Declining transaction: $transactionRef');

    try {
      final response = await _networkClient.put(
        ApiConstants.declineTransaction,
        body: {
          'transaction_reference': transactionRef,
          'channel_number': ApiConstants.channelNumber,
        },
      );

      final responseModel = TransactionResponseModel.fromJson(response);

      if (responseModel.transaction == null) {
        throw const ServerFailure('Transaction data not found in response');
      }

      AppLogger.success(_tag, 'Transaction declined: $transactionRef');
      return responseModel.transaction!;
    } catch (e) {
      if (e is Failure) rethrow;
      AppLogger.error(_tag, 'Failed to decline transaction', e);
      rethrow;
    }
  }

  @override
  Future<TransactionEntity> verifyTransaction(
      String transactionRef) async {
    AppLogger.info(_tag, 'Verifying transaction: $transactionRef');

    try {
      final response = await _networkClient.get(
        ApiConstants.verifyTransaction,
        queryParams: {'transaction_ref': transactionRef},
      );

      final responseModel = TransactionResponseModel.fromJson(response);

      if (responseModel.transaction == null) {
        throw const ServerFailure('Transaction data not found in response');
      }

      AppLogger.success(_tag, 'Transaction verified: $transactionRef');
      return responseModel.transaction!;
    } catch (e) {
      if (e is Failure) rethrow;
      AppLogger.error(_tag, 'Failed to verify transaction', e);
      rethrow;
    }
  }

  @override
  Future<void> abandonTransaction(String transactionRef) async {
    AppLogger.info(_tag, 'Abandoning transaction: $transactionRef');

    try {
      await _networkClient.get(
        ApiConstants.abandonTransaction,
        queryParams: {'transaction_ref': transactionRef},
      );

      AppLogger.success(_tag, 'Transaction abandoned: $transactionRef');
    } catch (e) {
      if (e is Failure) rethrow;
      AppLogger.error(_tag, 'Failed to abandon transaction', e);
      rethrow;
    }
  }

  @override
  Future<List<TransactionEntity>> listTransactions({
    String? agentNumber,
    int page = 1,
    int limit = 20,
  }) async {
    AppLogger.info(_tag, 'Listing transactions for agent: $agentNumber');

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (agentNumber != null) {
        queryParams['agent_number'] = agentNumber;
      }

      final response = await _networkClient.get(
        ApiConstants.listTransactions,
        queryParams: queryParams,
      );

      final dataList = response['data'] as List<dynamic>? ?? [];
      final transactions = dataList.map((item) {
        if (item is Map<String, dynamic>) {
          final parsed = TransactionResponseModel.fromJson(item);
          return parsed.transaction;
        }
        return null;
      }).whereType<TransactionEntity>().toList();

      AppLogger.success(
          _tag, 'Fetched ${transactions.length} transactions');
      return transactions;
    } catch (e) {
      if (e is Failure) rethrow;
      AppLogger.error(_tag, 'Failed to list transactions', e);
      rethrow;
    }
  }
}
