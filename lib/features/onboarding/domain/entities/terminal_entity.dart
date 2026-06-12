class TerminalEntity {
  final String serialNumber;
  final String terminalId;
  final String agentNumber;

  const TerminalEntity({
    required this.serialNumber,
    required this.terminalId,
    required this.agentNumber,
  });

  TerminalEntity copyWith({
    String? serialNumber,
    String? terminalId,
    String? agentNumber,
  }) {
    return TerminalEntity(
      serialNumber: serialNumber ?? this.serialNumber,
      terminalId: terminalId ?? this.terminalId,
      agentNumber: agentNumber ?? this.agentNumber,
    );
  }

  @override
  String toString() {
    return 'TerminalEntity(terminalId: $terminalId, agentNumber: $agentNumber)';
  }
}
