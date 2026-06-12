import '../../domain/entities/vehicle_registration_entity.dart';
import '../../../../core/utils/logger.dart';

class VehicleRegistrationModel {
  static const String _tag = 'VehicleRegistrationModel';

  static Map<String, dynamic> toJson(VehicleRegistrationEntity entity) {
    AppLogger.debug(_tag,
        'Payload built for license: ${entity.vehicleLicense}');

    return {
      'vehicle_license': entity.vehicleLicense,
      'vehicle_type': entity.vehicleType,
      'engine_number': entity.engineNumber,
      'chassis_number': entity.chassisNumber,
      'color': entity.color,
      'make': entity.make,
      'model': entity.model,
      'year': entity.year.toString(),
      'plate_type': entity.plateType,
      'issuing_state': entity.issuingState.toUpperCase(),
      'enumerating_state': entity.enumeratingState?.toUpperCase(),
      'enumerating_lga': entity.enumeratingLga,
      'owner_name': entity.ownerName,
      'owner_phone': entity.ownerPhone,
      'owner_email': entity.ownerEmail,
      'owner_address': entity.ownerAddress,
    };
  }

  static VehicleRegistrationEntity fromJson(Map<String, dynamic> json) {
    return VehicleRegistrationEntity(
      vehicleLicense: json['vehicle_license'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      engineNumber: json['engine_number'] as String? ?? '',
      chassisNumber: json['chassis_number'] as String? ?? '',
      color: json['color'] as String? ?? '',
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: int.tryParse(json['year']?.toString() ?? '') ?? 0,
      plateType: json['plate_type'] as String? ?? '',
      issuingState: json['issuing_state'] as String? ?? '',
      enumeratingState: json['enumerating_state'] as String?,
      enumeratingLga: json['enumerating_lga'] as String?,
      ownerName: json['owner_name'] as String? ?? '',
      ownerPhone: json['owner_phone'] as String? ?? '',
      ownerEmail: json['owner_email'] as String? ?? '',
      ownerAddress: json['owner_address'] as String? ?? '',
    );
  }
}
