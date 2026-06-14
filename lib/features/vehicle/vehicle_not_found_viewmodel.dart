import 'package:flutter/material.dart';

class VehicleNotFoundViewModel extends ChangeNotifier {
  final String licensePlate;

  VehicleNotFoundViewModel({required this.licensePlate});

  void searchAgain(BuildContext context) {
    Navigator.pop(context);
  }
}
