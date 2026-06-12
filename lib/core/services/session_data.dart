class SessionData {
  final String? companyNumber;
  final String? agentNumber;
  final String? terminalId;
  final bool isComplete;

  const SessionData({
    this.companyNumber,
    this.agentNumber,
    this.terminalId,
    required this.isComplete,
  });

  bool get isValid =>
      companyNumber != null &&
      companyNumber!.isNotEmpty &&
      agentNumber != null &&
      agentNumber!.isNotEmpty &&
      terminalId != null &&
      terminalId!.isNotEmpty &&
      isComplete;

  @override
  String toString() {
    return 'SessionData(company: $companyNumber, agent: $agentNumber, '
        'terminal: $terminalId, complete: $isComplete)';
  }
}
