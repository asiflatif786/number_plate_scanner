import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/section_header.dart';
import 'vehicle_not_found_viewmodel.dart';

class VehicleNotFoundScreen extends StatelessWidget {
  const VehicleNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final licensePlate = args['licensePlate'] as String;
    final metadata = args['metadata'] as Map<String, dynamic>?;
    final rfidData = args['rfidData'] as Map<String, dynamic>?;

    return ChangeNotifierProvider(
      create: (_) => VehicleNotFoundViewModel(
        licensePlate: licensePlate,
        metadata: metadata,
        rfidData: rfidData,
      ),
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
      ),
      body: Consumer<VehicleNotFoundViewModel>(
        builder: (context, vm, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 24,
                          child: Icon(Icons.close, color: Colors.red, size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Vehicle Not Found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Plate ${vm.licensePlate} is not registered in the Cyber1 database',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            vm.licensePlate,
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
                  ),
                  const SizedBox(height: 24),

                  // Display RFID Data if available from external registry
                  if (vm.rfidData != null) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'External Registry Details'),
                          const Divider(),
                          DetailRow(
                            label: 'Vehicle License',
                            value: vm.rfidData?['vehicle_license']?.toString() ?? 'N/A',
                          ),
                          const Divider(height: 1),
                          DetailRow(
                            label: 'Vehicle Type',
                            value: vm.rfidData?['vehicle_type']?.toString() ?? 'N/A',
                          ),
                          const Divider(height: 1),
                          DetailRow(
                            label: 'Issuing State',
                            value: vm.rfidData?['issuing_state']?.toString() ?? 'N/A',
                          ),
                          const Divider(height: 1),
                          DetailRow(
                            label: 'VIN',
                            value: vm.rfidData?['vin']?.toString() ?? 'N/A',
                          ),
                          const Divider(height: 1),
                          DetailRow(
                            label: 'Enum. State/LGA',
                            value: '${vm.rfidData?['enumerating_state'] ?? 'N/A'} / ${vm.rfidData?['enumerating_lga'] ?? 'N/A'}',
                          ),
                          const Divider(height: 1),
                          DetailRow(
                            label: 'Status',
                            value: vm.rfidData?['vehicle_status']?.toString().toUpperCase() ?? 'N/A',
                          ),
                          if (vm.rfidData?['tag_details'] != null) ...[
                            const Divider(height: 1),
                            DetailRow(
                              label: 'Tag Expiry',
                              value: vm.rfidData?['tag_details']?['next_renewal_date']?.toString() ?? 'N/A',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (vm.metadata != null && vm.rfidData == null) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Available Metadata'),
                          const Divider(),
                          DetailRow(
                            label: 'Service Number',
                            value: vm.metadata?['service_number']?.toString() ?? 'N/A',
                          ),
                          const Divider(height: 1),
                          DetailRow(
                            label: 'Vehicle License',
                            value: vm.metadata?['metadata']?['vehicle_license']?.toString() ?? 'N/A',
                          ),
                          const Divider(height: 1),
                          DetailRow(
                            label: 'Vehicle Type',
                            value: vm.metadata?['metadata']?['vehicle_type']?.toString() ?? 'N/A',
                          ),
                          const Divider(height: 1),
                          DetailRow(
                            label: 'Issuing State',
                            value: vm.metadata?['metadata']?['issuing_state']?.toString() ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What would you like to do?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: const Text(
                            'This plate was not found in the primary database. You can register this vehicle as a new customer or try another search.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF795548),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Add Customer',
                          onPressed: () => vm.addCustomer(context),
                          icon: Icons.person_add,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => vm.searchAgain(context),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search,
                                    color: Colors.grey, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Search Again',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF212121))),
                                      const SizedBox(height: 2),
                                      Text(
                                          'Try a different license plate number',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios,
                                    color: Colors.grey[400], size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
