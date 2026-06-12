import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/network_client.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/entities/vehicle_registration_entity.dart';
import '../../domain/entities/vehicle_search_params.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../models/vehicle_registration_model.dart';
import '../models/vehicle_registration_response_model.dart';
import '../models/vehicle_validation_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  static const String _tag = 'VehicleRepo';
  final NetworkClient _networkClient;

  VehicleRepositoryImpl({required NetworkClient networkClient})
      : _networkClient = networkClient;

  @override
  Future<VehicleEntity> validateVehicle(VehicleSearchParams params) async {
    AppLogger.info(_tag,
        'Validating vehicle: ${params.vehicleLicense} type: ${params.transactionType}');

    try {
      final response = await _networkClient.get(
        ApiConstants.validateCustomer,
        queryParams: {
          'service_number': params.serviceNumber,
          'vehicle_license': params.vehicleLicense,
          'transaction_type': params.transactionType,
        },
      );

      final statusCode = response['status_code'] as String? ?? '99';

      if (statusCode == '00') {
        final entity = VehicleValidationModel.fromJson(response);
        AppLogger.success(_tag,
            'Vehicle found: ${entity.vehicleLicense} price: ${entity.price}');
        return entity;
      }

      if (statusCode == '04') {
        AppLogger.warning(_tag,
            'Vehicle not found: ${params.vehicleLicense}');
        throw const NotFoundFailure('Vehicle not found in database');
      }

      final message = response['message'] as String? ?? 'Validation failed';
      AppLogger.error(_tag, 'Validation failed: $message');
      throw ServerFailure(message);
    } catch (e) {
      if (e is Failure) rethrow;
      AppLogger.error(_tag, 'Vehicle validation error', e);
      rethrow;
    }
  }

  @override
  Future<VehicleRegistrationResponseModel> registerVehicle(
      VehicleRegistrationEntity vehicle) async {
    AppLogger.info(_tag,
        'Registering vehicle: ${vehicle.vehicleLicense} type: ${vehicle.vehicleType} owner: ${vehicle.ownerName}');

    try {
      final json = VehicleRegistrationModel.toJson(vehicle);
      final response = await _networkClient.post(
        ApiConstants.registerVehicle,
        body: json,
      );

      final responseModel =
          VehicleRegistrationResponseModel.fromJson(response);

      AppLogger.success(_tag,
          'Vehicle registered: ${vehicle.vehicleLicense}');
      return responseModel;
    } catch (e) {
      if (e is Failure) rethrow;
      AppLogger.error(_tag, 'Failed to register vehicle', e);
      rethrow;
    }
  }

  @override
  Future<List<String>> getVehicleTypes() async {
    const types = [
      'Saloon Car',
      'SUV/Jeep (4 Tyres)',
      'Pick Up Vans and its equivalent (4 Tyres)',
      'Pick Up Heavy Duty 6/8 Tyres',
      'Buses (18 Seater and above)',
      'Mini Bus (14-17 Seater)',
      'Motorcycles',
      'Tricycles (Keke)',
      'Trucks (6 Tyres)',
      'Trucks (10 Tyres and above)',
      'Trailers',
      'Tankers',
    ];

    AppLogger.debug(_tag, 'Vehicle types loaded: ${types.length} types');
    return types;
  }
}
