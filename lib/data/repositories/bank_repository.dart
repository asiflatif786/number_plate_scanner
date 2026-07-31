import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/logger.dart';

class BankRepository {
  static const String _tag = 'BankRepo';

  Future<ApiResponse<List<Map<String, dynamic>>>> getAgentsForBank() async {
    AppLogger.logInfo(_tag, 'Fetching agents for bank account creation');

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionGetAgentsForBank,
    );

    if (response.success && response.data != null) {
      final List<dynamic> rawList = response.data!['data_list'] ?? [];
      final List<Map<String, dynamic>> agents = rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return ApiResponse.success(agents, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<Map<String, dynamic>>> createCustomerProfile({
    required String bvn,
    required String email,
  }) async {
    AppLogger.logInfo(_tag, 'Creating bank account profile via TMS action');

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionCreateBankAccount,
      fields: {
        'bvn': bvn,
        'email': email,
      },
    );

    if (response.success) {
      return ApiResponse.success(response.data ?? {}, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<Map<String, dynamic>>> generateAccount({
    required String otp,
    required String email,
  }) async {
    AppLogger.logInfo(_tag, 'Generating bank account');

    final response = await ApiClient.instance.post(
      ApiConstants.generateAccount,
      baseUrl: ApiConstants.cyber1BaseUrl,
      body: {
        'otp': otp,
        'email': email,
      },
    );

    if (response.success) {
      return ApiResponse.success(response.data ?? {}, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<Map<String, dynamic>>> regenerateOtp({
    required String email,
  }) async {
    AppLogger.logInfo(_tag, 'Regenerating OTP');

    final response = await ApiClient.instance.post(
      ApiConstants.regenerateOtp,
      baseUrl: ApiConstants.cyber1BaseUrl,
      body: {
        'email': email,
      },
    );

    if (response.success) {
      return ApiResponse.success(response.data ?? {}, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<Map<String, dynamic>>> getCustomerDetails({
    required String email,
  }) async {
    AppLogger.logInfo(_tag, 'Getting customer details');

    final response = await ApiClient.instance.get(
      ApiConstants.getCustomerDetails,
      baseUrl: ApiConstants.cyber1BaseUrl,
      queryParams: {
        'email': email,
      },
    );

    if (response.success) {
      return ApiResponse.success(response.data ?? {}, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
