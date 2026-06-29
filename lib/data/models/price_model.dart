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
      amount: _parseDouble(json['amount'] ?? json['price'] ?? json['base_amount'] ?? json['baseAmount'] ?? json['total_paid']),
      serviceFee: _parseDouble(
        json['convenience_fee'] ?? 
        json['convience_fee'] ?? 
        json['service_fee'] ?? 
        json['fee'] ?? 
        json['fee_amount'] ?? 
        json['admin_fee'] ?? 
        json['serviceFee'] ?? 
        json['total_fee'] ??
        json['charge']
      ),
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
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty || s.toUpperCase() == 'N/A' || s.toLowerCase() == 'null') return 0.0;
      return double.tryParse(s.replaceAll(',', '')) ?? 0.0;
    }
    return 0.0;
  }
}
