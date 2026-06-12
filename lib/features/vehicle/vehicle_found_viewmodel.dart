import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/utils/logger.dart';
import '../../data/models/vehicle_model.dart';

class VehicleFoundViewModel extends ChangeNotifier {
  static const String _tag = 'VehicleFoundVM';

  final VehicleModel vehicle;

  VehicleFoundViewModel({required this.vehicle});

  bool isProceeding = false;

  void proceedToTransaction(BuildContext context) {
    isProceeding = true;
    notifyListeners();

    AppLogger.logInfo(_tag, 'Proceeding: ${vehicle.vehicleLicense} ($vehicleType)');

    Navigator.pushNamed(
      context,
      AppRoutes.vehicleRegistration,
      arguments: vehicle,
    ).then((_) {
      AppLogger.logDebug(_tag, 'Returned from registration');
      isProceeding = false;
      notifyListeners();
    });
  }

  String get vehicleType => vehicle.vehicleType;

  void goBack(BuildContext context) {
    AppLogger.logDebug(_tag, 'User went back');
    Navigator.pop(context);
  }
}
