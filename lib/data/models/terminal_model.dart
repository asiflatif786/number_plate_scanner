class TerminalModel {
  final String serialNumber;
  final String terminalId;
  final String agentNumber;

  const TerminalModel({
    required this.serialNumber,
    required this.terminalId,
    required this.agentNumber,
  });

  factory TerminalModel.fromJson(Map<String, dynamic> json) {
    return TerminalModel(
      serialNumber: json['serial_number'] as String? ?? '',
      terminalId: json['terminal_id'] as String? ?? '',
      agentNumber: json['agent_number'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'serial_number': serialNumber,
        'terminal_id': terminalId,
        'agent_number': agentNumber,
      };

  TerminalModel copyWith({
    String? serialNumber,
    String? terminalId,
    String? agentNumber,
  }) {
    return TerminalModel(
      serialNumber: serialNumber ?? this.serialNumber,
      terminalId: terminalId ?? this.terminalId,
      agentNumber: agentNumber ?? this.agentNumber,
    );
  }
}
