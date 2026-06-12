import 'vehicle_model.dart';

class TransactionDraftModel {
  final VehicleModel vehicle;
  final String originState;
  final String originStateId;
  final String originLga;
  final String originLgaId;
  final String destinationState;
  final String destinationStateId;
  final String destinationLga;
  final String destinationLgaId;
  final String payerEmail;

  const TransactionDraftModel({
    required this.vehicle,
    required this.originState,
    required this.originStateId,
    required this.originLga,
    required this.originLgaId,
    required this.destinationState,
    required this.destinationStateId,
    required this.destinationLga,
    required this.destinationLgaId,
    this.payerEmail = 'customer@tms.ng',
  });

  bool get isCompleteTrip => vehicle.transactionType == 'complete';

  String get routeSummary =>
      '$originLga, $originState \u2192 $destinationLga, $destinationState';
}
