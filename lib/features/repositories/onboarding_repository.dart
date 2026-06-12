import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../data/models/agent_model.dart';
import '../../data/models/company_model.dart';

class OnboardingRepository {
  Future<ApiResponse<CompanyModel>> createCompany(
    Map<String, dynamic> formData,
  ) async {
    final payload = {
      'action': ApiConstants.actionCreateCompany,
      ...formData,
    };

    final response = await ApiClient.instance.post(payload);

    if (response.success && response.data != null) {
      final companyNumber = response.data!['company_number'] as String? ?? '';
      final company = CompanyModel(
        companyNumber: companyNumber,
        name: formData['company_name'] as String? ?? '',
        rcNumber: formData['rc_number'] as String? ?? '',
        email: formData['email'] as String? ?? '',
        phoneNumber: formData['phone_number'] as String? ?? '',
        address: formData['address'] as String? ?? '',
        contactAddress: formData['contact_address'] as String? ?? '',
        tin: formData['tin'] as String? ?? '',
        city: formData['city'] as String? ?? '',
        state: formData['state'] as String? ?? '',
        lga: formData['lga'] as String? ?? '',
      );
      return ApiResponse.success(company, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<List<String>>> getStates() async {
    final response = await ApiClient.instance.post({
      'action': ApiConstants.actionGetStates,
    });

    if (response.success && response.data != null) {
      final raw = response.data!['data_list'] as List<dynamic>? ?? [];
      final states = raw.cast<String>();
      return ApiResponse.success(states, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<AgentModel>> addAgent(
    Map<String, dynamic> formData,
  ) async {
    final payload = {
      'action': ApiConstants.actionAddAgent,
      ...formData,
    };

    final response = await ApiClient.instance.post(payload);

    if (response.success && response.data != null) {
      final agent = AgentModel.fromJson(response.data!);
      return ApiResponse.success(agent, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<List<String>>> getLgas(String stateName) async {
    final response = await ApiClient.instance.post({
      'action': ApiConstants.actionGetLgas,
      'state_name': stateName,
    });

    if (response.success && response.data != null) {
      final raw = response.data!['data_list'] as List<dynamic>? ?? [];
      final lgas = raw.cast<String>();
      return ApiResponse.success(lgas, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<void>> createTerminal({
    required String serialNumber,
    required String terminalId,
    required String agentNumber,
  }) async {
    final payload = {
      'action': ApiConstants.actionCreateTerminal,
      'serial_number': serialNumber,
      'terminal_id': terminalId,
      'agent_number': agentNumber,
    };

    final response = await ApiClient.instance.post(payload);

    if (response.success) {
      return ApiResponse.success(null, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
