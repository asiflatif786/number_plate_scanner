import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/vehicle_registration_response_model.dart';
import '../../domain/entities/vehicle_registration_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';

class VehicleRegistrationViewModel extends ChangeNotifier {
  static const String _tag = 'VehicleRegVM';
  final VehicleRepository _repository;

  VehicleRegistrationViewModel({required VehicleRepository repository})
      : _repository = repository;

  bool isLoading = false;
  bool isLoadingTypes = false;
  String? errorMessage;
  String? successMessage;
  bool isSubmitted = false;
  VehicleRegistrationResponseModel? registrationResult;

  List<String> vehicleTypes = [];
  String? selectedVehicleType;
  String? selectedIssuingState;
  String? selectedEnumeratingState;
  String? selectedPlateType;
  bool hasEnumeratingDetails = false;

  void setVehicleType(String type) {
    selectedVehicleType = type;
    notifyListeners();
  }

  void setIssuingState(String state) {
    selectedIssuingState = state;
    notifyListeners();
  }

  void setEnumeratingState(String? state) {
    selectedEnumeratingState = state;
    notifyListeners();
  }

  void setPlateType(String type) {
    selectedPlateType = type;
    notifyListeners();
  }

  void toggleEnumeratingDetails(bool value) {
    hasEnumeratingDetails = value;
    if (!value) {
      selectedEnumeratingState = null;
    }
    notifyListeners();
    AppLogger.debug(_tag, 'Enumerating details toggle: $value');
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    errorMessage = message;
    isLoading = false;
    notifyListeners();
    AppLogger.error(_tag, message);
  }

  void _setSuccess(String message) {
    successMessage = message;
    isSubmitted = true;
    isLoading = false;
    notifyListeners();
    AppLogger.success(_tag, message);
  }

  Future<void> loadVehicleTypes() async {
    isLoadingTypes = true;
    notifyListeners();

    try {
      final types = await _repository.getVehicleTypes();
      vehicleTypes = types;
      isLoadingTypes = false;
      notifyListeners();
      AppLogger.info(_tag,
          'Vehicle types loaded: ${vehicleTypes.length}');
    } catch (e) {
      isLoadingTypes = false;
      notifyListeners();
      AppLogger.error(_tag, 'Failed to load vehicle types', e);
    }
  }

  Future<void> registerVehicle(VehicleRegistrationEntity entity) async {
    errorMessage = null;
    successMessage = null;
    _setLoading(true);

    AppLogger.info(_tag,
        'Registering vehicle: ${entity.vehicleLicense}');

    try {
      final result = await _repository.registerVehicle(entity);
      registrationResult = result;
      isSubmitted = true;
      _setSuccess('Vehicle registered successfully');
      AppLogger.success(_tag,
          'Vehicle registered: ${entity.vehicleLicense}');
    } on Failure catch (f) {
      _setError(f.message);
    } catch (e) {
      AppLogger.error(_tag, 'Unexpected error during registration', e);
      _setError('Unexpected error occurred');
    }
  }

  void clearState() {
    isLoading = false;
    isLoadingTypes = false;
    errorMessage = null;
    successMessage = null;
    isSubmitted = false;
    registrationResult = null;
    vehicleTypes = [];
    selectedVehicleType = null;
    selectedIssuingState = null;
    selectedEnumeratingState = null;
    selectedPlateType = null;
    hasEnumeratingDetails = false;
    notifyListeners();
  }
}
