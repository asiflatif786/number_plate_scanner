import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/agent_entity.dart';
import '../../domain/repositories/agent_repository.dart';
import '../models/agent_model.dart';
import '../models/agent_response_model.dart';

class AgentRepositoryImpl implements AgentRepository {
  static const String _tag = 'AgentRepo';
  final NetworkClient _networkClient;

  AgentRepositoryImpl({required NetworkClient networkClient})
      : _networkClient = networkClient;

  @override
  Future<String> registerAgent(AgentEntity agent) async {
    AppLogger.info(
        _tag, 'Registering agent: ${agent.firstName} ${agent.lastName}');

    try {
      final json = AgentModel.toJson(agent);
      final response = await _networkClient.post(
        ApiConstants.actionAddAgent,
        body: json,
      );

      final responseModel = AgentResponseModel.fromJson(response);
      final agentNumber = responseModel.agentNumber;

      if (agentNumber == null || agentNumber.isEmpty) {
        AppLogger.error(_tag, 'Agent number not found in response');
        throw const ServerFailure('Agent number not found in response');
      }

      AppLogger.success(_tag, 'Agent registered: $agentNumber');
      return agentNumber;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to register agent', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAgentDetails(String agentNumber) async {
    AppLogger.info(_tag, 'Fetching agent details: $agentNumber');

    try {
      final response = await _networkClient.get(
        ApiConstants.actionGetAgentDetails,
        queryParams: {'agent_number': agentNumber},
      );

      AppLogger.success(_tag, 'Agent details fetched');
      return response;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch agent details', e);
      rethrow;
    }
  }

  @override
  Future<bool> getAgentStatus(String agentNumber) async {
    AppLogger.info(_tag, 'Fetching agent status: $agentNumber');

    try {
      final response = await _networkClient.get(
        ApiConstants.actionGetAgentStatus,
        queryParams: {'agent_number': agentNumber},
      );

      final status = response['data'] is Map
          ? (response['data'] as Map)['status'] as String?
          : null;
      final isActive = status?.toLowerCase() == 'active';
      AppLogger.info(_tag, 'Agent status: $status → active: $isActive');
      return isActive;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch agent status', e);
      rethrow;
    }
  }

  @override
  Future<void> assignAgentToCompany(
      String companyNumber, String agentNumber) async {
    AppLogger.info(
        _tag, 'Assigning agent $agentNumber to company $companyNumber');

    try {
      await _networkClient.put(
        ApiConstants.actionAssignAgentToCompany,
        body: {
          'company_number': companyNumber,
          'agent_number': agentNumber,
        },
      );

      AppLogger.success(
          _tag, 'Agent $agentNumber assigned to company $companyNumber');
    } catch (e) {
      AppLogger.error(_tag, 'Failed to assign agent to company', e);
      rethrow;
    }
  }
}
