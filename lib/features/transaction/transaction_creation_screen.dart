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
    final vehicle = ModalRoute.of(context)!.settings.arguments as VehicleModel;

    return ChangeNotifierProvider(
      create: (_) => TransactionCreationViewModel(vehicle: vehicle),
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
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransactionCreationViewModel>(
        builder: (context, vm, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
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
                _buildSquadCoButton(vm, context),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(TransactionCreationViewModel vm) {
    final vehicle = vm.vehicle;
    return AppCard(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Transaction Summary'),
          const Divider(),
          DetailRow(
              label: 'License Plate',
              value: vehicle.vehicleLicense,
              isMonospace: true),
          const SizedBox(height: 6),
          DetailRow(label: 'Vehicle Type', value: vehicle.vehicleType),
          const SizedBox(height: 6),
          _buildTripTypeChip(vehicle.transactionType),
          const SizedBox(height: 12),
          DetailRow(label: 'Base Amount', value: '₦${vm.formattedBaseAmount}'),
          const SizedBox(height: 6),
          DetailRow(label: 'Convenience Fee', value: '₦${vm.formattedTotalFee}'),
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
          AppTextField(
            controller: vm.payerNameController,
            label: 'Payer Full Name *',
            hint: 'Enter payer full name',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: vm.payerPhoneController,
            label: 'Payer Phone *',
            hint: 'Enter 11-digit phone number',
            keyboardType: TextInputType.phone,
            maxLength: 11,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: vm.payerEmailController,
            label: 'Payer Email',
            hint: 'customer@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
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
            decoration: InputDecoration(
              labelText: 'Origin State *',
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: vm.states
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              if (v != null) vm.onOriginStateChanged(v);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: vm.selectedOriginLga,
            decoration: InputDecoration(
              labelText: 'Origin LGA *',
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: vm.originLgas
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged:
                vm.selectedOriginState == null ? null : vm.onOriginLgaChanged,
          ),
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
            decoration: InputDecoration(
              labelText: 'Destination State *',
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: vm.states
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              if (v != null) vm.onDestinationStateChanged(v);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: vm.selectedDestinationLga,
            decoration: InputDecoration(
              labelText: 'Destination LGA *',
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: vm.destinationLgas
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: vm.selectedDestinationState == null
                ? null
                : vm.onDestinationLgaChanged,
          ),
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
          if (!vm.hasPayloadCategories)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Loading categories...',
                  style: TextStyle(color: Colors.grey)),
            )
          else ...[
            DropdownButtonFormField<String>(
              value: vm.selectedPayloadCategory?['name']?.toString(),
              decoration: InputDecoration(
                labelText: 'Select Category *',
                isDense: true,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              isExpanded: true,
              items: vm.payloadCategories
                  .map((c) => DropdownMenuItem(
                        value: c['name']?.toString() ?? '',
                        child: Text(c['name']?.toString() ?? '',
                            overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                final cat = vm.payloadCategories
                    .cast<Map<String, dynamic>?>()
                    .firstWhere((c) => c?['name']?.toString() == v,
                        orElse: () => null);
                if (cat != null) vm.selectPayloadCategory(cat);
              },
            ),
            if (vm.selectedPayloadCategory != null &&
                vm.subCategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: vm.selectedSubCategory,
                decoration: InputDecoration(
                  labelText: 'Select Subcategory *',
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                isExpanded: true,
                items: vm.subCategories
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) vm.selectSubCategory(v);
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFeeSummaryCard(TransactionCreationViewModel vm) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  '₦${vm.formattedTotalPayable}',
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
    );
  }

  Widget _buildErrorBanner(TransactionCreationViewModel vm) {
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

  Widget _buildSquadCoButton(TransactionCreationViewModel vm, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: AppButton(
        label: vm.isSquadCoProceeding ? 'Proceeding...' : 'Confirm & Proceed With Squad',
        onPressed: (vm.isLoading || vm.isSquadCoProceeding)
            ? null
            : () => vm.proceedWithSquadCo(context),
        isLoading: vm.isSquadCoProceeding,
        icon: Icons.payment,
        color: Colors.indigo,
      ),
    );
  }

  Widget _buildTripTypeChip(String transactionType) {
    final isSingle = transactionType.toLowerCase().contains('single');
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
