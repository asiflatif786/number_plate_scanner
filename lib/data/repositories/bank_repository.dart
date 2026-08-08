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

  Future<ApiResponse<Map<String, dynamic>>> getVendorDetail(String rcNumber) async {
    AppLogger.logInfo(_tag, 'Checking vendor detail for RC: $rcNumber');

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionGetVendorDetail,
      fields: {
        'rc_number': rcNumber,
      },
    );

    if (response.success) {
      return ApiResponse.success(response.data ?? {}, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<Map<String, dynamic>>> createVendorAccount(Map<String, dynamic> agentData) async {
    AppLogger.logInfo(_tag, 'Creating vendor account profile via TMS action');

    final String fullName = '${agentData['first_name'] ?? ''} ${agentData['last_name'] ?? ''}'.trim();

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionCreateBankAccount,
      fields: {
        'name': fullName,
        'email': agentData['email'],
        'rc_number': agentData['company_number'] ?? agentData['rc_number'] ?? '',
        'phone_number': agentData['phone_number'],
        'city': agentData['city'],
        'state': agentData['state'],
        'address': agentData['address'],
        'lga': agentData['lga'],
      },
    );

    if (response.success) {
      return ApiResponse.success(response.data ?? {}, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<Map<String, dynamic>>> addAgentBank(Map<String, dynamic> data) async {
    AppLogger.logInfo(_tag, 'Adding agent to bank system via TMS action');

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionAddAgentBank,
      fields: data,
    );

    if (response.success) {
      return ApiResponse.success(response.data ?? {}, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<Map<String, dynamic>>> createBankProfile({
    required String bvn,
    required String email,
  }) async {
    AppLogger.logInfo(_tag, 'Creating bank profile via Cyber1 API');

    final response = await ApiClient.instance.post(
      ApiConstants.createCustomerProfile,
      baseUrl: ApiConstants.cyber1BaseUrl,
      body: {
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
