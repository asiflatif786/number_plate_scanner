import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/logger.dart';
import '../models/agent_model.dart';

class AgentRepository {
  static const String _tag = 'AgentRepo';

  int totalPages = 1;
  int totalAgents = 0;

  Future<ApiResponse<List<AgentModel>>> listAgents({
    required String channelNumber,
    int page = 1,
  }) async {
    AppLogger.logInfo(_tag, 'Listing agents (page $page)');

    final response = await ApiClient.instance.get(
      ApiConstants.listAgents,
      queryParams: {
        'channel_number': channelNumber,
        'page': page.toString(),
      },
    );

    if (response.success && response.data != null) {
      totalPages = response.data!['total_pages'] as int? ?? 1;
      totalAgents = response.data!['total'] as int? ?? 0;
      final raw = response.data!['data_list'] as List<dynamic>? ?? [];
      final agents = raw
          .map((e) => AgentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.logInfo(_tag, 'Loaded ${agents.length} agents (page $page/$totalPages)');
      return ApiResponse.success(agents, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<List<AgentModel>>> getAllAgents() async {
    AppLogger.logInfo(_tag, 'Getting all agents via TMS POST');

    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionGetAllAgents,
    );

    if (response.success && response.data != null) {
      final raw = response.data!['data_list'] as List<dynamic>? ?? [];
      final agents = raw
          .map((e) => AgentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      totalAgents = agents.length;
      totalPages = 1;
      AppLogger.logInfo(_tag, 'Successfully retrieved ${agents.length} agents');
      return ApiResponse.success(agents, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<AgentModel>> getAgent({
    required String agentNumber,
  }) async {
    AppLogger.logInfo(_tag, 'Getting agent: $agentNumber');

    final response = await ApiClient.instance.get(
      ApiConstants.getAgent,
      queryParams: {'agent_number': agentNumber},
    );

    if (response.success && response.data != null) {
      final agent = AgentModel.fromJson(response.data!);
      return ApiResponse.success(agent, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<String>> getAgentStatus({
    required String agentNumber,
  }) async {
    AppLogger.logInfo(_tag, 'Getting status for agent: $agentNumber');

    final response = await ApiClient.instance.get(
      ApiConstants.getAgentStatus,
      queryParams: {'agent_number': agentNumber},
    );

    if (response.success && response.data != null) {
      final status = response.data!['status'] as String? ?? 'unknown';
      return ApiResponse.success(status, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> getAgentKycStatus({
    required String agentNumber,
  }) async {
    AppLogger.logInfo(_tag, 'Getting KYC status for agent: $agentNumber');

    final response = await ApiClient.instance.get(
      ApiConstants.getAgentKycStatus,
      queryParams: {'agent_number': agentNumber},
    );

    if (response.success && response.data != null) {
      final complete = response.data!['kyc_complete'] as bool? ?? false;
      return ApiResponse.success(complete, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> getCompanyKycStatus({
    required String companyNumber,
  }) async {
    AppLogger.logInfo(_tag, 'Getting KYC status for company: $companyNumber');

    final response = await ApiClient.instance.get(
      ApiConstants.getCompanyKycStatus,
      queryParams: {'company_number': companyNumber},
    );

    if (response.success && response.data != null) {
      final complete = response.data!['kyc_complete'] as bool? ?? false;
      return ApiResponse.success(complete, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<String>> getCompanyStatus({
    required String companyNumber,
  }) async {
    AppLogger.logInfo(_tag, 'Getting status for company: $companyNumber');

    final response = await ApiClient.instance.get(
      ApiConstants.getCompanyStatus,
      queryParams: {'company_number': companyNumber},
    );

    if (response.success && response.data != null) {
      final status = response.data!['status'] as String? ?? 'unknown';
      return ApiResponse.success(status, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }

  Future<ApiResponse<bool>> assignAgentToCompany({
    required String agentNumber,
    required String companyNumber,
  }) async {
    AppLogger.logInfo(_tag, 'Assigning $agentNumber to company $companyNumber');

    final response = await ApiClient.instance.put(
      ApiConstants.assignAgentToCompany,
      body: {
        'agent_number': agentNumber,
        'company_number': companyNumber,
      },
    );

    if (response.success) {
      AppLogger.logInfo(_tag, 'Assigned successfully');
      return ApiResponse.success(true, response.message);
    }

    AppLogger.logWarning(_tag, 'Assignment failed: ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }
}
