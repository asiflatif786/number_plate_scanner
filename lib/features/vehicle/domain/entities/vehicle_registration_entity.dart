class VehicleRegistrationEntity {
  final String vehicleLicense;
  final String vehicleType;
  final String engineNumber;
  final String chassisNumber;
  final String color;
  final String make;
  final String model;
  final int year;
  final String plateType;
  final String issuingState;
  final String? enumeratingState;
  final String? enumeratingLga;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final String ownerAddress;

  const VehicleRegistrationEntity({
    required this.vehicleLicense,
    required this.vehicleType,
    required this.engineNumber,
    required this.chassisNumber,
    required this.color,
    required this.make,
    required this.model,
    required this.year,
    required this.plateType,
    required this.issuingState,
    this.enumeratingState,
    this.enumeratingLga,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.ownerAddress,
  });

  VehicleRegistrationEntity copyWith({
    String? vehicleLicense,
    String? vehicleType,
    String? engineNumber,
    String? chassisNumber,
    String? color,
    String? make,
    String? model,
    int? year,
    String? plateType,
    String? issuingState,
    String? enumeratingState,
    String? enumeratingLga,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    String? ownerAddress,
  }) {
    return VehicleRegistrationEntity(
      vehicleLicense: vehicleLicense ?? this.vehicleLicense,
      vehicleType: vehicleType ?? this.vehicleType,
      engineNumber: engineNumber ?? this.engineNumber,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      color: color ?? this.color,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      plateType: plateType ?? this.plateType,
      issuingState: issuingState ?? this.issuingState,
      enumeratingState: enumeratingState ?? this.enumeratingState,
      enumeratingLga: enumeratingLga ?? this.enumeratingLga,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerAddress: ownerAddress ?? this.ownerAddress,
    );
  }

  @override
  String toString() {
    return 'VehicleRegistrationEntity(license: $vehicleLicense, type: $vehicleType, '
        'make: $make, model: $model, year: $year, owner: $ownerName)';
  }
}
