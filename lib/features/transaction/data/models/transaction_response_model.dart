import '../../../../core/utils/logger.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionResponseModel {
  final String statusCode;
  final String message;
  final TransactionEntity? transaction;

  const TransactionResponseModel({
    required this.statusCode,
    required this.message,
    this.transaction,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    final statusCode = json['status_code'] as String? ?? '99';
    final message = json['message'] as String? ?? '';
    final data = json['data'] as Map<String, dynamic>?;

    TransactionEntity? transaction;
    if (data != null) {
      transaction = _parseTransaction(data, statusCode);
    }

    AppLogger.debug('TransactionResponseModel',
        'Parsed: status_code=$statusCode, message=$message, hasTransaction=${transaction != null}');

    return TransactionResponseModel(
      statusCode: statusCode,
      message: message,
      transaction: transaction,
    );
  }

  static TransactionEntity _parseTransaction(
      Map<String, dynamic> data, String statusCode) {
    return TransactionEntity(
      transactionRef: data['transaction_ref'] as String? ?? '',
      vehicleLicense: data['vehicle_license'] as String? ?? '',
      vehicleType: data['vehicle_type'] as String? ?? '',
      price: data['price'] as String? ?? '0',
      priceName: data['price_name'] as String? ?? '',
      priceType: data['price_type'] as String? ?? '',
      issuingState: data['issuing_state'] as String?,
      enumeratingState: data['enumerating_state'] as String?,
      enumeratingLga: data['enumerating_lga'] as String?,
      payerFirstName: data['payer_first_name'] as String? ?? '',
      payerLastName: data['payer_last_name'] as String? ?? '',
      payerPhone: data['payer_phone'] as String? ?? '',
      payerEmail: data['payer_email'] as String? ?? '',
      transactionType: data['transaction_type'] as String? ?? '',
      paymentMethod: data['payment_method'] as String? ?? '',
      paymentRef: data['payment_ref'] as String?,
      baseFee: _parseDouble(data['base_fee']),
      adminFee: _parseDouble(data['admin_fee']),
      transactionFee: _parseDouble(data['transaction_fee']),
      vat: _parseDouble(data['vat']),
      totalAmount: _parseDouble(data['amount'] ?? data['total_amount']),
      status: statusCode == '00' ? 'completed' : statusCode,
      serviceNumber: data['service_number'] as String? ?? '',
      channelNumber: data['channel_number'] as String? ?? '',
      agentNumber: data['agent_number'] as String? ?? '',
      terminalId: data['terminal_id'] as String? ?? '',
      createdAt: data['created_at'] as String?,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
