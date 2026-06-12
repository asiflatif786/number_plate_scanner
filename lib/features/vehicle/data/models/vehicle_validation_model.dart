import '../../domain/entities/vehicle_entity.dart';
import '../../../../core/utils/logger.dart';

class VehicleValidationModel {
  static const String _tag = 'VehicleValidationModel';

  static VehicleEntity fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final priceData = data['price'] as Map<String, dynamic>? ?? {};

    final entity = VehicleEntity(
      vehicleType: data['vehicle_type'] as String? ?? '',
      vehicleLicense: data['vehicle_license'] as String? ?? '',
      issuingState: data['issuing_state'] as String?,
      enumeratingState: data['enumerating_state'] as String?,
      enumeratingLga: data['enumerating_lga'] as String?,
      priceName: priceData['name'] as String? ?? '',
      priceType: priceData['type'] as String? ?? '',
      price: priceData['price'] as String? ?? '',
    );

    AppLogger.debug(_tag,
        'Parsed vehicle: ${entity.vehicleLicense} | price: ${entity.price}');
    return entity;
  }
}
