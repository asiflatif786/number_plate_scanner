import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import 'vehicle_search_viewmodel.dart';

class VehicleSearchScreen extends StatefulWidget {
  const VehicleSearchScreen({super.key});

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VehicleSearchViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text('Vehicle Search'),
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<VehicleSearchViewModel>(
          builder: (context, vm, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildPlateField(vm),
                  const SizedBox(height: 16),
                  _buildScanButton(vm),
                  const SizedBox(height: 28),
                  _buildTripTypeSection(vm),
                  const SizedBox(height: 16),
                  _buildErrorBanner(vm),
                  const SizedBox(height: 16),
                  _buildSearchButton(vm),
                ],
              ),
            );
          },
        ),
      ),
    ),
   );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              size: 20, color: Color(0xFF1565C0)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Enter the vehicle license plate number or use the scanner to capture it automatically',
              style: TextStyle(fontSize: 13, color: Color(0xFF1565C0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlateField(VehicleSearchViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('License Plate Number',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: vm.licensePlateController,
          focusNode: _focusNode,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 3,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. BAL31XA',
            hintStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 3,
              color: const Color(0xFFBDBDBD).withValues(alpha: 0.5),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner,
                  color: Color(0xFF1A237E)),
              onPressed: () => vm.navigateToScanner(context),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
          ),
          onFieldSubmitted: (_) => vm.search(context),
        ),
      ],
    );
  }

  Widget _buildScanButton(VehicleSearchViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: vm.isLoading
            ? null
            : () => vm.navigateToScanner(context),
        icon: const Icon(Icons.document_scanner),
        label: const Text('Scan Number Plate'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A237E),
          side: const BorderSide(color: Color(0xFF1A237E)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTripTypeSection(VehicleSearchViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trip Type',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _tripTypeCard(
                icon: Icons.arrow_forward,
                title: 'Single Trip',
                subtitle: 'One-way journey',
                isSelected: vm.selectedTransactionType ==
                    ApiConstants.transactionTypeSingle,
                onTap: () => vm.onTransactionTypeChanged(
                    ApiConstants.transactionTypeSingle),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _tripTypeCard(
                icon: Icons.swap_horiz,
                title: 'Complete Trip',
                subtitle: 'Round trip / full journey',
                isSelected: vm.selectedTransactionType ==
                    ApiConstants.transactionTypeComplete,
                onTap: () => vm.onTransactionTypeChanged(
                    ApiConstants.transactionTypeComplete),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tripTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A237E).withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A237E)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color: isSelected
                    ? const Color(0xFF1A237E)
                    : const Color(0xFF9E9E9E)),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF1A237E)
                        : const Color(0xFF616161))),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(VehicleSearchViewModel vm) {
    if (vm.errorMessage == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFFC62828).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC62828), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(vm.errorMessage!,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFC62828))),
          ),
          GestureDetector(
            onTap: vm.clearError,
            child: const Icon(Icons.close, color: Color(0xFFC62828), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(VehicleSearchViewModel vm) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: vm.isLoading ? null : () => vm.search(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF1A237E).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: vm.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Search Vehicle',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
