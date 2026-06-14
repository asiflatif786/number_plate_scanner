import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/vehicle_model.dart';

class VehicleRepository {
  static const String _tag = 'VehicleRepo';

  Future<ApiResponse<VehicleModel>> validateCustomer({
    required String vehicleLicense,
    required String transactionType,
  }) async {
    final payload = {
      'action': ApiConstants.actionValidateCustomer,
      'vehicle_license': vehicleLicense,
      'transaction_type': transactionType,
    };

    AppLogger.logInfo(_tag, 'Validating: $vehicleLicense ($transactionType)');
    final response = await ApiClient.instance.post(payload as String);

    if (response.success && response.data != null) {
      final vehicle = VehicleModel.fromJson(response.data!);
      return ApiResponse.success(vehicle, response.message);
    }

    return ApiResponse.failure(response.failure!);
  }
}
