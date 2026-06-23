import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/logger.dart';
import 'transaction_draft_model.dart';

class TransactionModel {
  static const String _tag = 'TxModel';
  final String transactionReference;
  final String? transactionId;
  final String customerName;
  final String vehicleLicense;
  final double amount;
  final double serviceFee;
  final double totalAmount;
  final String paymentMethod;
  final String transactionType;
  final String status;
  final String originState;
  final String originLga;
  final String destinationState;
  final String destinationLga;
  final String agentNumber;
  final String terminalId;
  final String createdAt;

  const TransactionModel({
    required this.transactionReference,
    this.transactionId,
    this.customerName = 'N/A',
    this.vehicleLicense = 'N/A',
    this.amount = 0.0,
    this.serviceFee = 0.0,
    this.totalAmount = 0.0,
    this.paymentMethod = 'card',
    this.transactionType = 'single',
    this.status = 'pending',
    this.originState = 'N/A',
    this.originLga = 'N/A',
    this.destinationState = 'N/A',
    this.destinationLga = 'N/A',
    this.agentNumber = '',
    this.terminalId = '',
    this.createdAt = '',
  });

  String get formattedTotal =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 2)
          .format(totalAmount);

  String get formattedAmount =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 2).format(amount);

  String get formattedServiceFee =>
      NumberFormat.currency(symbol: '₦', decimalDigits: 2)
          .format(serviceFee);

  String get paymentMethodDisplay {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
        return 'Card Payment';
      case 'wallet':
        return 'Wallet';
      case 'transfer':
        return 'Bank Transfer';
      case 'squad':
        return 'Squad (Online)';
      default:
        return paymentMethod;
    }
  }

  Color get statusColor {
    final s = status.toLowerCase();
    // Use green for all successful/finalized states
    if (s == 'confirmed' || s == 'approved' || s == 'paid' || s == 'success' || s == 'successful') {
      return Colors.green.shade700;
    }
    if (s == 'pending' || s == 'created') return Colors.amber.shade800;
    if (s == 'declined' || s == 'failed') return Colors.red.shade700;
    return Colors.grey;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final details = json['transaction_details'] as Map<String, dynamic>? ?? {};
    final meta = json['metadata'] as Map<String, dynamic>? ?? {};
    
    String getString(dynamic val, {String fallback = 'N/A'}) {
      if (val == null) return fallback;
      final s = val.toString().trim();
      if (s.isEmpty || s.toLowerCase() == 'null' || s.toUpperCase() == 'N/A') return fallback;
      return s;
    }

    return TransactionModel(
      transactionReference: getString(json['transaction_reference']) != 'N/A' ? getString(json['transaction_reference']) :
                           (getString(json['reference']) != 'N/A' ? getString(json['reference']) :
                           (getString(meta['transaction_reference']) != 'N/A' ? getString(meta['transaction_reference']) :
                           getString(meta['reference']))),
      transactionId: getString(json['transaction_id'], fallback: ''),
      status: (json['status'] as String? ?? 'pending').toLowerCase(),
      totalAmount: _parseDouble(
          details['total'] ?? json['total'] ?? json['total_amount'] ?? meta['total_amount'] ?? json['total_paid'] ?? meta['total'] ?? json['amount_paid']),
      customerName: getString(json['customer_name']) != 'N/A' ? getString(json['customer_name']) :
                    (getString(json['payer_name']) != 'N/A' ? getString(json['payer_name']) :
                    (getString(meta['payer_name']) != 'N/A' ? getString(meta['payer_name']) :
                    getString(meta['customer_name']))),
      vehicleLicense: getString(json['vehicle_license']) != 'N/A' ? getString(json['vehicle_license']) :
                      (getString(meta['vehicle_license']) != 'N/A' ? getString(meta['vehicle_license']) :
                      (getString(json['license_plate']) != 'N/A' ? getString(json['license_plate']) :
                      getString(meta['license_plate']))),
      amount: _parseDouble(json['amount'] ?? meta['amount'] ?? json['base_amount'] ?? meta['base_amount']),
      serviceFee: _parseDouble(json['service_fee'] ?? json['fee'] ?? meta['fee'] ?? meta['service_fee'] ?? json['fee_amount'] ?? json['service_fee']),
      paymentMethod: getString(json['payment_method'], fallback: 'card'),
      transactionType: getString(json['transaction_type'], fallback: 'single'),
      originState: getString(json['origin_state']) != 'N/A' ? getString(json['origin_state']) : getString(meta['origin_state']),
      originLga: getString(json['origin_lga']) != 'N/A' ? getString(json['origin_lga']) : getString(meta['origin_lga']),
      destinationState: getString(json['destination_state']) != 'N/A' ? getString(json['destination_state']) : getString(meta['destination_state']),
      destinationLga: getString(json['destination_lga']) != 'N/A' ? getString(json['destination_lga']) : getString(meta['destination_lga']),
      agentNumber: getString(json['agent_number'], fallback: ''),
      terminalId: getString(json['terminal_id']) != 'N/A' ? getString(json['terminal_id']) : getString(meta['terminal_id'], fallback: ''),
      createdAt: getString(json['created_at']) != 'N/A' ? getString(json['created_at']) :
                 (getString(json['transaction_date']) != 'N/A' ? getString(json['transaction_date']) :
                 getString(meta['transaction_date'], fallback: '')),
    );
  }

  TransactionModel copyWith({
    String? status,
    String? customerName,
    String? vehicleLicense,
    double? amount,
    double? serviceFee,
    double? totalAmount,
  }) {
    return TransactionModel(
      transactionReference: transactionReference,
      transactionId: transactionId,
      customerName: customerName ?? this.customerName,
      vehicleLicense: vehicleLicense ?? this.vehicleLicense,
      amount: amount ?? this.amount,
      serviceFee: serviceFee ?? this.serviceFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod,
      transactionType: transactionType,
      status: status ?? this.status,
      originState: originState,
      originLga: originLga,
      destinationState: destinationState,
      destinationLga: destinationLga,
      agentNumber: agentNumber,
      terminalId: terminalId,
      createdAt: createdAt,
    );
  }

  /// Merges two models, protecting local data from being overwritten by "N/A"
  TransactionModel merge(TransactionModel other) {
    bool isInvalid(String val) => val == 'N/A' || val.trim().isEmpty;

    return TransactionModel(
      transactionReference: other.transactionReference.isNotEmpty && other.transactionReference != 'N/A' ? other.transactionReference : transactionReference,
      transactionId: (other.transactionId != null && other.transactionId!.isNotEmpty) ? other.transactionId : transactionId,
      status: other.status, 
      customerName: !isInvalid(other.customerName) ? other.customerName : customerName,
      vehicleLicense: !isInvalid(other.vehicleLicense) ? other.vehicleLicense : vehicleLicense,
      amount: other.amount > 0 ? other.amount : amount,
      serviceFee: other.serviceFee > 0 ? other.serviceFee : serviceFee,
      totalAmount: other.totalAmount > 0 ? other.totalAmount : totalAmount,
      paymentMethod: other.paymentMethod.toLowerCase() != 'card' ? other.paymentMethod : paymentMethod,
      transactionType: other.transactionType.isNotEmpty && other.transactionType != 'N/A' ? other.transactionType : transactionType,
      originState: !isInvalid(other.originState) ? other.originState : originState,
      originLga: !isInvalid(other.originLga) ? other.originLga : originLga,
      destinationState: !isInvalid(other.destinationState) ? other.destinationState : destinationState,
      destinationLga: !isInvalid(other.destinationLga) ? other.destinationLga : destinationLga,
      agentNumber: !isInvalid(other.agentNumber) ? other.agentNumber : agentNumber,
      terminalId: !isInvalid(other.terminalId) ? other.terminalId : terminalId,
      createdAt: !isInvalid(other.createdAt) ? other.createdAt : createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'transaction_reference': transactionReference,
        'transaction_id': transactionId,
        'customer_name': customerName,
        'vehicle_license': vehicleLicense,
        'amount': amount,
        'service_fee': serviceFee,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'transaction_type': transactionType,
        'status': status,
        'origin_state': originState,
        'origin_lga': originLga,
        'destination_state': destinationState,
        'destination_lga': destinationLga,
        'agent_number': agentNumber,
        'terminal_id': terminalId,
        'created_at': createdAt,
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
