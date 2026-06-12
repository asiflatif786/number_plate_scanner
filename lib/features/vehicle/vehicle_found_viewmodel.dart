import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/models/vehicle_model.dart';

class VehicleFoundViewModel extends ChangeNotifier {
  final VehicleModel vehicle;

  VehicleFoundViewModel({required this.vehicle});

  bool isProceeding = false;

  void proceedToTransaction(BuildContext context) {
    isProceeding = true;
    notifyListeners();

    Navigator.pushNamed(
      context,
      AppRoutes.vehicleRegistration,
      arguments: vehicle,
    ).then((_) {
      isProceeding = false;
      notifyListeners();
    });
  }

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
