import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../data/models/agent_model.dart';
import '../../data/models/company_model.dart';
import '../../data/models/state_model.dart';

class OnboardingRepository {
  Future<ApiResponse<CompanyModel>> createCompany(
    Map<String, dynamic> formData,
  ) async {
    // POST to /api_data with action: 'create-company'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionCreateCompany,
      fields: formData,
    );

    if (response.success && response.data != null) {
      final companyNumber = response.data!['company_number'] as String? ?? '';
      final company = CompanyModel(
        companyNumber: companyNumber,
        name: formData['name'] as String? ?? '',
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

  Future<ApiResponse<List<StateModel>>> getStates() async {
    // POST to /api_data with action: 'get-states'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionGetStates,
    );

    if (response.success && response.data != null) {
      final raw = response.data!['data'] ?? response.data!['data_list'];
      if (raw is List) {
        final states = raw.map((e) {
          if (e is Map<String, dynamic>) return StateModel.fromJson(e);
          final name = e.toString();
          return StateModel(stateId: name, stateName: name);
        }).where((s) => s.stateName.isNotEmpty).toList();
        return ApiResponse.success(states, response.message);
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<AgentModel>> addAgent(
    Map<String, dynamic> formData,
  ) async {
    // POST to /api_data with action: 'add-agent'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionAddAgent,
      fields: formData,
    );

    if (response.success && response.data != null) {
      final agent = AgentModel.fromJson(response.data!);
      return ApiResponse.success(agent, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<List<String>>> getLgas(String stateId) async {
    // POST to /api_data with action: 'get-lgas'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionGetLgas,
      fields: {'state_id': stateId},
    );

    if (response.success && response.data != null) {
      final raw = response.data!['data'] ?? response.data!['data_list'];
      if (raw is List) {
        final lgas = raw
            .map((e) {
              if (e is String) return e;
              if (e is Map<String, dynamic>) {
                return e['lga_name']?.toString() ??
                    e['name']?.toString() ??
                    '';
              }
              return e.toString();
            })
            .where((e) => e.isNotEmpty)
            .toList();
        return ApiResponse.success(lgas, response.message);
      }
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<void>> createTerminal({
    required String serialNumber,
    required String terminalId,
    required String agentNumber,
  }) async {
    // POST to /api_data with action: 'create-terminal'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionCreateTerminal,
      fields: {
        'serial_number': serialNumber,
        'terminal_id': terminalId,
        'agent_number': agentNumber,
      },
    );

    if (response.success) {
      return ApiResponse.success(null, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
