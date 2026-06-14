import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/vehicle_repository.dart';

class VehicleSearchViewModel extends ChangeNotifier {
  static const String _tag = 'VehSearchVM';

  final VehicleRepository _repository;

  VehicleSearchViewModel({VehicleRepository? repository})
      : _repository = repository ?? VehicleRepository();

  bool isLoading = false;
  String? errorMessage;
  String selectedTransactionType = ApiConstants.transactionTypeSingle;

  final licensePlateController = TextEditingController();

  bool get isComplete => selectedTransactionType == ApiConstants.transactionTypeComplete;

  void onTransactionTypeChanged(String type) {
    selectedTransactionType = type;
    notifyListeners();
  }

  void onScanResult(String scannedPlate) {
    licensePlateController.text = scannedPlate.toUpperCase().trim();
    notifyListeners();
  }

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> search(BuildContext context) async {
    final plate = licensePlateController.text.toUpperCase().trim();

    if (plate.isEmpty) {
      errorMessage = 'Please enter a license plate number';
      notifyListeners();
      return;
    }
    if (plate.length < 5) {
      errorMessage = 'License plate must be at least 5 characters';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.validateVehicle(
        vehicleLicense: plate,
        transactionType: selectedTransactionType,
      );

      if (result.success && result.data != null) {
        AppLogger.logInfo(_tag, 'Vehicle found: $plate');

        if (!context.mounted) return;
        Navigator.pushNamed(context, AppRoutes.vehicleFound, arguments: result.data);
      } else if (result.failure != null) {
        if (result.failure is NotFoundFailure) {
          AppLogger.logInfo(_tag, 'Vehicle not found: $plate');

          if (!context.mounted) return;
          Navigator.pushNamed(
              context, AppRoutes.vehicleNotFound, arguments: plate);
        } else if (result.failure is NetworkFailure) {
          errorMessage = 'No internet connection. Check your network.';
          AppLogger.logWarning(
              _tag, 'Network error: ${result.failure!.message}');
        } else {
          errorMessage = result.failure!.message;
          AppLogger.logWarning(_tag, 'Search failed: ${result.failure!.message}');
        }
      } else {
        errorMessage = 'Something went wrong. Please try again.';
      }
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      AppLogger.logError(_tag, 'search error', e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> navigateToScanner(BuildContext context) async {
    final result = await Navigator.pushNamed(context, AppRoutes.scanner);
    if (result != null && result is String) {
      onScanResult(result);
    }
  }

  @override
  void dispose() {
    licensePlateController.dispose();
    super.dispose();
  }
}
