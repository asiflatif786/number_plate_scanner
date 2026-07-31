import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/vehicle_model.dart';
import 'transaction_creation_viewmodel.dart';

class TransactionCreationScreen extends StatelessWidget {
  const TransactionCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    
    VehicleModel vehicle;
    bool hasPenalty = false;
    double penaltyAmount = 0.0;
    String? paymentType;

    if (args is VehicleModel) {
      vehicle = args;
    } else if (args is Map<String, dynamic>) {
      vehicle = args['vehicle'] as VehicleModel;
      hasPenalty = args['hasPenalty'] as bool? ?? false;
      penaltyAmount = (args['penaltyAmount'] as num?)?.toDouble() ?? 0.0;
      paymentType = args['paymentType'] as String?;
    } else {
      return const Scaffold(body: Center(child: Text('Invalid Arguments')));
    }

    return ChangeNotifierProvider(
      create: (_) => TransactionCreationViewModel(
        vehicle: vehicle,
        hasPenalty: hasPenalty,
        penaltyAmount: penaltyAmount,
        paymentType: paymentType,
      ),
      child: const _TransactionCreationBody(),
    );
  }
}

class _TransactionCreationBody extends StatelessWidget {
  const _TransactionCreationBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Transaction'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionCreationViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                if (vm.paymentType != null) ...[
                  _buildPaymentTypeHeader(vm.paymentType!),
                  const SizedBox(height: 12),
                ],
                _buildSummaryCard(vm),
                const SizedBox(height: 12),
                _buildPayerInfoCard(vm),
                const SizedBox(height: 12),
                _buildOriginCard(vm),
                const SizedBox(height: 12),
                _buildDestinationCard(vm),
                const SizedBox(height: 12),
                if (!vm.isCompleteTrip) ...[
                  _buildPayloadCategoryCard(vm),
                  const SizedBox(height: 12),
                ],
                _buildFeeSummaryCard(vm),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorBanner(vm),
                ],
                const SizedBox(height: 24),
                if (vm.hasPenalty)
                  _buildSquadCoButton(vm, context)
                else
                  _buildStandardProceedButton(vm, context),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentTypeHeader(String type) {
    String label = 'CHL Payment';
    Color color = const Color(0xFF1A237E);
    
    if (type == 'chl-inter') {
      label = 'CHL - Inter State';
    } else if (type == 'chl-intra') {
      label = 'CHL - Intra State';
      color = Colors.green.shade700;
    } else if (type == 'penalty-inter') {
      label = 'Inter-State Penalty';
      color = Colors.red.shade700;
    } else if (type == 'penalty-intra') {
      label = 'Intra-State Penalty';
      color = Colors.orange.shade800;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            'Processing: $label',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(TransactionCreationViewModel vm) {
    final vehicle = vm.vehicle;
    final modeLabel = vm.transactionMode == TransactionMode.intraState ? 'Intra-State' : 'Inter-State';
    
    return AppCard(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Transaction Summary'),
          const Divider(),
          DetailRow(label: 'License Plate', value: vehicle.vehicleLicense, isMonospace: true),
          const SizedBox(height: 6),
          DetailRow(label: 'Vehicle Type', value: vehicle.vehicleType),
          const SizedBox(height: 6),
          DetailRow(
            label: 'Transaction Type', 
            value: modeLabel, 
            valueColor: Colors.indigo, 
            fontWeight: FontWeight.bold
          ),
          const SizedBox(height: 12),
          DetailRow(label: 'Base Amount', value: '₦${vm.formattedBaseAmount}'),
          const SizedBox(height: 6),
          DetailRow(label: 'Convenience Fee', value: '₦${vm.formattedTotalFee}'),
          if (vm.hasPenalty) ...[
            const SizedBox(height: 6),
            DetailRow(label: 'Penalty (50%)', value: '₦${vm.formattedPenaltyAmount}', valueColor: Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildPayerInfoCard(TransactionCreationViewModel vm) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Payer Information'),
          const Divider(),
          AppTextField(controller: vm.payerNameController, label: 'Payer Full Name *', hint: 'Enter payer full name', textCapitalization: TextCapitalization.words),
          const SizedBox(height: 12),
          AppTextField(controller: vm.payerPhoneController, label: 'Payer Phone *', hint: 'Enter 11-digit phone number', keyboardType: TextInputType.phone, maxLength: 11),
          const SizedBox(height: 12),
          AppTextField(controller: vm.payerEmailController, label: 'Payer Email', hint: 'customer@example.com', keyboardType: TextInputType.emailAddress),
        ],
      ),
    );
  }

  Widget _buildOriginCard(TransactionCreationViewModel vm) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Trip Origin'),
          const Divider(),
          DropdownButtonFormField<String>(
            value: vm.selectedOriginState,
            decoration: InputDecoration(labelText: 'Origin State *', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            items: vm.states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (vm.transactionMode == TransactionMode.intraState && vm.assignedState != null) ? null : (v) { if (v != null) vm.onOriginStateChanged(v); },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: vm.selectedOriginLga,
            decoration: InputDecoration(labelText: 'Origin LGA *', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            items: vm.originLgas.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: vm.selectedOriginState == null ? null : vm.onOriginLgaChanged,
          ),
          if (vm.transactionMode == TransactionMode.intraState) ...[
            const SizedBox(height: 12),
            AppTextField(controller: vm.departureTownController, label: 'Departure Town *', hint: 'Enter town name'),
          ],
        ],
      ),
    );
  }

  Widget _buildDestinationCard(TransactionCreationViewModel vm) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Trip Destination'),
          const Divider(),
          DropdownButtonFormField<String>(
            value: vm.selectedDestinationState,
            decoration: InputDecoration(labelText: 'Destination State *', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            items: vm.states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (vm.transactionMode == TransactionMode.intraState && vm.assignedState != null) ? null : (v) { if (v != null) vm.onDestinationStateChanged(v); },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: vm.selectedDestinationLga,
            decoration: InputDecoration(labelText: 'Destination LGA *', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            items: vm.destinationLgas.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: vm.selectedDestinationState == null ? null : vm.onDestinationLgaChanged,
          ),
          if (vm.transactionMode == TransactionMode.intraState) ...[
            const SizedBox(height: 12),
            AppTextField(controller: vm.destinationTownController, label: 'Destination Town *', hint: 'Enter town name'),
          ],
        ],
      ),
    );
  }

  Widget _buildPayloadCategoryCard(TransactionCreationViewModel vm) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Payload Category'),
          const Divider(),
          if (!vm.hasPayloadCategories) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Loading categories...', style: TextStyle(color: Colors.grey)))
          else ...[
            DropdownButtonFormField<String>(
              value: vm.selectedPayloadCategory?['name']?.toString(),
              decoration: InputDecoration(labelText: 'Select Category *', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              isExpanded: true,
              items: vm.payloadCategories.map((c) => DropdownMenuItem(value: c['name']?.toString() ?? '', child: Text(c['name']?.toString() ?? '', overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) {
                if (v == null) return;
                final cat = vm.payloadCategories.cast<Map<String, dynamic>?>().firstWhere((c) => c?['name']?.toString() == v, orElse: () => null);
                if (cat != null) vm.selectPayloadCategory(cat);
              },
            ),
            if (vm.selectedPayloadCategory != null && vm.subCategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: vm.selectedSubCategory,
                decoration: InputDecoration(labelText: 'Select Subcategory *', isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                isExpanded: true,
                items: vm.subCategories.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) { if (v != null) vm.selectSubCategory(v); },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFeeSummaryCard(TransactionCreationViewModel vm) {
    return AppCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(color: const Color(0xFF1A237E).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: Text('Total Payable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)))),
                Text('₦${vm.formattedTotalPayable}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              ],
            ),
            if (vm.hasPenalty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Text('(Includes ₦${vm.formattedPenaltyAmount} Penalty)', style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500))],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(TransactionCreationViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 20, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(vm.errorMessage!, style: TextStyle(fontSize: 13, color: Colors.red.shade800))),
          InkWell(onTap: vm.clearError, child: Icon(Icons.close, size: 18, color: Colors.red.shade400)),
        ],
      ),
    );
  }

  Widget _buildSquadCoButton(TransactionCreationViewModel vm, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: AppButton(
        label: vm.isSquadCoProceeding ? 'Proceeding...' : 'Confirm & Proceed With Squad',
        onPressed: (vm.isLoading || vm.isSquadCoProceeding) ? null : () => vm.proceedWithSquadCo(context),
        isLoading: vm.isSquadCoProceeding,
        icon: Icons.payment,
        color: Colors.indigo,
      ),
    );
  }

  Widget _buildStandardProceedButton(TransactionCreationViewModel vm, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: AppButton(
        label: vm.isLoading ? 'Processing...' : 'Confirm & Generate Invoice',
        onPressed: (vm.isLoading || vm.isSquadCoProceeding) ? null : () => vm.proceedWithStandardPayment(context),
        isLoading: vm.isLoading,
        icon: Icons.check_circle,
        color: Colors.green.shade700,
      ),
    );
  }
}
