import '../entities/vehicle_entity.dart';
import '../entities/vehicle_registration_entity.dart';
import '../entities/vehicle_search_params.dart';
import '../../data/models/vehicle_registration_response_model.dart';

abstract class VehicleRepository {
  Future<VehicleEntity> validateVehicle(VehicleSearchParams params);

  Future<VehicleRegistrationResponseModel> registerVehicle(
    VehicleRegistrationEntity vehicle,
  );

  Future<List<String>> getVehicleTypes();
}
