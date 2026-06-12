class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.success(T data, String message) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: '00',
    );
  }

  factory ApiResponse.error(String message, String statusCode) {
    return ApiResponse(
      success: false,
      message: message,
      data: null,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    final statusCode = json['status_code'] as String? ?? '99';
    final message = json['message'] as String? ?? '';
    final success = statusCode == '00';

    T? data;
    if (json['data'] != null && fromJsonT != null) {
      if (json['data'] is Map<String, dynamic>) {
        data = fromJsonT(json['data'] as Map<String, dynamic>);
      }
    }

    return ApiResponse(
      success: success,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }
}
