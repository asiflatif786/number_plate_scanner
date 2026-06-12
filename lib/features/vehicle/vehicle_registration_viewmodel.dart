import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/models/lga_model.dart';
import '../../data/models/state_model.dart';
import '../../data/models/transaction_draft_model.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/location_repository.dart';

class VehicleRegistrationViewModel extends ChangeNotifier {
  final VehicleModel vehicle;
  final LocationRepository _repository = LocationRepository();

  VehicleRegistrationViewModel({required this.vehicle}) {
    loadStates();
  }

  List<StateModel> states = [];
  bool isLoadingStates = false;

  List<LgaModel> originLgas = [];
  bool isLoadingOriginLgas = false;

  List<LgaModel> destinationLgas = [];
  bool isLoadingDestinationLgas = false;

  StateModel? selectedOriginState;
  LgaModel? selectedOriginLga;
  StateModel? selectedDestinationState;
  LgaModel? selectedDestinationLga;

  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadStates() async {
    isLoadingStates = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.getStates();
    if (result.success) {
      states = result.data ?? [];
    } else {
      final failure = result.failure!;
      errorMessage = _mapFailureMessage(failure.runtimeType.toString());
    }
    isLoadingStates = false;
    notifyListeners();
  }

  void onOriginStateChanged(StateModel? state) {
    selectedOriginState = state;
    selectedOriginLga = null;
    originLgas = [];
    notifyListeners();
    if (state != null) {
      _loadOriginLgas(state.stateId);
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadOriginLgas(String stateId) async {
    isLoadingOriginLgas = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.getLgas(stateId);
    if (result.success) {
      originLgas = result.data ?? [];
    } else {
      errorMessage = _mapFailureMessage(result.failure!.runtimeType.toString());
    }
    isLoadingOriginLgas = false;
    notifyListeners();
  }

  void onOriginLgaChanged(LgaModel? lga) {
    selectedOriginLga = lga;
    notifyListeners();
  }

  void onDestinationStateChanged(StateModel? state) {
    selectedDestinationState = state;
    selectedDestinationLga = null;
    destinationLgas = [];
    notifyListeners();
    if (state != null) {
      _loadDestinationLgas(state.stateId);
    }
  }

  Future<void> _loadDestinationLgas(String stateId) async {
    isLoadingDestinationLgas = true;
    errorMessage = null;
    notifyListeners();

    final result = await _repository.getLgas(stateId);
    if (result.success) {
      destinationLgas = result.data ?? [];
    } else {
      errorMessage = _mapFailureMessage(result.failure!.runtimeType.toString());
    }
    isLoadingDestinationLgas = false;
    notifyListeners();
  }

  void onDestinationLgaChanged(LgaModel? lga) {
    selectedDestinationLga = lga;
    notifyListeners();
  }

  void submit(BuildContext context) {
    if (selectedOriginState == null) {
      errorMessage = 'Please select the origin state';
      notifyListeners();
      return;
    }
    if (selectedOriginLga == null) {
      errorMessage = 'Please select the origin LGA';
      notifyListeners();
      return;
    }
    if (selectedDestinationState == null) {
      errorMessage = 'Please select the destination state';
      notifyListeners();
      return;
    }
    if (selectedDestinationLga == null) {
      errorMessage = 'Please select the destination LGA';
      notifyListeners();
      return;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    final draft = TransactionDraftModel(
      vehicle: vehicle,
      originState: selectedOriginState!.stateName,
      originStateId: selectedOriginState!.stateId,
      originLga: selectedOriginLga!.lgaName,
      originLgaId: selectedOriginLga!.lgaId,
      destinationState: selectedDestinationState!.stateName,
      destinationStateId: selectedDestinationState!.stateId,
      destinationLga: selectedDestinationLga!.lgaName,
      destinationLgaId: selectedDestinationLga!.lgaId,
      payerEmail: 'customer@tms.ng',
    );

    Navigator.pushNamed(context, AppRoutes.transactionCreation, arguments: draft)
        .then((_) {
      isSubmitting = false;
      notifyListeners();
    });
  }

  String _mapFailureMessage(String type) {
    if (type == 'NetworkFailure') {
      return 'No internet connection. Check your network';
    }
    if (type == 'AuthFailure') {
      return 'API authentication error. Contact your administrator';
    }
    return 'Failed to load data. Please try again';
  }
}
