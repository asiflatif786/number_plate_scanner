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
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2)
          .format(totalAmount);

  String get formattedAmount =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(amount);

  String get formattedServiceFee =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2)
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
    switch (status.toLowerCase()) {
      case 'approved':
      case 'confirmed':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'declined':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final details = json['transaction_details'] as Map<String, dynamic>? ?? {};
    AppLogger.logDebug(_tag,
        'fromJson: ref=${json['transaction_reference']} status=${json['status']}');
    return TransactionModel(
      transactionReference: json['transaction_reference'] as String? ?? '',
      transactionId: json['transaction_id'] as String?,
      status: (json['status'] as String? ?? 'pending').toLowerCase(),
      totalAmount: _parseDouble(
          details['total'] ?? json['total'] ?? json['total_amount']),
      customerName: json['customer_name'] as String? ??
          json['payer_name'] as String? ??
          'N/A',
      vehicleLicense: json['vehicle_license'] as String? ??
          (json['metadata'] is Map<String, dynamic>
              ? json['metadata']['vehicle_license'] as String?
              : null) ??
          'N/A',
      amount: _parseDouble(json['amount']),
      serviceFee: _parseDouble(json['service_fee'] ?? json['fee']),
      paymentMethod: json['payment_method'] as String? ?? 'card',
      transactionType: json['transaction_type'] as String? ??
          (json['metadata'] is Map<String, dynamic>
              ? json['metadata']['transaction_type'] as String?
              : null) ??
          'single',
      originState: json['origin_state'] as String? ??
          (json['metadata'] is Map<String, dynamic>
              ? json['metadata']['origin_state'] as String?
              : null) ??
          'N/A',
      originLga: json['origin_lga'] as String? ??
          (json['metadata'] is Map<String, dynamic>
              ? json['metadata']['origin_lga'] as String?
              : null) ??
          'N/A',
      destinationState: json['destination_state'] as String? ??
          (json['metadata'] is Map<String, dynamic>
              ? json['metadata']['destination_state'] as String?
              : null) ??
          'N/A',
      destinationLga: json['destination_lga'] as String? ??
          (json['metadata'] is Map<String, dynamic>
              ? json['metadata']['destination_lga'] as String?
              : null) ??
          'N/A',
      agentNumber: json['agent_number'] as String? ?? '',
      terminalId: json['terminal_id'] as String? ?? '',
      createdAt: json['created_at'] as String? ??
          json['transaction_date'] as String? ??
          '',
    );
  }

  factory TransactionModel.fromDraftAndResponse(
    TransactionDraftModel draft,
    String paymentMethod,
    Map<String, dynamic> responseData,
    String agentNumber,
    String terminalId,
  ) {
    final details =
        responseData['transaction_details'] as Map<String, dynamic>? ?? {};
    final now = DateTime.now();
    final createdAt =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final ref = responseData['transaction_reference'] as String? ?? '';
    AppLogger.logInfo(_tag,
        'fromDraftAndResponse: ref=$ref plate=${draft.vehicle.vehicleLicense}');

    return TransactionModel(
      transactionReference: ref,
      status: (responseData['status'] as String? ?? 'pending').toLowerCase(),
      totalAmount: _parseDouble(details['total']),
      customerName: draft.vehicle.customerName,
      vehicleLicense: draft.vehicle.vehicleLicense,
      amount: draft.vehicle.price.amount,
      serviceFee: draft.vehicle.price.serviceFee,
      paymentMethod: paymentMethod,
      transactionType: draft.vehicle.transactionType,
      originState: draft.originState,
      originLga: draft.originLga,
      destinationState: draft.destinationState,
      destinationLga: draft.destinationLga,
      agentNumber: agentNumber,
      terminalId: terminalId,
      createdAt: createdAt,
    );
  }

  TransactionModel copyWith({String? status}) {
    return TransactionModel(
      transactionReference: transactionReference,
      transactionId: transactionId,
      customerName: customerName,
      vehicleLicense: vehicleLicense,
      amount: amount,
      serviceFee: serviceFee,
      totalAmount: totalAmount,
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
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
