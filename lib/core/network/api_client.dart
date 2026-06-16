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

  // Default to the hardcoded key if env var is not set
  String _apiKey = ApiConstants.defaultApiKey.isNotEmpty
      ? ApiConstants.defaultApiKey
      : 'tms_local_1776144090';

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

  void setApiKey(String key) {
    _apiKey = key;
    AppLogger.logDebug(_tag, 'API key updated');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─── TMS POST (single-endpoint base URL with key+action in body) ───────────

  /// Use this for ALL TMS API calls. Posts directly to base URL with key, action,
  /// and any additional [fields] automatically injected into the JSON body.
  Future<ApiResponse<Map<String, dynamic>>> tmsPost(
    String action, {
    Map<String, dynamic>? fields,
  }) async {
    final body = <String, dynamic>{
      'key': _apiKey,
      'action': action,
      ...?fields,
    };
    return post(ApiConstants.tmsEndpoint, body: body);
  }

  // ─── GET ─────────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final hasInternet = await _checkConnectivity();
    if (!hasInternet) {
      return ApiResponse.failure(
        const NetworkFailure(
            'No internet connection. Please check your network.'),
      );
    }

    final uri = Uri.parse('${ApiConstants.laravelBaseUrl}$endpoint')
        .replace(queryParameters: queryParams);

    _logRequest('GET', endpoint, queryParams);

    try {
      final httpResponse = await _httpClient
          .get(uri, headers: _headers)
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

  // ─── POST ────────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final hasInternet = await _checkConnectivity();
    if (!hasInternet) {
      return ApiResponse.failure(
        const NetworkFailure(
            'No internet connection. Please check your network.'),
      );
    }

    final uri = Uri.parse('${ApiConstants.laravelBaseUrl}$endpoint');

    _logRequest('POST', endpoint, body);

    try {
      final httpResponse = await _httpClient
          .post(uri,
              headers: _headers, body: body != null ? jsonEncode(body) : null)
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

  // ─── PUT ─────────────────────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final hasInternet = await _checkConnectivity();
    if (!hasInternet) {
      return ApiResponse.failure(
        const NetworkFailure(
            'No internet connection. Please check your network.'),
      );
    }

    final uri = Uri.parse('${ApiConstants.laravelBaseUrl}$endpoint');

    _logRequest('PUT', endpoint, body);

    try {
      final httpResponse = await _httpClient
          .put(uri,
              headers: _headers, body: body != null ? jsonEncode(body) : null)
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

  // ─── Connectivity ────────────────────────────────────────────────────────

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

  // ─── Response handling ───────────────────────────────────────────────────

  ApiResponse<Map<String, dynamic>> _handleResponse(
    http.Response httpResponse,
  ) {
    final body = _parseBody(httpResponse);
    final message = body['message'] as String? ?? 'Unknown error';
    final rawData = body['data'];

    // Support both old (status: true/false) and new (status_code: "00") formats
    final oldStatus = body['status'] as bool?;
    final statusCode = body['status_code'] as String?;

    final isSuccess = oldStatus == true || statusCode == '00';

    Map<String, dynamic> data = {};
    if (rawData is Map<String, dynamic>) {
      data = rawData;
    } else if (rawData is List) {
      data = {'data_list': rawData};
    }

    AppLogger.logInfo(_tag, '${httpResponse.statusCode} → $message');

    if (httpResponse.statusCode != 200) {
      final failure = _mapHttpError(httpResponse.statusCode, message);
      AppLogger.logError(_tag, 'HTTP ${httpResponse.statusCode}', failure);
      return ApiResponse.failure(failure);
    }

    if (!isSuccess) {
      final failure = _mapBusinessError(message, statusCode);
      AppLogger.logError(_tag, 'Business error: $message', failure);
      return ApiResponse.failure(failure);
    }

    return ApiResponse.success(data, message);
  }

  Failure _mapHttpError(int statusCode, String message) {
    switch (statusCode) {
      case 404:
        return NotFoundFailure(message);
      case 500:
        return const ServerFailure('Internal server error. Please try again.');
      case 503:
        return const NetworkFailure(
            'Service unavailable. Please try again later.');
      case 422:
        return const ServerFailure('Validation failed. Check your input.');
      case 401:
        return const AuthFailure('Invalid API key. Please contact support.');
      default:
        return UnknownFailure(message);
    }
  }

  Failure _mapBusinessError(String message, String? statusCode) {
    // Map by status_code first (new TMS format)
    switch (statusCode) {
      case '02':
      case '03':
        return const AuthFailure('Authentication error. Please re-login.');
      case '04':
        return NotFoundFailure(message);
      case '05':
        return DuplicateFailure(message);
    }

    // Fallback to message-based mapping (old format)
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

  void _logRequest(String method, String endpoint, dynamic body) {
    final url = '${ApiConstants.laravelBaseUrl}$endpoint';
    AppLogger.logInfo(_tag, '$method $url');
    if (body != null) {
      AppLogger.logDebug(_tag, 'Body: ${jsonEncode(body)}');
    }
  }

  void dispose() {
    _httpClient.close();
    _instance = null;
  }
}
