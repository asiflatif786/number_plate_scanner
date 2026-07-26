import 'package:flutter/material.dart';
import '../../app/routes.dart';

class PenaltyStateSelectionScreen extends StatelessWidget {
  const PenaltyStateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Penalty Category'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Penalty Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose whether this penalty is for Inter-State or Intra-State haulage.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildSelectionCard(
              context,
              title: 'Inter-State Penalty',
              subtitle: 'Penalty for vehicles on inter-state routes',
              icon: Icons.departure_board,
              color: Colors.red.shade700,
              onTap: () => _navigateToSearch(context, 'penalty-inter'),
            ),
            const SizedBox(height: 16),
            _buildSelectionCard(
              context,
              title: 'Intra-State Penalty',
              subtitle: 'Penalty for vehicles on intra-state routes',
              icon: Icons.local_shipping,
              color: Colors.orange.shade800,
              onTap: () => _navigateToSearch(context, 'penalty-intra'),
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
