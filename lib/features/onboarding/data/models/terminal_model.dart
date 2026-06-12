import 'dart:convert';
import '../../domain/entities/terminal_entity.dart';
import '../../../../core/utils/logger.dart';

class TerminalModel {
  static const String _tag = 'TerminalModel';

  static Map<String, dynamic> toJson(TerminalEntity entity) {
    final json = <String, dynamic>{
      'serial_number': entity.serialNumber,
      'terminal_id': entity.terminalId,
      'agent_number': entity.agentNumber,
    };

    AppLogger.debug(_tag, 'Payload: ${jsonEncode(json)}');
    return json;
  }

  static TerminalEntity fromJson(Map<String, dynamic> json) {
    return TerminalEntity(
      serialNumber: json['serial_number'] as String? ?? '',
      terminalId: json['terminal_id'] as String? ?? '',
      agentNumber: json['agent_number'] as String? ?? '',
    );
  }
}
