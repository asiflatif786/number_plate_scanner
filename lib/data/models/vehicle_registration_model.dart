class VehicleRegistrationModel {
  final String licensePlate;
  final String vehicleType;
  final String chassisNumber;
  final String engineNumber;
  final String yearOfManufacture;
  final String ownerName;
  final String ownerPhone;
  final String ownerAddress;
  final String ownerState;
  final String ownerLga;
  final String issuingState;
  final String issuingLga;
  final String enumeratingState;
  final String enumeratingLga;

  const VehicleRegistrationModel({
    required this.licensePlate,
    required this.vehicleType,
    required this.chassisNumber,
    required this.engineNumber,
    required this.yearOfManufacture,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerAddress,
    required this.ownerState,
    required this.ownerLga,
    required this.issuingState,
    required this.issuingLga,
    required this.enumeratingState,
    required this.enumeratingLga,
  });

  Map<String, dynamic> toJson() => {
        'license_plate': licensePlate,
        'vehicle_type': vehicleType,
        'chassis_number': chassisNumber,
        'engine_number': engineNumber,
        'year_of_manufacture': yearOfManufacture,
        'owner_name': ownerName,
        'owner_phone': ownerPhone,
        'owner_address': ownerAddress,
        'owner_state': ownerState,
        'owner_lga': ownerLga,
        'issuing_state': issuingState,
        'issuing_lga': issuingLga,
        'enumerating_state': enumeratingState,
        'enumerating_lga': enumeratingLga,
      };
}
