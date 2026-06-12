import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/failure.dart';
import '../utils/logger.dart';
import 'connectivity_helper.dart';
import 'request_logger.dart';
import 'exception_handler.dart';

class NetworkClient {
  static const String _tag = 'NetworkClient';

  static NetworkClient? _instance;
  final http.Client _client;

  NetworkClient._internal({http.Client? client})
      : _client = client ?? http.Client();

  factory NetworkClient({http.Client? client}) {
    _instance ??= NetworkClient._internal(client: client);
    return _instance!;
  }

  static NetworkClient get instance {
    _instance ??= NetworkClient._internal();
    return _instance!;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final isConnected = await ConnectivityHelper.isConnected();
    if (!isConnected) {
      AppLogger.error(_tag, 'No internet connection');
      throw const NetworkFailure(
        'No internet connection. Please check your network.',
      );
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(
      queryParameters: queryParams,
    );
    final headers = _buildHeaders();
    final stopwatch = Stopwatch()..start();

    RequestLogger.logRequest(
      method: 'GET',
      url: uri.toString(),
      headers: headers,
    );

    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      stopwatch.stop();
      final body = _parseBody(response);
      RequestLogger.logResponse(
        url: uri.toString(),
        statusCode: response.statusCode,
        body: body,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();
      throw ExceptionHandler.handle(e, _tag);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final isConnected = await ConnectivityHelper.isConnected();
    if (!isConnected) {
      AppLogger.error(_tag, 'No internet connection');
      throw const NetworkFailure(
        'No internet connection. Please check your network.',
      );
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = _buildHeaders();
    final stopwatch = Stopwatch()..start();

    RequestLogger.logRequest(
      method: 'POST',
      url: uri.toString(),
      headers: headers,
      body: body,
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      stopwatch.stop();
      final responseBody = _parseBody(response);
      RequestLogger.logResponse(
        url: uri.toString(),
        statusCode: response.statusCode,
        body: responseBody,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();
      throw ExceptionHandler.handle(e, _tag);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    final isConnected = await ConnectivityHelper.isConnected();
    if (!isConnected) {
      AppLogger.error(_tag, 'No internet connection');
      throw const NetworkFailure(
        'No internet connection. Please check your network.',
      );
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = _buildHeaders();
    final stopwatch = Stopwatch()..start();

    RequestLogger.logRequest(
      method: 'PUT',
      url: uri.toString(),
      headers: headers,
      body: body,
    );

    try {
      final response = await _client
          .put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      stopwatch.stop();
      final responseBody = _parseBody(response);
      RequestLogger.logResponse(
        url: uri.toString(),
        statusCode: response.statusCode,
        body: responseBody,
        durationMs: stopwatch.elapsedMilliseconds,
      );

      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();
      throw ExceptionHandler.handle(e, _tag);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = _parseBody(response) as Map<String, dynamic>? ?? {};
    final statusCode = body['status_code'] as String? ?? '99';
    final message = body['message'] as String? ?? 'Unknown error';

    AppLogger.debug(_tag, 'Response status_code: $statusCode, message: $message');

    switch (statusCode) {
      case '00':
        return body;
      case '01':
        throw ServerFailure(message);
      case '02':
        throw const AuthFailure('Invalid or missing API key');
      case '03':
        throw const AuthFailure('API key does not have permission');
      case '04':
        throw NotFoundFailure(message);
      case '05':
        throw DuplicateFailure(message);
      default:
        break;
    }

    if (response.statusCode == 500) {
      throw const ServerFailure('Internal server error');
    }
    if (response.statusCode == 503) {
      throw const NetworkFailure('Service unavailable');
    }

    throw UnknownFailure('Unexpected error: $statusCode');
  }

  Map<String, String> _buildHeaders() {
    return {
      'api-key': ApiConstants.apiKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  dynamic _parseBody(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  void dispose() {
    _client.close();
    _instance = null;
  }
}
