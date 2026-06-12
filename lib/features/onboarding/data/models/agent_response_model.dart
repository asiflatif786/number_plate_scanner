import '../../../../core/utils/logger.dart';

class AgentResponseModel {
  final String statusCode;
  final String message;
  final String? agentNumber;

  const AgentResponseModel({
    required this.statusCode,
    required this.message,
    this.agentNumber,
  });

  factory AgentResponseModel.fromJson(Map<String, dynamic> json) {
    final statusCode = json['status_code'] as String? ?? '99';
    final message = json['message'] as String? ?? '';
    final agentNumber = json['data'] is Map
        ? (json['data'] as Map)['agent_number'] as String?
        : null;

    AppLogger.debug('AgentResponseModel',
        'Parsed: status_code=$statusCode, message=$message, agent_number=$agentNumber');

    return AgentResponseModel(
      statusCode: statusCode,
      message: message,
      agentNumber: agentNumber,
    );
  }
}
