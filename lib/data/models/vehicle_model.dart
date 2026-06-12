import 'price_model.dart';

class VehicleModel {
  final String customerName;
  final String vehicleLicense;
  final String vehicleType;
  final String vehicleColor;
  final String vehicleMake;
  final String vehicleModel;
  final String stateOfOrigin;
  final String? phoneNumber;
  final String transactionType;
  final PriceModel price;

  const VehicleModel({
    required this.customerName,
    required this.vehicleLicense,
    required this.vehicleType,
    required this.vehicleColor,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.stateOfOrigin,
    this.phoneNumber,
    this.transactionType = 'single',
    required this.price,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final priceData = json['price'] as Map<String, dynamic>? ?? {};
    return VehicleModel(
      customerName: json['customer_name'] as String? ?? 'N/A',
      vehicleLicense: json['vehicle_license'] as String? ?? 'N/A',
      vehicleType: json['vehicle_type'] as String? ?? priceData['name'] as String? ?? 'N/A',
      vehicleColor: json['vehicle_color'] as String? ?? 'N/A',
      vehicleMake: json['vehicle_make'] as String? ?? 'N/A',
      vehicleModel: json['vehicle_model'] as String? ?? 'N/A',
      stateOfOrigin: json['state_of_origin'] as String? ?? json['issuing_state'] as String? ?? 'N/A',
      phoneNumber: json['phone_number'] as String?,
      transactionType: json['transaction_type'] as String? ?? priceData['type'] as String? ?? 'single',
      price: PriceModel.fromJson(priceData),
    );
  }

  Map<String, dynamic> toJson() => {
        'customer_name': customerName,
        'vehicle_license': vehicleLicense,
        'vehicle_type': vehicleType,
        'vehicle_color': vehicleColor,
        'vehicle_make': vehicleMake,
        'vehicle_model': vehicleModel,
        'state_of_origin': stateOfOrigin,
        'phone_number': phoneNumber,
        'transaction_type': transactionType,
        'price': price.toJson(),
      };
}
