import '../entities/terminal_entity.dart';

abstract class TerminalRepository {
  Future<void> createTerminalProfile(TerminalEntity terminal);
  Future<Map<String, dynamic>> getTerminalProfile(String terminalId);
  Future<bool> getTerminalStatus(String terminalId);
  Future<void> assignTerminal(String terminalId, String agentNumber);
  Future<void> enableDisableTerminal(String terminalId);
}
