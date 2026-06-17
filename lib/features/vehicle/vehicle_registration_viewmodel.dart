import 'package:flutter/material.dart';

import '../../core/utils/logger.dart';
import '../../data/models/vehicle_registration_model.dart';
import '../../data/repositories/location_repository.dart';
import '../../data/repositories/vehicle_repository.dart';

class VehicleRegistrationViewModel extends ChangeNotifier {
  static const String _tag = 'VehRegVM';

  final String licensePlate;
  final LocationRepository _locationRepo = LocationRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();

  bool isLoading = false;
  String? errorMessage;

  String? selectedVehicleType;
  String? selectedOwnerState;
  String? selectedOwnerLga;
  String? selectedIssuingState;
  String? selectedIssuingLga;
  String? selectedEnumeratingState;
  String? selectedEnumeratingLga;

  void setVehicleType(String? value) {
    selectedVehicleType = value;
    notifyListeners();
  }

  void setOwnerLga(String? value) {
    selectedOwnerLga = value;
    notifyListeners();
  }

  void setIssuingLga(String? value) {
    selectedIssuingLga = value;
    notifyListeners();
  }

  void setEnumeratingLga(String? value) {
    selectedEnumeratingLga = value;
    notifyListeners();
  }

  List<String> states = [];
  List<String> ownerLgas = [];
  List<String> issuingLgas = [];
  List<String> enumeratingLgas = [];

  final TextEditingController licensePlateController;
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController ownerAddressController = TextEditingController();
  final TextEditingController chassisNumberController = TextEditingController();
  final TextEditingController engineNumberController = TextEditingController();
  final TextEditingController yearOfManufactureController = TextEditingController();

  final Map<String, String> _stateNameToId = {};

  VehicleRegistrationViewModel({required this.licensePlate})
      : licensePlateController = TextEditingController(text: licensePlate.toLowerCase().trim()) {
    AppLogger.logDebug(_tag, 'Init for ${licensePlate.toLowerCase()}');
    loadStates();
  }

  @override
  void dispose() {
    licensePlateController.dispose();
    ownerNameController.dispose();
    ownerPhoneController.dispose();
    ownerAddressController.dispose();
    chassisNumberController.dispose();
    engineNumberController.dispose();
    yearOfManufactureController.dispose();
    super.dispose();
  }

