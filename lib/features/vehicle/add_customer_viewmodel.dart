import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/vehicle_repository.dart';

class AddCustomerViewModel extends ChangeNotifier {
  static const String _tag = 'AddCustVM';
  final VehicleRepository _repository = VehicleRepository();

  final String initialLicensePlate;
  final String? paymentType;
  final TextEditingController licensePlateController;
  
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  List<String> vehicleTypes = [];
  List<String> issuingStates = [];

  String? selectedVehicleType;
  String? selectedIssuingState;

  AddCustomerViewModel({required this.initialLicensePlate, this.paymentType})
      : licensePlateController = TextEditingController(text: initialLicensePlate.toUpperCase()) {
    _fetchEnums();
  }

  Future<void> _fetchEnums() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getAddCustomerEnums();
      if (response.success && response.data != null) {
        final outerData = response.data!['data'] as Map<String, dynamic>?;
        if (outerData != null) {
          if (outerData.containsKey('vehicle_category')) {
            final categoryMap = outerData['vehicle_category'] as Map<String, dynamic>;
            vehicleTypes = categoryMap.values.map((e) => e.toString()).toList();
          }

          if (outerData.containsKey('issuing_state')) {
            final statesList = outerData['issuing_state'] as List?;
            issuingStates = statesList?.map((e) => e['name'].toString()).toList() ?? [];
          }
        }
        
        AppLogger.logInfo(_tag, 'Enums parsed: ${vehicleTypes.length} types, ${issuingStates.length} states');
        
        if (vehicleTypes.isEmpty && issuingStates.isEmpty) {
          errorMessage = 'Form data is empty. Please contact support.';
        }
      } else {
        errorMessage = response.failure?.message ?? 'Failed to load form data';
      }
    } catch (e) {
      AppLogger.logError(_tag, 'fetchEnums error', e);
      errorMessage = 'An error occurred while loading data';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setVehicleType(String? value) {
    selectedVehicleType = value;
    notifyListeners();
  }

  void setIssuingState(String? value) {
    selectedIssuingState = value;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    final plate = licensePlateController.text.trim();

    if (plate.isEmpty || selectedVehicleType == null || selectedIssuingState == null) {
      errorMessage = 'Please fill all fields';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createCustomer(
        vehicleLicense: plate,
        vehicleType: selectedVehicleType!,
        issuingState: selectedIssuingState!,
      );
      
      if (result.success && result.data != null) {
        successMessage = 'Customer created successfully!';
        notifyListeners();
        
        AppLogger.logInfo(_tag, 'Success: customer created. Proceeding to found screen...');
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (context.mounted) {
          // Instead of going back to dashboard, go to Vehicle Found screen to continue the flow
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.vehicleFound,
            arguments: {
              'vehicle': result.data!,
              'paymentType': paymentType,
            },
          );
        }
      } else {
        errorMessage = result.failure?.message ?? 'Failed to add customer';
      }
    } catch (e) {
      errorMessage = 'Registration error: $e';
      AppLogger.logError(_tag, 'Registration error', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    licensePlateController.dispose();
    super.dispose();
  }
}
