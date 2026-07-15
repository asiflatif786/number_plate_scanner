import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/section_header.dart';
import 'add_customer_viewmodel.dart';

class AddCustomerScreen extends StatelessWidget {
  const AddCustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final licensePlate = ModalRoute.of(context)!.settings.arguments as String;

    return ChangeNotifierProvider(
      create: (_) => AddCustomerViewModel(initialLicensePlate: licensePlate),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Add New Customer'),
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
        ),
        body: Consumer<AddCustomerViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading && vm.vehicleTypes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Customer Details'),
                        const SizedBox(height: 16),
                        
                        // Field 1: Vehicle License
                        AppTextField(
                          controller: vm.licensePlateController,
                          label: 'Vehicle License',
                          readOnly: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        const SizedBox(height: 16),

                        // Field 2: Vehicle Type (Dropdown)
                        _buildDropdown(
                          label: 'Vehicle Type',
                          value: vm.selectedVehicleType,
                          items: vm.vehicleTypes,
                          onChanged: vm.setVehicleType,
                          hint: 'Select Vehicle Type',
                        ),
                        const SizedBox(height: 16),

                        // Field 3: Issuing State (Dropdown)
                        _buildDropdown(
                          label: 'Issuing State',
                          value: vm.selectedIssuingState,
                          items: vm.issuingStates,
                          onChanged: vm.setIssuingState,
                          hint: 'Select Issuing State',
                        ),
                        
                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ],
                        
                        if (vm.successMessage != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            vm.successMessage!,
                            style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],

                        const SizedBox(height: 24),
                        AppButton(
                          label: 'Register Customer',
                          onPressed: () => vm.submit(context),
                          isLoading: vm.isLoading,
                          color: const Color(0xFF1A237E),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF616161),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