  Future<void> loadStates() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    AppLogger.logInfo(_tag, 'Loading states...');
    final result = await _locationRepo.getStates();
    if (result.success) {
      _stateNameToId.clear();
      for (final s in result.data ?? []) {
        _stateNameToId[s.stateName] = s.stateId;
      }
      states = _stateNameToId.keys.toList();
      AppLogger.logInfo(_tag, 'Loaded ${states.length} states');
    } else {
      AppLogger.logWarning(_tag, 'Failed to load states: ${result.failure?.message}');
      errorMessage = _mapFailureMessage(result.failure!.runtimeType.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void onOwnerStateChanged(String? state) {
    selectedOwnerState = state;
    selectedOwnerLga = null;
    ownerLgas = [];
    notifyListeners();
    if (state != null) {
      AppLogger.logDebug(_tag, 'Owner state: $state');
      loadLgas(state, 'owner');
    }
  }

  void onIssuingStateChanged(String? state) {
    selectedIssuingState = state;
    selectedIssuingLga = null;
    issuingLgas = [];
    notifyListeners();
    if (state != null) {
      AppLogger.logDebug(_tag, 'Issuing state: $state');
      loadLgas(state, 'issuing');
    }
  }

  void onEnumeratingStateChanged(String? state) {
    selectedEnumeratingState = state;
    selectedEnumeratingLga = null;
    enumeratingLgas = [];
    notifyListeners();
    if (state != null) {
      AppLogger.logDebug(_tag, 'Enumerating state: $state');
      loadLgas(state, 'enumerating');
    }
  }

  Future<void> loadLgas(String state, String type) async {
    final stateId = _stateNameToId[state];
    if (stateId == null) {
      AppLogger.logWarning(_tag, 'State ID not found for: $state');
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    AppLogger.logInfo(_tag, 'Loading $type LGAs for $state');
    final result = await _locationRepo.getLgas(stateId);
    if (result.success) {
      final lgas = (result.data ?? []).map((l) => l.lgaName).toList();
      switch (type) {
        case 'owner':
          ownerLgas = lgas;
          break;
        case 'issuing':
          issuingLgas = lgas;
          break;
        case 'enumerating':
          enumeratingLgas = lgas;
          break;
      }
      AppLogger.logInfo(_tag, 'Loaded ${lgas.length} $type LGAs');
    } else {
      AppLogger.logWarning(_tag, 'Failed $type LGAs: ${result.failure?.message}');
      errorMessage = _mapFailureMessage(result.failure!.runtimeType.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  void submit(BuildContext context) {
    final name = ownerNameController.text.trim();
    final phone = ownerPhoneController.text.trim();
    final address = ownerAddressController.text.trim();
    final chassis = chassisNumberController.text.trim();
    final engine = engineNumberController.text.trim();
    final year = yearOfManufactureController.text.trim();

    if (selectedVehicleType == null) {
      errorMessage = 'Please select the vehicle type';
      notifyListeners();
      return;
    }
    if (chassis.isEmpty) {
      errorMessage = 'Please enter the chassis number';
      notifyListeners();
      return;
    }
    if (engine.isEmpty) {
      errorMessage = 'Please enter the engine number';
      notifyListeners();
      return;
    }
    if (year.isEmpty || year.length != 4) {
      errorMessage = 'Please enter a valid 4-digit year of manufacture';
      notifyListeners();
      return;
    }
    if (name.isEmpty) {
      errorMessage = "Please enter the owner's full name";
      notifyListeners();
      return;
    }
    if (phone.isEmpty || phone.length != 11) {
      errorMessage = 'Please enter a valid 11-digit phone number';
      notifyListeners();
      return;
    }
    if (address.isEmpty) {
      errorMessage = "Please enter the owner's address";
      notifyListeners();
      return;
    }
    if (selectedOwnerState == null) {
      errorMessage = "Please select the owner's state";
      notifyListeners();
      return;
    }
    if (selectedOwnerLga == null) {
      errorMessage = "Please select the owner's LGA";
      notifyListeners();
      return;
    }
    if (selectedIssuingState == null) {
      errorMessage = 'Please select the issuing state';
      notifyListeners();
      return;
    }
    if (selectedIssuingLga == null) {
      errorMessage = 'Please select the issuing LGA';
      notifyListeners();
      return;
    }
    if (selectedEnumeratingState == null) {
      errorMessage = 'Please select the enumerating state';
      notifyListeners();
      return;
    }
    if (selectedEnumeratingLga == null) {
      errorMessage = 'Please select the enumerating LGA';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final payload = VehicleRegistrationModel(
      licensePlate: licensePlate.toLowerCase().trim(),
      vehicleType: selectedVehicleType!,
      chassisNumber: chassis,
      engineNumber: engine,
      yearOfManufacture: year,
      ownerName: name,
      ownerPhone: phone,
      ownerAddress: address,
      ownerState: selectedOwnerState!,
      ownerLga: selectedOwnerLga!,
      issuingState: selectedIssuingState!,
      issuingLga: selectedIssuingLga!,
      enumeratingState: selectedEnumeratingState!,
      enumeratingLga: selectedEnumeratingLga!,
    ).toJson();

    AppLogger.logInfo(_tag, 'Submitting registration for ${licensePlate.toLowerCase()}');

    _vehicleRepo.registerVehicle(payload).then((result) {
      isLoading = false;
      notifyListeners();

      if (result.success) {
        AppLogger.logInfo(_tag, 'Vehicle registered successfully');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Vehicle registered successfully'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ).then((_) => Navigator.of(context).pop());
      } else {
        AppLogger.logWarning(_tag, 'Registration failed: ${result.failure?.message}');
        errorMessage = _mapFailureMessage(result.failure!.runtimeType.toString());
        notifyListeners();
      }
    });
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  String _mapFailureMessage(String type) {
    if (type == 'NetworkFailure') {
      return 'No internet connection. Check your network';
    }
    if (type == 'AuthFailure') {
      return 'API authentication error. Contact your administrator';
    }
    return 'Failed to register vehicle. Please try again';
  }
}
