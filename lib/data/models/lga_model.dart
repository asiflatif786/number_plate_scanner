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
      lgaId: json['lga_id']?.toString() ??
          json['id']?.toString() ??
          json['lga_name']?.toString() ??
          json['name']?.toString() ??
          '',
      lgaName: json['lga_name']?.toString() ??
          json['name']?.toString() ??
          json['lga']?.toString() ??
          '',
      stateId: json['state_id']?.toString() ?? '',
    );
  }

  @override
  String toString() => lgaName;
}
