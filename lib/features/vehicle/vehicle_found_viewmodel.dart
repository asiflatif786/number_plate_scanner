import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../data/models/vehicle_model.dart';

class VehicleFoundViewModel extends ChangeNotifier {
  static const String _tag = 'VehicleFoundVM';

  final VehicleModel vehicle;
  bool isProceeding = false;
  String? errorMessage;

  VehicleFoundViewModel({required this.vehicle});

  double get baseAmount => vehicle.price.amount;
  double get adminFee => baseAmount * AppConstants.adminFeePercent;
  double get flatFee => AppConstants.flatTransactionFee;
  double get vatAmount => baseAmount * AppConstants.vatPercent;
  double get totalFee => adminFee + flatFee + vatAmount;
  double get totalPayable => baseAmount + totalFee;

  String get formattedBaseAmount =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(baseAmount);
  String get formattedAdminFee =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(adminFee);
  String get formattedFlatFee =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(flatFee);
  String get formattedVatAmount =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(vatAmount);
  String get formattedTotalFee =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(totalFee);
  String get formattedTotalPayable =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(totalPayable);

  void proceedToPayment(BuildContext context) {
    isProceeding = true;
    errorMessage = null;
    notifyListeners();

    AppLogger.logInfo(_tag, 'Proceeding: ${vehicle.vehicleLicense}');

    Navigator.pushNamed(
      context,
      AppRoutes.transactionCreation,
      arguments: vehicle,
    ).then((_) {
      AppLogger.logDebug(_tag, 'Returned from transaction creation');
      isProceeding = false;
      notifyListeners();
    }).catchError((error) {
      AppLogger.logError(_tag, 'Navigation error', error);
      errorMessage = error.toString();
      isProceeding = false;
      notifyListeners();
    });
  }
}
