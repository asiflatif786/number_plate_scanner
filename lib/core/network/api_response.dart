import '../errors/failure.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Failure? failure;

  const ApiResponse._({
    required this.success,
    required this.message,
    this.data,
    this.failure,
  });

  factory ApiResponse.success(T data, String message) {
    return ApiResponse._(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.failure(Failure failure) {
    return ApiResponse._(
      success: false,
      message: failure.message,
      failure: failure,
    );
  }
}
