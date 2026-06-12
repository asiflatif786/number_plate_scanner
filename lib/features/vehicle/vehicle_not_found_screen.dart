import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'vehicle_not_found_viewmodel.dart';

class VehicleNotFoundScreen extends StatelessWidget {
  const VehicleNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final licensePlate = ModalRoute.of(context)!.settings.arguments as String;

    return ChangeNotifierProvider(
      create: (_) => VehicleNotFoundViewModel(licensePlate: licensePlate),
      child: const _VehicleNotFoundBody(),
    );
  }
}

class _VehicleNotFoundBody extends StatelessWidget {
  const _VehicleNotFoundBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Not Found'),
        foregroundColor: const Color(0xFF212121),
      ),
      body: Consumer<VehicleNotFoundViewModel>(
        builder: (context, vm, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off,
                      size: 80, color: Color(0xFFE53935)),
                  const SizedBox(height: 20),
                  const Text('Vehicle Not Found',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121))),
                  const SizedBox(height: 8),
                  const Text(
                    'No registered vehicle was found for the license plate:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade400, width: 1.5),
                    ),
                    child: Text(
                      vm.licensePlate,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 3,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPossibleReasons(),
                  const SizedBox(height: 28),
                  _buildSearchAgainButton(context, vm),
                  const SizedBox(height: 12),
                  _buildDashboardButton(context, vm),
                  const SizedBox(height: 20),
                  const Text(
                    'If this vehicle should be registered, contact Cyber1 support',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPossibleReasons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Possible Reasons',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF9A825))),
          const SizedBox(height: 10),
          _buildBullet(
              'The vehicle is not registered in the Cyber1 TMS system'),
          _buildBullet(
              'The license plate may have been entered incorrectly'),
          _buildBullet(
              'The vehicle registration may have expired'),
          _buildBullet(
              'Contact your supervisor if you believe this is an error'),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('  \u2022  ',
              style: TextStyle(fontSize: 13, color: Color(0xFF616161))),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: Color(0xFF616161))),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAgainButton(
      BuildContext context, VehicleNotFoundViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => vm.retrySearch(context),
        icon: const Icon(Icons.refresh),
        label: const Text('Search Again',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, VehicleNotFoundViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => vm.goToDashboard(context),
        icon: const Icon(Icons.home),
        label: const Text('Back to Dashboard',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A237E),
          side: const BorderSide(color: Color(0xFF1A237E)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
