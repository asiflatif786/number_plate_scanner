import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';

class VehicleNotFoundCard extends StatelessWidget {
  final String licensePlate;
  final VoidCallback onRegister;
  final VoidCallback onSearchAgain;

  const VehicleNotFoundCard({
    super.key,
    required this.licensePlate,
    required this.onRegister,
    required this.onSearchAgain,
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
          children: [
            _buildIcon(),
            const SizedBox(height: 12),
            _buildNotFoundBadge(),
            const SizedBox(height: 8),
            const Text(
              'Vehicle Not Registered',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            _buildMessage(),
            const Divider(height: 24),
            const Text(
              'Would you like to register this vehicle?',
              style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildRegisterButton(),
            const SizedBox(height: 8),
            _buildSearchAgainButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF3E0),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.search_off_rounded,
        size: 40,
        color: Color(0xFFF57C00),
      ),
    );
  }

  Widget _buildNotFoundBadge() {
    return FittedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFC62828),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'NOT FOUND',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMessage() {
    return Column(
      children: [
        const Text(
          'The vehicle with license plate',
          style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          licensePlate,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'was not found in the Cyber1 database.',
          style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onRegister,
        icon: const Icon(Icons.app_registration, color: Colors.white),
        label: const Text(
          'Register Vehicle',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAgainButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: TextButton.icon(
        onPressed: onSearchAgain,
        icon: const Icon(Icons.refresh, color: Color(0xFF0288D1)),
        label: const Text(
          'Search Again',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0288D1),
          ),
        ),
      ),
    );
  }
}
