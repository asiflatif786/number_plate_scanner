import '../../domain/entities/transaction_entity.dart';
import '../../../../core/utils/logger.dart';

class TransactionRequestModel {
  static const String _tag = 'TransactionRequestModel';

  static Map<String, dynamic> toCreateJson(TransactionEntity entity) {
    AppLogger.debug(_tag, 'Building create transaction payload');

    final transactionDate = entity.createdAt ?? '';
    final amountStr = entity.totalAmount.toStringAsFixed(2);
    final feeStr = (entity.baseFee + entity.adminFee + entity.transactionFee + entity.vat).toStringAsFixed(2);

    return {
      'transaction_reference': entity.transactionRef,
      'payer_name': '${entity.payerFirstName} ${entity.payerLastName}'.trim(),
      'payer_phone': entity.payerPhone,
      'payer_email': entity.payerEmail,
      'amount': amountStr,
      'fee': feeStr,
      'transaction_date': transactionDate,
      'channel_number': entity.channelNumber,
      'payment_method': entity.paymentMethod,
      'terminal_id': entity.terminalId,
      'service_number': entity.serviceNumber,
      'metadata': {
        'terminal_id': entity.terminalId,
        'contact': entity.payerPhone,
        'vehicle_type': entity.vehicleType,
        'transaction_type': entity.transactionType,
        'transaction_date': transactionDate,
        'amount': amountStr,
        'vehicle_license': entity.vehicleLicense,
        'transaction_reference': entity.transactionRef,
        'origin_state': entity.issuingState?.toUpperCase() ?? '',
        'origin_lga': entity.enumeratingLga?.toUpperCase() ?? '',
        'destination_state': entity.enumeratingState?.toUpperCase(),
        'destination_lga': entity.enumeratingLga?.toUpperCase(),
        'payload': null,
      },
    };
  }
}
