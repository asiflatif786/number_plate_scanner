import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/entities/vehicle_search_params.dart';
import '../../domain/repositories/vehicle_repository.dart';

class VehicleSearchViewModel extends ChangeNotifier {
  static const String _tag = 'VehicleSearchVM';
  final VehicleRepository _repository;

  bool isLoading = false;
  bool isSearched = false;
  String? errorMessage;
  VehicleEntity? foundVehicle;
  String? searchedLicense;
  String selectedTransactionType = 'single';
  bool vehicleNotFound = false;

  VehicleSearchViewModel({required VehicleRepository repository})
      : _repository = repository;

  void setTransactionType(String type) {
    selectedTransactionType = type;
    AppLogger.debug(_tag, 'Transaction type set: $type');
    notifyListeners();
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

  Future<void> searchVehicle(String licensePlate) async {
    final cleaned = licensePlate.trim().toUpperCase();
    searchedLicense = cleaned;
    errorMessage = null;
    foundVehicle = null;
    vehicleNotFound = false;
    isSearched = false;
    _setLoading(true);

    AppLogger.info(_tag, 'Searching vehicle: $cleaned');

    try {
      final params = VehicleSearchParams.defaults(
        vehicleLicense: cleaned,
        transactionType: selectedTransactionType,
      );

      final result = await _repository.validateVehicle(params);
      foundVehicle = result;
      vehicleNotFound = false;
      isSearched = true;
      isLoading = false;
      notifyListeners();
      AppLogger.success(_tag, 'Vehicle found: ${result.vehicleLicense}');
    } on NotFoundFailure {
      vehicleNotFound = true;
      foundVehicle = null;
      isSearched = true;
      isLoading = false;
      notifyListeners();
      AppLogger.warning(_tag, 'Vehicle not found: $cleaned');
    } on Failure catch (f) {
      _setError(f.message);
    } catch (e) {
      AppLogger.error(_tag, 'Unexpected error during search', e);
      _setError('Unexpected error occurred');
    }
  }

  void clearSearch() {
    isLoading = false;
    isSearched = false;
    errorMessage = null;
    foundVehicle = null;
    searchedLicense = null;
    vehicleNotFound = false;
    notifyListeners();
    AppLogger.debug(_tag, 'Search cleared');
  }
}
