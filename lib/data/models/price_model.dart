import 'package:intl/intl.dart';

class PriceModel {
  final double amount;
  final double serviceFee;
  final String currency;

  double get totalAmount => amount + serviceFee;

  const PriceModel({
    required this.amount,
    this.serviceFee = 0.0,
    this.currency = 'NGN',
  });

  String get formattedTotal => _format(totalAmount);
  String get formattedAmount => _format(amount);
  String get formattedServiceFee => _format(serviceFee);

  String _format(double value) {
    return NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(value);
  }

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      amount: _parseDouble(json['price'] ?? json['amount']),
      serviceFee: _parseDouble(json['service_fee']),
      currency: json['currency'] as String? ?? 'NGN',
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'service_fee': serviceFee,
        'currency': currency,
      };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
