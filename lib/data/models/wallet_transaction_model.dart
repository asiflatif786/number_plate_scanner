import 'package:intl/intl.dart';

class WalletTransactionModel {
  final String walletNumber;
  final String reference;
  final String transactionType; // 'D' for Debit, 'C' for Credit
  final double amount;
  final double previousBalance;
  final double currentBalance;
  final String? createdAt;

  const WalletTransactionModel({
    required this.walletNumber,
    required this.reference,
    required this.transactionType,
    required this.amount,
    required this.previousBalance,
    required this.currentBalance,
    this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    double _parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) {
        return double.tryParse(val.replaceAll(',', '')) ?? 0.0;
      }
      return 0.0;
    }

    return WalletTransactionModel(
      walletNumber: json['wallet_number']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? 'D',
      amount: _parseDouble(json['amount']),
      previousBalance: _parseDouble(json['previous_balance']),
      currentBalance: _parseDouble(json['current_balance']),
      createdAt: json['transaction_date']?.toString() ?? json['created_at']?.toString(),
    );
  }

  String get formattedAmount =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 2).format(amount);

  String get formattedCurrentBalance =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 2).format(currentBalance);
      
  bool get isDebit => transactionType.toUpperCase() == 'D';
}
