import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/state_model.dart';
import '../../data/models/lga_model.dart';
import '../../data/models/vehicle_model.dart';
import 'vehicle_registration_viewmodel.dart';

class VehicleRegistrationScreen extends StatelessWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicle = ModalRoute.of(context)!.settings.arguments as VehicleModel;

    return ChangeNotifierProvider(
      create: (_) => VehicleRegistrationViewModel(vehicle: vehicle),
      child: const _VehicleRegistrationBody(),
    );
  }
}

class _VehicleRegistrationBody extends StatelessWidget {
  const _VehicleRegistrationBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Registration'),
      ),
      body: Consumer<VehicleRegistrationViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVehicleSummaryCard(vm.vehicle),
                const SizedBox(height: 20),
                _buildSectionHeader(Icons.location_on, 'Origin Details'),
                const SizedBox(height: 8),
                _buildOriginStateDropdown(vm),
                const SizedBox(height: 12),
                _buildOriginLgaDropdown(vm),
                const SizedBox(height: 24),
                _buildSectionHeader(Icons.flag, 'Destination Details'),
                const SizedBox(height: 8),
                _buildDestinationStateDropdown(vm),
                const SizedBox(height: 12),
                _buildDestinationLgaDropdown(vm),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorBanner(vm),
                ],
                if (vm.selectedDestinationLga != null) ...[
                  const SizedBox(height: 16),
                  _buildFeePreviewCard(vm),
                ],
                const SizedBox(height: 24),
                _buildSubmitButton(vm, context),
                const SizedBox(height: 8),
                _buildBottomCaption(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleSummaryCard(VehicleModel vehicle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.customerName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121)),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.vehicleLicense,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              vehicle.transactionType == 'single'
                  ? 'Single Trip'
                  : 'Complete Trip',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A237E)),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121))),
      ],
    );
  }

  Widget _buildOriginStateDropdown(VehicleRegistrationViewModel vm) {
    if (vm.isLoadingStates) {
      return _buildLoadingDropdown(
        label: 'State of Origin',
        hint: 'Loading states...',
      );
    }

    if (vm.states.isEmpty) {
      return _buildRetryButton(vm);
    }

    return _buildDropdown<StateModel>(
      label: 'State of Origin',
      hint: 'Select state',
      value: vm.selectedOriginState,
      items: vm.states,
      itemLabel: (s) => s.stateName,
      onChanged: (v) => vm.onOriginStateChanged(v),
    );
  }

  Widget _buildOriginLgaDropdown(VehicleRegistrationViewModel vm) {
    if (vm.selectedOriginState == null) {
      return _buildDisabledDropdown(
        label: 'Origin LGA',
        hint: 'Select origin state first',
      );
    }

    if (vm.isLoadingOriginLgas) {
      return _buildLoadingDropdown(
        label: 'Origin LGA',
        hint: 'Loading LGAs...',
      );
    }

    return _buildDropdown<LgaModel>(
      label: 'Origin LGA',
      hint: 'Select LGA',
      value: vm.selectedOriginLga,
      items: vm.originLgas,
      itemLabel: (l) => l.lgaName,
      onChanged: (v) => vm.onOriginLgaChanged(v),
    );
  }

  Widget _buildDestinationStateDropdown(VehicleRegistrationViewModel vm) {
    if (vm.isLoadingStates) {
      return _buildLoadingDropdown(
        label: 'Destination State',
        hint: 'Loading states...',
      );
    }

    if (vm.states.isEmpty) {
      return _buildRetryButton(vm);
    }

    return _buildDropdown<StateModel>(
      label: 'Destination State',
      hint: 'Select state',
      value: vm.selectedDestinationState,
      items: vm.states,
      itemLabel: (s) => s.stateName,
      onChanged: (v) => vm.onDestinationStateChanged(v),
    );
  }

  Widget _buildDestinationLgaDropdown(VehicleRegistrationViewModel vm) {
    if (vm.selectedDestinationState == null) {
      return _buildDisabledDropdown(
        label: 'Destination LGA',
        hint: 'Select destination state first',
      );
    }

    if (vm.isLoadingDestinationLgas) {
      return _buildLoadingDropdown(
        label: 'Destination LGA',
        hint: 'Loading LGAs...',
      );
    }

    return _buildDropdown<LgaModel>(
      label: 'Destination LGA',
      hint: 'Select LGA',
      value: vm.selectedDestinationLga,
      items: vm.destinationLgas,
      itemLabel: (l) => l.lgaName,
      onChanged: (v) => vm.onDestinationLgaChanged(v),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      isExpanded: true,
      menuMaxHeight: 250,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildLoadingDropdown({required String label, required String hint}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      isExpanded: true,
      items: const [],
      onChanged: null,
    );
  }

  Widget _buildDisabledDropdown({required String label, required String hint}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      isExpanded: true,
      items: const [],
      onChanged: null,
    );
  }

  Widget _buildRetryButton(VehicleRegistrationViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: vm.loadStates,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, size: 18, color: Color(0xFFE65100)),
            SizedBox(width: 8),
            Text(
              'Failed to load states. Tap to retry',
              style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFE65100),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(VehicleRegistrationViewModel vm) {
    return Dismissible(
      key: const ValueKey('error_banner'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.clearError(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 20, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vm.errorMessage!,
                style: TextStyle(fontSize: 13, color: Colors.red.shade800),
              ),
            ),
              InkWell(
              onTap: vm.clearError,
              child: Icon(Icons.close, size: 18, color: Colors.red.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeePreviewCard(VehicleRegistrationViewModel vm) {
    final vehicle = vm.vehicle;
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction Summary',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32))),
            const Divider(),
            _buildFeeRow('Customer', vehicle.customerName),
            _buildFeeRow('License Plate', vehicle.vehicleLicense),
            _buildFeeRow(
                'Trip Type',
                vehicle.transactionType == 'single'
                    ? 'Single Trip'
                    : 'Complete Trip'),
            _buildFeeRow(
                'Route',
                '${vm.selectedOriginLga!.lgaName}, '
                '${vm.selectedOriginState!.stateName}'
                ' \u2192 '
                '${vm.selectedDestinationLga!.lgaName}, '
                '${vm.selectedDestinationState!.stateName}'),
            const Divider(),
            Row(
              children: [
                const Expanded(
                  child: Text('Total Payable',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121))),
                ),
                Text(
                  vehicle.price.formattedTotal,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121)),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(VehicleRegistrationViewModel vm, BuildContext context) {
    final canSubmit = vm.selectedOriginState != null &&
        vm.selectedOriginLga != null &&
        vm.selectedDestinationState != null &&
        vm.selectedDestinationLga != null;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: canSubmit && !vm.isSubmitting
            ? () => vm.submit(context)
            : null,
        icon: vm.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.arrow_forward),
        label: Text(
          vm.isSubmitting
              ? 'Submitting...'
              : 'Confirm & Proceed to Payment',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1A237E).withValues(alpha: 0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildBottomCaption() {
    return const Center(
      child: Text(
        'Step 2 of 3 \u2014 Select trip route',
        style: TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}
