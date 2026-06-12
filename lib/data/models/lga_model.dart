class LgaModel {
  final String lgaId;
  final String lgaName;
  final String stateId;

  const LgaModel({
    required this.lgaId,
    required this.lgaName,
    required this.stateId,
  });

  factory LgaModel.fromJson(Map<String, dynamic> json) {
    return LgaModel(
      lgaId: json['lga_id'] as String? ?? '',
      lgaName: json['lga_name'] as String? ?? '',
      stateId: json['state_id'] as String? ?? '',
    );
  }

  @override
  String toString() => lgaName;
}
