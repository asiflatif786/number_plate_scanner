import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/failure.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/logger.dart';
import '../models/vehicle_model.dart';

class VehicleRepository {
  static const String _tag = 'VehicleRepo';

  Future<ApiResponse<VehicleModel>> validateVehicle({
    required String vehicleLicense,
    required String transactionType,
  }) async {
    final normalizedPlate = vehicleLicense.toLowerCase().trim();
    AppLogger.logInfo(_tag, 'Validating: $normalizedPlate');

    // POST to /api_data with action: 'validate-customer'
    final response = await ApiClient.instance.tmsPost(
      ApiConstants.actionValidateCustomer,
      fields: {
        'vehicle_license': normalizedPlate,
        'transaction_type': transactionType,
      },
    );

    if (response.success && response.data != null) {
      final vehicle = VehicleModel.fromJson(response.data!);
      AppLogger.logInfo(_tag, 'Found: ${vehicle.vehicleLicense}');
      return ApiResponse.success(vehicle, response.message);
    }

    if (response.failure is NotFoundFailure) {
      AppLogger.logInfo(_tag, 'Vehicle not found in TMS: $normalizedPlate');
    } else {
      AppLogger.logWarning(
          _tag, 'Validation failed: ${response.failure?.message}');
    }

    return ApiResponse.failure(response.failure!);
  }

  /// Fetches metadata from the external enum service
  Future<ApiResponse<Map<String, dynamic>>> getServiceMetadata(
      String serviceNumber) async {
    try {
      final url = Uri.parse(ApiConstants.getServiceEnums)
          .replace(queryParameters: {'service_number': serviceNumber});

      AppLogger.logInfo(_tag, 'Fetching metadata from: $url');
      final response = await http.get(url).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == true || body['status_code'] == '00') {
          final data = body['data'] as Map<String, dynamic>? ?? {};
          return ApiResponse.success(data, 'Metadata fetched successfully');
        }
      }
      return ApiResponse.failure(const ServerFailure('Failed to fetch metadata'));
    } catch (e) {
      AppLogger.logError(_tag, 'Error fetching metadata', e);
      return ApiResponse.failure(UnknownFailure(e.toString()));
    }
  }

  /// Fetches enums for Add Customer from specific endpoint with API key
  Future<ApiResponse<Map<String, dynamic>>> getAddCustomerEnums() async {
    try {
      final url = Uri.parse('https://tmsdev.cyber1apps.com/api/enum/get-service-enums?service_number=S13401182324');
      
      AppLogger.logInfo(_tag, 'Fetching add customer enums from: $url');
      final response = await http.get(
        url,
        headers: {
          'api-key': 'GJU3DCRTYDPTBL18',
          'Accept': 'application/json',
        },
      ).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == true || body['status_code'] == '00') {
          final data = body['data'] as Map<String, dynamic>? ?? {};
          return ApiResponse.success(data, 'Enums fetched successfully');
        }
      }
      return ApiResponse.failure(const ServerFailure('Failed to fetch enums'));
    } catch (e) {
      AppLogger.logError(_tag, 'Error fetching add customer enums', e);
      return ApiResponse.failure(UnknownFailure(e.toString()));
    }
  }

  /// Fetches RFID status and vehicle details from external JRB API
  Future<ApiResponse<Map<String, dynamic>>> getVehicleRfidStatus(
      String plateNumber) async {
    try {
      final url = Uri.parse(ApiConstants.getVehicleRfidStatus)
          .replace(queryParameters: {'params': plateNumber.toUpperCase()});

      AppLogger.logInfo(_tag, 'Fetching RFID status from: $url');
      final response = await http.get(url).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status_code'] == '00') {
          final data = body['data'] as Map<String, dynamic>? ?? {};
          return ApiResponse.success(data, body['message'] ?? 'Vehicle found');
        }
        return ApiResponse.failure(ServerFailure(body['message'] ?? 'Vehicle not found in external registry'));
      }
      return ApiResponse.failure(const ServerFailure('Failed to fetch vehicle RFID status'));
    } catch (e) {
      AppLogger.logError(_tag, 'Error fetching RFID status', e);
      return ApiResponse.failure(UnknownFailure(e.toString()));
    }
  }

  /// Registers a vehicle in TMS with the corrected flat format
  Future<ApiResponse<VehicleModel>> createCustomer({
    required String vehicleLicense,
    required String vehicleType,
    required String issuingState,
  }) async {
    AppLogger.logInfo(_tag, 'Creating customer: $vehicleLicense');

    // Flattened the payload because the server validation error confirmed it expects 
    // fields at the top level, not inside a 'metadata' object.
    final response = await ApiClient.instance.post(
      ApiConstants.tmsEndpoint,
      body: {
        'key': 'tms_local_1776144090',
        'action': 'create-customer',
        'vehicle_license': vehicleLicense,
        'vehicle_type': vehicleType,
        'issuing_state': issuingState,
      },
    );

    if (response.success && response.data != null) {
      final vehicle = VehicleModel.fromJson(response.data!);
      AppLogger.logInfo(_tag, 'Customer created successfully: ${vehicle.vehicleLicense}');
      return ApiResponse.success(vehicle, response.message);
    }

    AppLogger.logWarning(
        _tag, 'Customer creation failed: ${response.failure?.message}');
    return ApiResponse.failure(response.failure ?? const ServerFailure('Failed to create customer'));
  }

  Future<ApiResponse<bool>> registerVehicle(
    Map<String, dynamic> formData,
  ) async {
    // Ensure license plate is lowercase if present in form data
    if (formData.containsKey('license_plate')) {
      formData['license_plate'] =
          formData['license_plate'].toString().toLowerCase().trim();
    }

    AppLogger.logInfo(_tag, 'Registering: ${formData['license_plate']}');

    final response = await ApiClient.instance.tmsPost(
      'register-vehicle',
      fields: formData,
    );

    if (response.success) {
      AppLogger.logInfo(_tag, 'Vehicle registered successfully');
      return ApiResponse.success(true, response.message);
    }

    AppLogger.logWarning(
        _tag, 'Registration failed: ${response.failure?.message}');
    return ApiResponse.failure(response.failure!);
  }
}
