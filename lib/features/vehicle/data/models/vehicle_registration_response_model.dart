import '../../../../core/utils/logger.dart';

class VehicleRegistrationResponseModel {
  final String statusCode;
  final String message;
  final String? registrationId;
  final Map<String, dynamic>? data;

  const VehicleRegistrationResponseModel({
    required this.statusCode,
    required this.message,
    this.registrationId,
    this.data,
  });

  bool get success => statusCode == '00';

  factory VehicleRegistrationResponseModel.fromJson(
      Map<String, dynamic> json) {
    final statusCode = json['status_code'] as String? ?? '99';
    final message = json['message'] as String? ?? '';
    final responseData = json['data'] as Map<String, dynamic>?;
    final registrationId =
        responseData?['id'] as String?;

    AppLogger.debug('VehicleRegistrationResponseModel',
        'Registration status: $statusCode | $message');

    return VehicleRegistrationResponseModel(
      statusCode: statusCode,
      message: message,
      registrationId: registrationId,
      data: responseData,
    );
  }
}
