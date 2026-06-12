import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/entities/vehicle_entity.dart';

class VehicleFoundCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback onProceed;

  const VehicleFoundCard({
    super.key,
    required this.vehicle,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.cardPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 24),
            _buildInfoRow(context, Icons.directions_car, 'Vehicle Type', vehicle.vehicleType),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.location_on, 'Issuing State',
                vehicle.issuingState ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.map, 'Registered In',
                vehicle.enumeratingState ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.zoom_out_map, 'LGA',
                vehicle.enumeratingLga ?? 'N/A'),
            const Divider(height: 24),
            _buildPriceSection(context),
            const SizedBox(height: 20),
            _buildProceedButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'FOUND',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        FittedBox(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              vehicle.vehicleLicense,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: ResponsiveHelper.iconSize(context, 20), color: const Color(0xFF1A237E)),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amount Due',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    '₦${vehicle.price}',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A237E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              vehicle.priceType.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.buttonHeight(context),
      child: ElevatedButton.icon(
        onPressed: onProceed,
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text(
          'Proceed to Payment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
