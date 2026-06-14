import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/detail_row.dart';
import 'vehicle_registration_viewmodel.dart';

class VehicleRegistrationScreen extends StatelessWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final licensePlate = ModalRoute.of(context)!.settings.arguments as String;

    return ChangeNotifierProvider(
      create: (_) => VehicleRegistrationViewModel(licensePlate: licensePlate),
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
        title: const Text('Register Vehicle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<VehicleRegistrationViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBanner(),
                const SizedBox(height: 16),
                _buildVehicleInfoCard(vm),
                const SizedBox(height: 16),
                _buildOwnerInfoCard(vm),
                const SizedBox(height: 16),
                _buildRegistrationDetailsCard(vm),
                const SizedBox(height: 24),
                if (vm.errorMessage != null) ...[
                  _buildErrorBanner(vm),
                  const SizedBox(height: 16),
                ],
                _buildSubmitButton(vm, context),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: Color(0xFFF57F17)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This vehicle is not in the Cyber1 database. '
              'Fill in the details below to register it.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF795548)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(VehicleRegistrationViewModel vm) {
    return AppCard(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Vehicle Information', fontSize: 15),
          const SizedBox(height: 12),
          _buildLicensePlateField(vm),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Vehicle Type',
            value: vm.selectedVehicleType,
            items: AppConstants.vehicleTypes,
            onChanged: (v) => vm.setVehicleType(v),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: vm.chassisNumberController,
            label: 'Chassis Number',
            hint: 'Enter chassis number',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: vm.engineNumberController,
            label: 'Engine Number',
            hint: 'Enter engine number',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: vm.yearOfManufactureController,
            label: 'Year of Manufacture',
            hint: 'e.g. 2020',
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfoCard(VehicleRegistrationViewModel vm) {
    return AppCard(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Owner Information', fontSize: 15),
          const SizedBox(height: 12),
          AppTextField(
            controller: vm.ownerNameController,
            label: 'Owner Full Name',
            hint: 'Enter full name',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: vm.ownerPhoneController,
            label: 'Owner Phone',
            hint: 'Enter 11-digit phone number',
            keyboardType: TextInputType.phone,
            maxLength: 11,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: vm.ownerAddressController,
            label: 'Owner Address',
            hint: 'Enter address',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Owner State',
            value: vm.selectedOwnerState,
            items: vm.states,
            onChanged: (v) => vm.onOwnerStateChanged(v),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Owner LGA',
            value: vm.selectedOwnerLga,
            items: vm.ownerLgas,
            onChanged: (v) => vm.setOwnerLga(v),
            disabled: vm.selectedOwnerState == null,
            disabledHint: 'Select owner state first',
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationDetailsCard(VehicleRegistrationViewModel vm) {
    return AppCard(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Registration Details', fontSize: 15),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Issuing State',
            value: vm.selectedIssuingState,
            items: vm.states,
            onChanged: (v) => vm.onIssuingStateChanged(v),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Issuing LGA',
            value: vm.selectedIssuingLga,
            items: vm.issuingLgas,
            onChanged: (v) => vm.setIssuingLga(v),
            disabled: vm.selectedIssuingState == null,
            disabledHint: 'Select issuing state first',
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Enumerating State',
            value: vm.selectedEnumeratingState,
            items: vm.states,
            onChanged: (v) => vm.onEnumeratingStateChanged(v),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Enumerating LGA',
            value: vm.selectedEnumeratingLga,
            items: vm.enumeratingLgas,
            onChanged: (v) => vm.setEnumeratingLga(v),
            disabled: vm.selectedEnumeratingState == null,
            disabledHint: 'Select enumerating state first',
          ),
        ],
      ),
    );
  }

  Widget _buildLicensePlateField(VehicleRegistrationViewModel vm) {
    return AppTextField(
      controller: vm.licensePlateController,
      label: 'License Plate',
      readOnly: true,
      fillColor: const Color(0xFF212121),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool disabled = false,
    String? disabledHint,
  }) {
    if (disabled) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          hintText: disabledHint ?? 'Select an option',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        isExpanded: true,
        items: const [],
        onChanged: null,
      );
    }

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      isExpanded: true,
      menuMaxHeight: 250,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
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

  Widget _buildErrorBanner(VehicleRegistrationViewModel vm) {
    return Container(
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
    );
  }

  Widget _buildSubmitButton(
      VehicleRegistrationViewModel vm, BuildContext context) {
    return AppButton(
      label: 'Register Vehicle',
      onPressed: () => vm.submit(context),
      isLoading: vm.isLoading,
      height: 50,
      color: const Color(0xFF1A237E),
      textColor: Colors.white,
    );
  }
}
