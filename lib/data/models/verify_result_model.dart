class VerifyResultModel {
  final String transactionReference;
  final String status;
  final double amount;
  final double fee;

  const VerifyResultModel({
    required this.transactionReference,
    required this.status,
    this.amount = 0.0,
    this.fee = 0.0,
  });

  factory VerifyResultModel.fromJson(Map<String, dynamic> json) {
    return VerifyResultModel(
      transactionReference:
          json['transaction_reference'] as String? ?? '',
      status:
          (json['status'] as String? ?? 'pending').toLowerCase(),
      amount: _parseDouble(json['amount']),
      fee: _parseDouble(json['fee']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
