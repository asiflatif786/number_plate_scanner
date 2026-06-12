import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/vehicle_model.dart';
import 'vehicle_found_viewmodel.dart';

class VehicleFoundScreen extends StatelessWidget {
  const VehicleFoundScreen({super.key});

  Color _colorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'silver':
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      case 'gold':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ModalRoute.of(context)!.settings.arguments as VehicleModel;

    return ChangeNotifierProvider(
      create: (_) => VehicleFoundViewModel(vehicle: vehicle),
      child: _VehicleFoundBody(colorFromString: _colorFromString),
    );
  }
}

class _VehicleFoundBody extends StatelessWidget {
  final Color Function(String) colorFromString;

  const _VehicleFoundBody({required this.colorFromString});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Found'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<VehicleFoundViewModel>(
        builder: (context, vm, _) {
          final vehicle = vm.vehicle;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSuccessBanner(context, vehicle),
                const SizedBox(height: 16),
                _buildCustomerDetailsCard(context, vehicle),
                const SizedBox(height: 12),
                _buildVehicleDetailsCard(context, vehicle),
                const SizedBox(height: 12),
                _buildTransactionSummaryCard(context, vehicle),
                const SizedBox(height: 8),
                _buildDisclaimer(),
                const SizedBox(height: 20),
                _buildProceedButton(context, vm),
                const SizedBox(height: 8),
                _buildBottomNote(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessBanner(BuildContext context, VehicleModel vehicle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: Colors.green.shade50,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green,
            child: Icon(Icons.check_circle, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          Text('Vehicle Verified',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800)),
          const SizedBox(height: 4),
          Text('Customer details loaded successfully',
              style: TextStyle(fontSize: 13, color: Colors.green.shade600)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              vehicle.vehicleLicense,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 3,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsCard(BuildContext context, VehicleModel vehicle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer Details',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121))),
              const Divider(),
              _buildDetailRow('Full Name', vehicle.customerName),
              const Divider(height: 1),
              _buildDetailRow(
                  'Phone Number',
                  (vehicle.phoneNumber != null && vehicle.phoneNumber != 'N/A')
                      ? vehicle.phoneNumber!
                      : 'Not provided'),
              const Divider(height: 1),
              _buildDetailRow('State of Origin', vehicle.stateOfOrigin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleDetailsCard(BuildContext context, VehicleModel vehicle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Vehicle Information',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121))),
              const Divider(),
              _buildDetailRow(
                  'License Plate', vehicle.vehicleLicense,
                  isMonospace: true),
              const Divider(height: 1),
              _buildDetailRow('Vehicle Type', vehicle.vehicleType),
              const Divider(height: 1),
              _buildDetailRow(
                  'Make & Model', '${vehicle.vehicleMake} ${vehicle.vehicleModel}'),
              const Divider(height: 1),
              _buildColorRow(vehicle.vehicleColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSummaryCard(
      BuildContext context, VehicleModel vehicle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: const Border(
              left: BorderSide(color: Colors.amber, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transaction Summary',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121))),
              const Divider(),
              _buildDetailRow(
                  'Trip Type',
                  vehicle.transactionType == 'single'
                      ? 'Single Trip'
                      : 'Complete Trip'),
              const Divider(height: 1),
              _buildDetailRow('Base Amount', vehicle.price.formattedAmount),
              const Divider(height: 1),
              _buildDetailRow(
                  'Service Fee', vehicle.price.formattedServiceFee),
              const Divider(thickness: 1.5, height: 20),
              _buildTotalRow(vehicle.price.formattedTotal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF212121),
                fontFamily: isMonospace ? 'monospace' : null,
                letterSpacing: isMonospace ? 1.5 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(String colorName) {
    final color = colorFromString(colorName);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 120,
            child: Text('Color',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: color),
              const SizedBox(width: 8),
              Text(
                colorName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String formattedTotal) {
    return Row(
      children: [
        const Expanded(
          child: Text('Total Payable',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121))),
        ),
        Text(
          formattedTotal,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'The agent will collect this amount from the customer before proceeding.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context, VehicleFoundViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed:
              vm.isProceeding ? null : () => vm.proceedToTransaction(context),
          icon: vm.isProceeding
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.arrow_forward),
          label: Text(
            vm.isProceeding ? 'Proceeding...' : 'Proceed to Registration',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.green.shade300,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNote() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'Verify all details with the customer before proceeding',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}
