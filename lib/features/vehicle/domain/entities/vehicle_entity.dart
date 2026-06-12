class VehicleEntity {
  final String vehicleType;
  final String vehicleLicense;
  final String? issuingState;
  final String? enumeratingState;
  final String? enumeratingLga;
  final String priceName;
  final String priceType;
  final String price;

  const VehicleEntity({
    required this.vehicleType,
    required this.vehicleLicense,
    this.issuingState,
    this.enumeratingState,
    this.enumeratingLga,
    required this.priceName,
    required this.priceType,
    required this.price,
  });

  VehicleEntity copyWith({
    String? vehicleType,
    String? vehicleLicense,
    String? issuingState,
    String? enumeratingState,
    String? enumeratingLga,
    String? priceName,
    String? priceType,
    String? price,
  }) {
    return VehicleEntity(
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleLicense: vehicleLicense ?? this.vehicleLicense,
      issuingState: issuingState ?? this.issuingState,
      enumeratingState: enumeratingState ?? this.enumeratingState,
      enumeratingLga: enumeratingLga ?? this.enumeratingLga,
      priceName: priceName ?? this.priceName,
      priceType: priceType ?? this.priceType,
      price: price ?? this.price,
    );
  }

  @override
  String toString() {
    return 'VehicleEntity(license: $vehicleLicense, type: $vehicleType, price: $price)';
  }
}
