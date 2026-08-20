import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/logger.dart';
import 'transaction_draft_model.dart';

class TransactionModel {
  static const String _tag = 'TxModel';
  final String transactionReference;
  final String? transactionId;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String vehicleLicense;
  final String? vehicleType;
  final double amount;
  final double serviceFee;
  final double totalAmount;
  final String paymentMethod;
  final String transactionType;
  final String? transactionState;
  final String status;
  final String originState;
  final String originLga;
  final String? originTown;
  final String destinationState;
  final String destinationLga;
  final String? destinationTown;
  final String agentNumber;
  final String terminalId;
  final String createdAt;
  final List<dynamic> rawPayload;

  const TransactionModel({
    required this.transactionReference,
    this.transactionId,
    this.customerName = 'N/A',
    this.customerPhone,
    this.customerEmail,
    this.vehicleLicense = 'N/A',
    this.vehicleType,
    this.amount = 0.0,
    this.serviceFee = 0.0,
    this.totalAmount = 0.0,
    this.paymentMethod = 'card',
    this.transactionType = 'single',
    this.transactionState,
    this.status = 'pending',
    this.originState = 'N/A',
    this.originLga = 'N/A',
    this.originTown,
    this.destinationState = 'N/A',
    this.destinationLga = 'N/A',
    this.destinationTown,
    this.agentNumber = '',
    this.terminalId = '',
    this.createdAt = '',
    this.rawPayload = const [],
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
    final meta = (details['metadata'] as Map<String, dynamic>?) ?? (json['metadata'] as Map<String, dynamic>?) ?? {};
    
    String getString(dynamic val, {String fallback = 'N/A'}) {
      if (val == null) return fallback;
      final s = val.toString().trim();
      if (s.isEmpty || s.toLowerCase() == 'null' || s.toUpperCase() == 'N/A') return fallback;
      return s;
    }

    String? getStringOrNull(dynamic val) {
      final s = getString(val, fallback: '');
      return s.isEmpty ? null : s;
    }

    final amountVal = _parseDouble(details['amount'] ?? json['amount'] ?? meta['amount'] ?? json['base_amount'] ?? meta['base_amount']);
    final feeVal = _parseDouble(details['fee'] ?? json['service_fee'] ?? json['fee'] ?? meta['fee'] ?? meta['service_fee'] ?? json['fee_amount']);
    final totalVal = _parseDouble(details['total'] ?? json['total'] ?? json['total_amount'] ?? meta['total_amount'] ?? json['total_paid'] ?? meta['total'] ?? json['amount_paid']);

    dynamic rawPayloadData = json['payload'] ?? meta['payload'] ?? details['payload'];
    List<dynamic> payloadList = [];
    
    if (rawPayloadData is List) {
      payloadList = rawPayloadData;
    } else if (rawPayloadData is String && rawPayloadData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPayloadData);
        if (decoded is List) {
          payloadList = decoded;
        }
      } catch (_) {}
    }

