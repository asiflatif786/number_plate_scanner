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

  Future<ApiResponse<bool>> registerVehicle(
    Map<String, dynamic> formData,
  ) async {
    // Ensure license plate is lowercase if present in form data
    if (formData.containsKey('license_plate')) {
      formData['license_plate'] = formData['license_plate'].toString().toLowerCase().trim();
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
