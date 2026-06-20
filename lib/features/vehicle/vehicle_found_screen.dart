import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/vehicle_model.dart';
import 'vehicle_found_viewmodel.dart';

class VehicleFoundScreen extends StatelessWidget {
  const VehicleFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicle = ModalRoute.of(context)!.settings.arguments as VehicleModel;

    return ChangeNotifierProvider(
      create: (_) => VehicleFoundViewModel(vehicle: vehicle),
      child: const _VehicleFoundBody(),
    );
  }
}

class _VehicleFoundBody extends StatelessWidget {
  const _VehicleFoundBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Found'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<VehicleFoundViewModel>(
        builder: (context, vm, _) {
          final vehicle = vm.vehicle;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildStatusBanner(vehicle),
                const SizedBox(height: 16),
                _buildVehicleDetailsCard(vehicle),
                const SizedBox(height: 12),
                _buildFeeBreakdownCard(vm),
                const SizedBox(height: 24),
                _buildProceedButton(vm, context),
                const SizedBox(height: 12),
                _buildSquadCoButton(vm, context),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(VehicleModel vehicle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      color: Colors.green,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.check_circle, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          const Text(
            'Vehicle Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'This vehicle is registered in the Cyber1 database',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
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

  Widget _buildVehicleDetailsCard(VehicleModel vehicle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppCard(
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Vehicle Information'),
            const Divider(),
            DetailRow(label: 'License Plate', value: vehicle.vehicleLicense, isMonospace: true),
            const Divider(height: 1),
            DetailRow(label: 'Vehicle Type', value: vehicle.vehicleType),
            const Divider(height: 1),
            DetailRow(label: 'Issuing State', value: vehicle.stateOfOrigin),
            const Divider(height: 1),
            DetailRow(label: 'Enumerating State', value: vehicle.enumeratingState ?? 'N/A'),
            const Divider(height: 1),
            DetailRow(label: 'Enumerating LGA', value: vehicle.enumeratingLga ?? 'N/A'),
            const Divider(height: 1),
            _buildTripTypeChip(vehicle.transactionType),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdownCard(VehicleFoundViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppCard(
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildTotalPayableRow(vm.formattedTotalPayable),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton(VehicleFoundViewModel vm, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppButton(
        label: vm.isProceeding ? 'Proceeding...' : 'Proceed to Payment',
        onPressed: (vm.isProceeding || vm.isSquadCoProceeding)
            ? null
            : () => vm.proceedToPayment(context),
        isLoading: vm.isProceeding,
        icon: Icons.arrow_forward,
        color: Colors.green,
      ),
    );
  }

  Widget _buildSquadCoButton(VehicleFoundViewModel vm, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppButton(
        label: vm.isSquadCoProceeding ? 'Proceeding...' : 'Proceed With SquadCo',
        onPressed: (vm.isProceeding || vm.isSquadCoProceeding)
            ? null
            : () => vm.proceedWithSquadCo(context),
        isLoading: vm.isSquadCoProceeding,
        icon: Icons.payment,
        color: Colors.indigo,
      ),
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPayableRow(String formattedTotal) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Total Payable',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
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

  Widget _buildTripTypeChip(String transactionType) {
    final isSingle = transactionType == 'single';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(
            width: 140,
            child: Text('Trip Type', style: TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSingle
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isSingle ? 'Single Trip' : 'Complete Trip',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSingle ? Colors.blue : Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
