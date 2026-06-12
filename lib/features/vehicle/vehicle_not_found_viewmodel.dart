import 'package:flutter/material.dart';

class VehicleNotFoundViewModel extends ChangeNotifier {
  final String licensePlate;

  VehicleNotFoundViewModel({required this.licensePlate});

  void retrySearch(BuildContext context) {
    Navigator.pop(context);
  }

  void goToDashboard(BuildContext context) {
    Navigator.popUntil(
      context,
      ModalRoute.withName('/agent-dashboard'),
    );
  }
}
