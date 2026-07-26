import 'package:flutter/material.dart';
import '../../app/routes.dart';

class PaymentTypeSelectionScreen extends StatelessWidget {
  const PaymentTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Select Payment Type'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What would you like to do today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the type of payment you want to process for the vehicle.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildSelectionCard(
              context,
              title: 'CHL - Inter State',
              subtitle: 'Consolidated Haulage Levy (Between States)',
              icon: Icons.departure_board,
              color: const Color(0xFF1A237E),
              onTap: () => _navigateToSearch(context, 'chl-inter'),
            ),
            const SizedBox(height: 16),
            _buildSelectionCard(
              context,
              title: 'CHL - Intra State',
              subtitle: 'Consolidated Haulage Levy (Within State)',
              icon: Icons.local_shipping,
              color: Colors.green.shade700,
              onTap: () => _navigateToSearch(context, 'chl-intra'),
            ),
            const SizedBox(height: 16),
            _buildSelectionCard(
              context,
              title: 'Penalty',
              subtitle: 'Search and pay for vehicle penalties',
              icon: Icons.gavel,
              color: Colors.red.shade700,
              onTap: () => Navigator.pushNamed(context, AppRoutes.penaltyStateSelection),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context, String type) {
    Navigator.pushNamed(
      context,
      AppRoutes.vehicleSearch,
      arguments: {'paymentType': type},
    );
  }
}