    return TransactionModel(
      transactionReference: getString(json['transaction_reference']) != 'N/A' ? getString(json['transaction_reference']) :
                           (getString(json['reference']) != 'N/A' ? getString(json['reference']) :
                           (getString(details['transaction_reference']) != 'N/A' ? getString(details['transaction_reference']) :
                           (getString(meta['transaction_reference']) != 'N/A' ? getString(meta['transaction_reference']) :
                           getString(meta['reference'])))),
      transactionId: getString(json['transaction_id'], fallback: ''),
      status: (json['status'] as String? ?? 'pending').toLowerCase(),
      totalAmount: totalVal > 0 ? totalVal : (amountVal + feeVal),
      customerName: getString(json['customer_name']) != 'N/A' ? getString(json['customer_name']) :
                    (getString(details['payer_name']) != 'N/A' ? getString(details['payer_name']) :
                    (getString(meta['payer_name']) != 'N/A' ? getString(meta['payer_name']) :
                    getString(meta['customer_name']))),
      customerPhone: getString(details['payer_phone']) != 'N/A' ? getString(details['payer_phone']) :
                     (getString(meta['contact']) != 'N/A' ? getString(meta['contact']) :
                     (getString(json['payer_phone']) != 'N/A' ? getString(json['payer_phone']) :
                     null)),
      customerEmail: getString(json['customer_email']) != 'N/A' ? getString(json['customer_email']) :
                     (getString(details['payer_email']) != 'N/A' ? getString(details['payer_email']) :
                     (getString(meta['payer_email']) != 'N/A' ? getString(meta['payer_email']) :
                     null)),
      vehicleLicense: getString(json['vehicle_license']) != 'N/A' ? getString(json['vehicle_license']) :
                      (getString(details['vehicle_license']) != 'N/A' ? getString(details['vehicle_license']) :
                      (getString(meta['vehicle_license']) != 'N/A' ? getString(meta['vehicle_license']) :
                      (getString(json['license_plate']) != 'N/A' ? getString(json['license_plate']) :
                      getString(meta['license_plate'])))),
      vehicleType: getString(details['vehicle_type']) != 'N/A' ? getString(details['vehicle_type']) :
                   (getString(meta['vehicle_type']) != 'N/A' ? getString(meta['vehicle_type']) :
                   getString(json['vehicle_type'], fallback: '')),
      amount: amountVal,
      serviceFee: feeVal,
      paymentMethod: getString(details['payment_method']) != 'N/A' ? getString(details['payment_method']) :
                     getString(json['payment_method'], fallback: 'card'),
      transactionType: getString(meta['transaction_type']) != 'N/A' ? getString(meta['transaction_type']) :
                       getString(json['transaction_type'], fallback: 'single'),
      transactionState: getStringOrNull(json['transaction_state']) ?? 
                        getStringOrNull(meta['transaction_category']) ?? 
                        getStringOrNull(meta['transaction_state']),
      originState: getString(details['origin_state']) != 'N/A' ? getString(details['origin_state']) :
                   (getString(json['origin_state']) != 'N/A' ? getString(json['origin_state']) : getString(meta['origin_state'])),
      originLga: getString(details['origin_lga']) != 'N/A' ? getString(details['origin_lga']) :
                 (getString(json['origin_lga']) != 'N/A' ? getString(json['origin_lga']) : getString(meta['origin_lga'])),
      originTown: getString(meta['origin_town']) != 'N/A' ? getString(meta['origin_town']) :
                  (getString(meta['origin_location']) != 'N/A' ? getString(meta['origin_location']) :
                  (getString(json['origin_location']) != 'N/A' ? getString(json['origin_location']) : null)),
      destinationState: getString(details['destination_state']) != 'N/A' ? getString(details['destination_state']) :
                        (getString(json['destination_state']) != 'N/A' ? getString(json['destination_state']) : getString(meta['destination_state'])),
      destinationLga: getString(details['destination_lga']) != 'N/A' ? getString(details['destination_lga']) :
                      (getString(json['destination_lga']) != 'N/A' ? getString(json['destination_lga']) : getString(meta['destination_lga'])),
      destinationTown: getString(meta['destination_town']) != 'N/A' ? getString(meta['destination_town']) :
                       (getString(meta['destination_location']) != 'N/A' ? getString(meta['destination_location']) :
                       (getString(json['destination_location']) != 'N/A' ? getString(json['destination_location']) : null)),
      agentNumber: getString(json['agent_number'], fallback: ''),
      terminalId: getString(details['terminal_id']) != 'N/A' ? getString(details['terminal_id']) :
                  (getString(json['terminal_id']) != 'N/A' ? getString(json['terminal_id']) : getString(meta['terminal_id'], fallback: '')),
      createdAt: getString(details['transaction_date']) != 'N/A' ? getString(details['transaction_date']) :
                 (getString(json['created_at']) != 'N/A' ? getString(json['created_at']) :
                 (getString(json['transaction_date']) != 'N/A' ? getString(json['transaction_date']) :
                 getString(meta['transaction_date'], fallback: ''))),
      rawPayload: payloadList,
    );
  }

  TransactionModel copyWith({
    String? status,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? vehicleLicense,
    String? vehicleType,
    double? amount,
    double? serviceFee,
    double? totalAmount,
    String? paymentMethod,
    String? transactionState,
    List<dynamic>? rawPayload,
  }) {
    return TransactionModel(
      transactionReference: transactionReference,
      transactionId: transactionId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      vehicleLicense: vehicleLicense ?? this.vehicleLicense,
      vehicleType: vehicleType ?? this.vehicleType,
      amount: amount ?? this.amount,
      serviceFee: serviceFee ?? this.serviceFee,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionType: transactionType,
      transactionState: transactionState ?? this.transactionState,
      status: status ?? this.status,
      originState: originState,
      originLga: originLga,
      originTown: originTown,
      destinationState: destinationState,
      destinationLga: destinationLga,
      destinationTown: destinationTown,
      agentNumber: agentNumber,
      terminalId: terminalId,
      createdAt: createdAt,
      rawPayload: rawPayload ?? this.rawPayload,
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
      customerPhone: other.customerPhone ?? customerPhone,
      customerEmail: other.customerEmail ?? customerEmail,
      vehicleLicense: !isInvalid(other.vehicleLicense) ? other.vehicleLicense : vehicleLicense,
      vehicleType: other.vehicleType ?? vehicleType,
      amount: other.amount > 0 ? other.amount : amount,
      serviceFee: other.serviceFee > 0 ? other.serviceFee : serviceFee,
      totalAmount: other.totalAmount > 0 ? other.totalAmount : totalAmount,
      paymentMethod: other.paymentMethod.toLowerCase() != 'card' ? other.paymentMethod : paymentMethod,
      transactionType: other.transactionType.isNotEmpty && other.transactionType != 'N/A' ? other.transactionType : transactionType,
      transactionState: other.transactionState ?? transactionState,
      originState: !isInvalid(other.originState) ? other.originState : originState,
      originLga: !isInvalid(other.originLga) ? other.originLga : originLga,
      originTown: other.originTown ?? originTown,
      destinationState: !isInvalid(other.destinationState) ? other.destinationState : destinationState,
      destinationLga: !isInvalid(other.destinationLga) ? other.destinationLga : destinationLga,
      destinationTown: other.destinationTown ?? destinationTown,
      agentNumber: !isInvalid(other.agentNumber) ? other.agentNumber : agentNumber,
      terminalId: !isInvalid(other.terminalId) ? other.terminalId : terminalId,
      createdAt: !isInvalid(other.createdAt) ? other.createdAt : createdAt,
      rawPayload: other.rawPayload.isNotEmpty ? other.rawPayload : rawPayload,
    );
  }

  Map<String, dynamic> toJson() => {
        'transaction_reference': transactionReference,
        'transaction_id': transactionId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_email': customerEmail,
        'vehicle_license': vehicleLicense,
        'vehicle_type': vehicleType,
        'amount': amount,
        'service_fee': serviceFee,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'transaction_type': transactionType,
        'transaction_state': transactionState,
        'status': status,
        'origin_state': originState,
        'origin_lga': originLga,
        'origin_town': originTown,
        'destination_state': destinationState,
        'destination_lga': destinationLga,
        'destination_town': destinationTown,
        'agent_number': agentNumber,
        'terminal_id': terminalId,
        'created_at': createdAt,
        'payload': rawPayload,
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
