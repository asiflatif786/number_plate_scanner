import '../../../../core/utils/logger.dart';

class TerminalResponseModel {
  final String statusCode;
  final String message;
  final bool success;

  const TerminalResponseModel({
    required this.statusCode,
    required this.message,
    required this.success,
  });

  factory TerminalResponseModel.fromJson(Map<String, dynamic> json) {
    final statusCode = json['status_code'] as String? ?? '99';
    final message = json['message'] as String? ?? '';
    final success = statusCode == '00';

    AppLogger.debug('TerminalResponseModel',
        'Status: $statusCode | Message: $message');

    return TerminalResponseModel(
      statusCode: statusCode,
      message: message,
      success: success,
    );
  }
}
