import 'package:flutter/material.dart';
import '../../app/routes.dart';

class VehicleNotFoundViewModel extends ChangeNotifier {
  final String licensePlate;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? rfidData;

  VehicleNotFoundViewModel({
    required this.licensePlate,
    this.metadata,
    this.rfidData,
  });

  void searchAgain(BuildContext context) {
    Navigator.pop(context);
  }

  void addCustomer(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.addCustomer,
      arguments: licensePlate,
    );
  }
}
