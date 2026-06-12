import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/failure.dart';
import '../utils/logger.dart';
import 'api_response.dart';

class ApiClient {
  static const String _tag = 'ApiClient';

  static ApiClient? _instance;
  final http.Client _httpClient;
  final Connectivity _connectivity;

  ApiClient._internal({
    http.Client? client,
    Connectivity? connectivity,
  })  : _httpClient = client ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  factory ApiClient({
    http.Client? client,
    Connectivity? connectivity,
  }) {
    _instance ??= ApiClient._internal(
      client: client,
      connectivity: connectivity,
    );
    return _instance!;
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    Map<String, dynamic> body,
  ) async {
    final hasInternet = await _checkConnectivity();
    if (!hasInternet) {
      AppLogger.logError(_tag, 'No internet connection');
      return ApiResponse.failure(
        const NetworkFailure('No internet connection. Please check your network.'),
      );
    }

    final requestBody = _buildRequestBody(body);
    final uri = Uri.parse(ApiConstants.baseUrl);

    _logRequest(requestBody);

    try {
      final httpResponse = await _httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConstants.timeout);

      return _handleResponse(httpResponse);
    } on TimeoutException catch (e) {
      AppLogger.logError(_tag, 'Request timed out', e);
      return ApiResponse.failure(
        const TimeoutFailure('Request timed out. Please try again.'),
      );
    } on FormatException catch (e) {
      AppLogger.logError(_tag, 'Invalid response format', e);
      return ApiResponse.failure(
        const ServerFailure('Invalid response from server.'),
      );
    } catch (e) {
      AppLogger.logError(_tag, 'Unexpected error', e);
      return ApiResponse.failure(
        UnknownFailure('Something went wrong: ${e.toString()}'),
      );
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final connected = results.any((r) => r != ConnectivityResult.none);
      AppLogger.logDebug(_tag, 'Connectivity: $connected');
      return connected;
    } catch (e) {
      AppLogger.logError(_tag, 'Connectivity check failed', e);
      return true;
    }
  }

  Map<String, dynamic> _buildRequestBody(Map<String, dynamic> body) {
    return {
      'key': ApiConstants.apiKey,
      ...body,
    };
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(
    http.Response httpResponse,
  ) {
    final body = _parseBody(httpResponse);
    final status = body['status'] as bool? ?? false;
    final message = body['message'] as String? ?? 'Unknown error';
    final rawData = body['data'];

    Map<String, dynamic> data = {};
    if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else if (rawData is List) {
      data = {'data_list': rawData};
    }

    AppLogger.logInfo(_tag, '$status → $message');

    if (httpResponse.statusCode != 200) {
      final failure = _mapHttpError(httpResponse.statusCode, message);
      AppLogger.logError(_tag, 'HTTP ${httpResponse.statusCode}', failure);
      return ApiResponse.failure(failure);
    }

    if (!status) {
      final failure = _mapBusinessError(message);
      AppLogger.logError(_tag, 'Business error: $message', failure);
      return ApiResponse.failure(failure);
    }

    return ApiResponse.success(data, message);
  }

  Failure _mapHttpError(int statusCode, String message) {
    switch (statusCode) {
      case 500:
        return const ServerFailure('Internal server error. Please try again.');
      case 503:
        return const NetworkFailure('Service unavailable. Please try again later.');
      case 422:
        return const ServerFailure('Validation failed. Check your input.');
      default:
        return UnknownFailure(message);
    }
  }

  Failure _mapBusinessError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid') && lower.contains('key')) {
      return const AuthFailure('Invalid API key. Please contact support.');
    }
    if (lower.contains('invalid credentials')) {
      return const AuthFailure('Invalid email or password.');
    }
    if (lower.contains('already registered') || lower.contains('duplicate')) {
      return DuplicateFailure(message);
    }
    if (lower.contains('not found')) {
      return NotFoundFailure(message);
    }
    if (lower.contains('permission') || lower.contains('unauthorized')) {
      return const AuthFailure('You do not have permission for this action.');
    }

    return ServerFailure(message);
  }

  Map<String, dynamic> _parseBody(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'status': false, 'message': 'Invalid server response'};
    }
  }

  void _logRequest(Map<String, dynamic> body) {
    final masked = Map<String, dynamic>.from(body);
    if (masked.containsKey('key')) {
      final key = masked['key'] as String;
      masked['key'] = key.length > 4
          ? '${key.substring(0, 4)}****'
          : '****';
    }

    AppLogger.logInfo(_tag, 'POST ${ApiConstants.baseUrl}');
    AppLogger.logDebug(_tag, 'Body: ${jsonEncode(masked)}');
  }

  void dispose() {
    _httpClient.close();
    _instance = null;
  }
}
