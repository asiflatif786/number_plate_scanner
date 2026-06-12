import 'dart:async';
import 'dart:io';
import '../errors/failure.dart';
import '../utils/logger.dart';

class ExceptionHandler {
  static Failure handle(Object error, String tag) {
    if (error is Failure) {
      AppLogger.error(tag, 'Failure rethrown: ${error.message}', error);
      return error;
    }

    if (error is SocketException) {
      AppLogger.error(tag, 'SocketException caught', error);
      return const NetworkFailure('No internet connection');
    }

    if (error is TimeoutException) {
      AppLogger.error(tag, 'TimeoutException caught', error);
      return const NetworkFailure('Request timed out');
    }

    if (error is FormatException) {
      AppLogger.error(tag, 'FormatException caught', error);
      return const ServerFailure('Invalid response format');
    }

    AppLogger.error(tag, 'Unexpected error caught', error);
    return UnknownFailure('Something went wrong: ${error.toString()}');
  }
}
