import '../../../../core/constants/api_constants.dart';

class VehicleSearchParams {
  final String vehicleLicense;
  final String transactionType;
  final String serviceNumber;

  const VehicleSearchParams({
    required this.vehicleLicense,
    required this.transactionType,
    this.serviceNumber = '',
  });

  factory VehicleSearchParams.defaults({
    required String vehicleLicense,
    required String transactionType,
  }) {
    return VehicleSearchParams(
      vehicleLicense: vehicleLicense,
      transactionType: transactionType,
      serviceNumber: ApiConstants.serviceNumber,
    );
  }

  @override
  String toString() {
    return 'VehicleSearchParams(license: $vehicleLicense, type: $transactionType)';
  }
}
