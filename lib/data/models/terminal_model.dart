class TerminalModel {
  final int id;
  final String terminalId;
  final String serialNumber;
  final String agentNumber;
  final String status;
  final String? tmsResponse;
  final String createdAt;
  final String updatedAt;

  const TerminalModel({
    required this.id,
    required this.terminalId,
    required this.serialNumber,
    required this.agentNumber,
    required this.status,
    this.tmsResponse,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TerminalModel.fromJson(Map<String, dynamic> json) {
    return TerminalModel(
      id: json['id'] as int? ?? 0,
      terminalId: json['terminal_id'] as String? ?? '',
      serialNumber: json['serial_number'] as String? ?? '',
      agentNumber: json['agent_number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      tmsResponse: json['tms_response'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'terminal_id': terminalId,
        'serial_number': serialNumber,
        'agent_number': agentNumber,
        'status': status,
        'tms_response': tmsResponse,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  TerminalModel copyWith({
    int? id,
    String? terminalId,
    String? serialNumber,
    String? agentNumber,
    String? status,
    String? tmsResponse,
    String? createdAt,
    String? updatedAt,
  }) {
    return TerminalModel(
      id: id ?? this.id,
      terminalId: terminalId ?? this.terminalId,
      serialNumber: serialNumber ?? this.serialNumber,
      agentNumber: agentNumber ?? this.agentNumber,
      status: status ?? this.status,
      tmsResponse: tmsResponse ?? this.tmsResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
