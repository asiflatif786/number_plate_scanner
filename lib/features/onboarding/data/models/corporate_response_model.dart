import '../../../../core/utils/logger.dart';

class CorporateResponseModel {
  final String statusCode;
  final String message;
  final String? companyNumber;

  const CorporateResponseModel({
    required this.statusCode,
    required this.message,
    this.companyNumber,
  });

  factory CorporateResponseModel.fromJson(Map<String, dynamic> json) {
    final statusCode = json['status_code'] as String? ?? '99';
    final message = json['message'] as String? ?? '';
    final companyNumber = json['data'] is Map
        ? (json['data'] as Map)['company_number'] as String?
        : null;

    AppLogger.debug('CorporateResponseModel',
        'Parsed: status_code=$statusCode, message=$message, company_number=$companyNumber');

    return CorporateResponseModel(
      statusCode: statusCode,
      message: message,
      companyNumber: companyNumber,
    );
  }
}
