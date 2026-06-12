import '../entities/agent_entity.dart';

abstract class AgentRepository {
  Future<String> registerAgent(AgentEntity agent);
  Future<Map<String, dynamic>> getAgentDetails(String agentNumber);
  Future<bool> getAgentStatus(String agentNumber);
  Future<void> assignAgentToCompany(String companyNumber, String agentNumber);
}
