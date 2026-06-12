import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session/session_manager.dart';
import '../../data/models/transaction_draft_model.dart';
import 'transaction_creation_viewmodel.dart';

class TransactionCreationScreen extends StatefulWidget {
  const TransactionCreationScreen({super.key});

  @override
  State<TransactionCreationScreen> createState() =>
      _TransactionCreationScreenState();
}

class _TransactionCreationScreenState
    extends State<TransactionCreationScreen> {
  String? _agentNumber;
  String? _terminalId;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await SessionManager.instance;
    setState(() {
      _agentNumber = session.agentNumber;
      _terminalId = session.terminalId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft =
        ModalRoute.of(context)!.settings.arguments as TransactionDraftModel;

    return ChangeNotifierProvider(
      create: (_) => TransactionCreationViewModel(draft: draft),
      child: _TransactionCreationBody(
        agentNumber: _agentNumber,
        terminalId: _terminalId,
      ),
    );
  }
}

class _TransactionCreationBody extends StatelessWidget {
  final String? agentNumber;
  final String? terminalId;

  const _TransactionCreationBody({
    required this.agentNumber,
    required this.terminalId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Transaction'),
      ),
      body: Consumer<TransactionCreationViewModel>(
        builder: (context, vm, _) {
          final vehicle = vm.draft.vehicle;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomerInfoFields(vm),
                const SizedBox(height: 12),
                _buildCustomerVehicleCard(vehicle, vm.draft),
                const SizedBox(height: 12),
                _buildRouteCard(vm.draft),
                const SizedBox(height: 12),
                _buildFeeBreakdownCard(vehicle),
                const SizedBox(height: 16),
                _buildPaymentMethodSection(vm),
                const SizedBox(height: 12),
                _buildAgentInfoCard(),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorBanner(vm),
                ],
                const SizedBox(height: 20),
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

  Widget _buildCustomerInfoFields(TransactionCreationViewModel vm) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit, size: 18, color: Color(0xFF1A237E)),
                SizedBox(width: 6),
                Text('Customer Details',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121))),
              ],
            ),
            const Divider(),
            TextField(
              controller: vm.payerNameController,
              decoration: InputDecoration(
                labelText: 'Payer Name *',
                hintText: 'Enter customer full name',
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vm.payerPhoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter customer phone number',
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerVehicleCard(vehicle, TransactionDraftModel draft) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Color(0xFF1A237E)),
                const SizedBox(width: 6),
                const Text('Customer & Vehicle',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121))),
              ],
            ),
            const Divider(),
            _buildRow('Customer Name', vehicle.customerName),
            const SizedBox(height: 6),
            _buildRow('License Plate', vehicle.vehicleLicense,
                isMonospace: true),
            const SizedBox(height: 6),
            _buildRow(
                'Vehicle',
                '${vehicle.vehicleMake} ${vehicle.vehicleModel} (${vehicle.vehicleColor})'),
            const SizedBox(height: 6),
            _buildTripTypeChip(vehicle.transactionType),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(TransactionDraftModel draft) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: Color(0xFF1A237E), width: 4),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, size: 18, color: Color(0xFF1A237E)),
                const SizedBox(width: 6),
                const Text('Trip Route',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121))),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FROM',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(draft.originLga,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121))),
                      Text(draft.originState,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.arrow_forward,
                          size: 20, color: Color(0xFF1A237E)),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('TO',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(draft.destinationLga,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121))),
                      Text(draft.destinationState,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdownCard(vehicle) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, size: 18, color: Color(0xFF1A237E)),
                const SizedBox(width: 6),
                const Text('Fee Breakdown',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121))),
              ],
            ),
            const Divider(),
            _buildFeeRow('Base Amount', vehicle.price.formattedAmount),
            const SizedBox(height: 6),
            _buildFeeRow('Service Fee', vehicle.price.formattedServiceFee),
            const Divider(thickness: 1.5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Total Payable',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121))),
                  ),
                  Text(
                    vehicle.price.formattedTotal,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(TransactionCreationViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.payment, size: 18, color: Color(0xFF1A237E)),
            const SizedBox(width: 6),
            const Text('Payment Method',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121))),
          ],
        ),
        const SizedBox(height: 8),
        ...TransactionCreationViewModel.paymentMethods.map((method) {
          final value = method['value'] as String;
          final label = method['label'] as String;
          final icon = method['icon'] as IconData;
          final color = method['color'] as Color;
          final subtitle = method['subtitle'] as String;
          final isSelected = vm.selectedPaymentMethod == value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => vm.onPaymentMethodChanged(value),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      isSelected ? color.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121))),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? color : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAgentInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaction will be processed on:',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                  width: 100,
                  child: Text('Agent Number',
                      style: TextStyle(fontSize: 11, color: Colors.grey))),
              Text(
                agentNumber ?? 'N/A',
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(
                  width: 100,
                  child: Text('Terminal ID',
                      style: TextStyle(fontSize: 11, color: Colors.grey))),
              Text(
                terminalId ?? 'N/A',
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(TransactionCreationViewModel vm) {
    return Dismissible(
      key: const ValueKey('txn_error_banner'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.errorMessage = null,
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
              onTap: () {
                vm.clearError();
              },
              child: Icon(Icons.close, size: 18, color: Colors.red.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
      TransactionCreationViewModel vm, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed:
            vm.isSubmitting ? null : () => vm.submit(context),
        icon: vm.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.check_circle),
        label: Text(
          vm.isSubmitting ? 'Creating...' : 'Create Transaction',
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
        'Step 3 of 3 \u2014 Review and confirm',
        style: TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }

  // ── Helpers ──

  Widget _buildRow(String label, String value, {bool isMonospace = false}) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF212121),
              fontFamily: isMonospace ? 'monospace' : null,
              letterSpacing: isMonospace ? 1 : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121)),
        ),
      ],
    );
  }

  Widget _buildTripTypeChip(String transactionType) {
    final isSingle = transactionType == 'single';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSingle
            ? Colors.blue.withValues(alpha: 0.1)
            : Colors.purple.withValues(alpha: 0.1),
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
    );
  }
}
