import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/terminal_entity.dart';
import '../../domain/repositories/terminal_repository.dart';
import '../models/terminal_model.dart';

class TerminalRepositoryImpl implements TerminalRepository {
  static const String _tag = 'TerminalRepo';
  final NetworkClient _networkClient;

  TerminalRepositoryImpl({required NetworkClient networkClient})
      : _networkClient = networkClient;

  @override
  Future<void> createTerminalProfile(TerminalEntity terminal) async {
    AppLogger.info(_tag,
        'Profiling terminal: ${terminal.terminalId} for agent: ${terminal.agentNumber}');

    try {
      final json = TerminalModel.toJson(terminal);
      final response = await _networkClient.post(
        ApiConstants.createTerminal,
        body: json,
      );

      final statusCode = response['status_code'] as String? ?? '99';
      if (statusCode != '00') {
        final message = response['message'] as String? ?? 'Failed to profile terminal';
        AppLogger.error(_tag, 'Terminal profiling failed: $message');
        throw ServerFailure(message);
      }

      AppLogger.success(_tag,
          'Terminal profiled successfully: ${terminal.terminalId}');
    } catch (e) {
      AppLogger.error(_tag, 'Failed to profile terminal', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTerminalProfile(String terminalId) async {
    AppLogger.info(_tag, 'Fetching terminal profile: $terminalId');

    try {
      final response = await _networkClient.get(
        ApiConstants.getTerminalProfile,
        queryParams: {'tid': terminalId},
      );

      AppLogger.success(_tag, 'Terminal profile fetched');
      return response;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch terminal profile', e);
      rethrow;
    }
  }

  @override
  Future<bool> getTerminalStatus(String terminalId) async {
    AppLogger.info(_tag, 'Fetching terminal status: $terminalId');

    try {
      final response = await _networkClient.get(
        ApiConstants.terminalStatus,
        queryParams: {'tid': terminalId},
      );

      final status = response['data'] is Map
          ? (response['data'] as Map)['status'] as String?
          : null;
      final isActive = status?.toLowerCase() == 'active';
      AppLogger.info(_tag, 'Terminal status: $status → active: $isActive');
      return isActive;
    } catch (e) {
      AppLogger.error(_tag, 'Failed to fetch terminal status', e);
      rethrow;
    }
  }

  @override
  Future<void> assignTerminal(String terminalId, String agentNumber) async {
    AppLogger.info(_tag, 'Assigning terminal $terminalId to agent $agentNumber');

    try {
      await _networkClient.put(
        ApiConstants.assignTerminal,
        body: {
          'terminal_id': terminalId,
          'agent_number': agentNumber,
        },
      );

      AppLogger.success(_tag, 'Terminal $terminalId assigned to agent $agentNumber');
    } catch (e) {
      AppLogger.error(_tag, 'Failed to assign terminal', e);
      rethrow;
    }
  }

  @override
  Future<void> enableDisableTerminal(String terminalId) async {
    AppLogger.info(_tag, 'Toggling terminal status: $terminalId');

    try {
      await _networkClient.get(
        ApiConstants.enableDisableTerminal,
        queryParams: {'tid': terminalId},
      );

      AppLogger.success(_tag, 'Terminal status toggled: $terminalId');
    } catch (e) {
      AppLogger.error(_tag, 'Failed to toggle terminal status', e);
      rethrow;
    }
  }
}
