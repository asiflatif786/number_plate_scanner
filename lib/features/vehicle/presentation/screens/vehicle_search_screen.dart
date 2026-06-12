import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../transaction/presentation/viewmodels/transaction_viewmodel.dart';
import '../viewmodels/vehicle_search_viewmodel.dart';
import '../widgets/vehicle_found_card.dart';
import '../widgets/vehicle_not_found_card.dart';

class VehicleSearchScreen extends StatefulWidget {
  final String? initialLicensePlate;

  const VehicleSearchScreen({super.key, this.initialLicensePlate});

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  static const String _tag = 'VehicleSearchScreen';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_uppercaseListener);
    _handleInitialPlate();
  }

  void _handleInitialPlate() {
    final searchController = _searchController;
    final viewmodel = context.read<VehicleSearchViewModel>();
    final initialPlate = widget.initialLicensePlate;
    if (initialPlate != null && initialPlate.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchController.text = initialPlate;
        Future.delayed(const Duration(milliseconds: 500), () {
          viewmodel.searchVehicle(initialPlate);
        });
        AppLogger.info(_tag,
            'Auto-search triggered for: $initialPlate');
      });
    }
  }

  void _uppercaseListener() {
    final text = _searchController.text;
    final uppercase = text.toUpperCase();
    if (uppercase != text) {
      _searchController.value = TextEditingValue(
        text: uppercase,
        selection: TextSelection.collapsed(offset: uppercase.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_uppercaseListener);
    _searchController.dispose();
    super.dispose();
  }

  void _showAgentInfo(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final companyNumber = prefs.getString(AppConstants.companyNumberKey) ?? 'N/A';
    final agentNumber = prefs.getString(AppConstants.agentNumberKey) ?? 'N/A';
    final terminalId = prefs.getString(AppConstants.terminalIdKey) ?? 'N/A';

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Info',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(ctx, Icons.business, 'Company No.', companyNumber),
            const SizedBox(height: 12),
            _buildInfoRow(ctx, Icons.person, 'Agent No.', agentNumber),
            const SizedBox(height: 12),
            _buildInfoRow(ctx, Icons.point_of_sale, 'Terminal ID', terminalId),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final confirmed = await CustomDialog.showConfirm(
                    context,
                    title: 'Re-onboard?',
                    message:
                        'Are you sure? This will clear saved credentials.',
                  );
                  if (confirmed && context.mounted) {
                    final p = await SharedPreferences.getInstance();
                    await p.remove(AppConstants.companyNumberKey);
                    await p.remove(AppConstants.agentNumberKey);
                    await p.remove(AppConstants.terminalIdKey);
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(
                          context, '/corporate-registration');
                    }
                  }
                },
                child: const Text(
                  'Re-onboard',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A237E)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E))),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () =>
              ClipboardHelper.copyToClipboard(context, value, label),
          child: const Icon(Icons.copy, size: 18, color: Color(0xFF0288D1)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleSearchViewModel>(
      builder: (context, viewmodel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Vehicle Lookup'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  AppLogger.info(_tag, 'Navigate to transaction history');
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => _showAgentInfo(context),
              ),
            ],
          ),
          body: ResponsiveHelper.isTablet(context)
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      children: [
                        _buildSearchSection(viewmodel),
                        Expanded(child: _buildResultArea(viewmodel)),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildSearchSection(viewmodel),
                    Expanded(child: _buildResultArea(viewmodel)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSearchSection(VehicleSearchViewModel viewmodel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Vehicle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter license plate to look up vehicle details',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter license plate (e.g. BAL31XA)',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A237E)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          viewmodel.clearSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF1A237E), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _performSearch(viewmodel),
            ),
            const SizedBox(height: 16),
            _buildTripTypeToggle(viewmodel),
            const SizedBox(height: 16),
            _buildSearchButton(viewmodel),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeToggle(VehicleSearchViewModel viewmodel) {
    return Row(
      children: [
        const Text('Trip Type:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        Expanded(
          child: Tooltip(
            message: 'One-way trip (origin only)',
            child: _toggleButton(
              label: 'Single Trip',
              isSelected: viewmodel.selectedTransactionType == 'single',
              onTap: () => viewmodel.setTransactionType('single'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Tooltip(
            message: 'Round trip (origin + destination)',
            child: _toggleButton(
              label: 'Complete Trip',
              isSelected: viewmodel.selectedTransactionType == 'complete',
              onTap: () => viewmodel.setTransactionType('complete'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A237E) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A237E) : const Color(0xFF1A237E),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF1A237E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(VehicleSearchViewModel viewmodel) {
    final isEmpty = _searchController.text.trim().isEmpty;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed:
                (isEmpty || viewmodel.isLoading) ? null : () => _performSearch(viewmodel),
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text('Search Vehicle',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF1A237E).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _performSearch(VehicleSearchViewModel viewmodel) {
    final text = _searchController.text.trim();
    if (text.isEmpty) return;
    viewmodel.searchVehicle(text);
  }

  Widget _buildResultArea(VehicleSearchViewModel viewmodel) {
    if (viewmodel.isLoading) {
      return _buildLoadingState();
    }

    if (viewmodel.errorMessage != null) {
      return _buildErrorState(viewmodel);
    }

    if (viewmodel.isSearched && viewmodel.foundVehicle != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            VehicleFoundCard(
              vehicle: viewmodel.foundVehicle!,
              onProceed: () {
                AppLogger.info(_tag, 'Proceed to payment');
                final vehicle = viewmodel.foundVehicle!;
                final txnVm = context.read<TransactionViewModel>();
                txnVm.setVehicleDetails(
                  license: vehicle.vehicleLicense,
                  type: vehicle.vehicleType,
                  price: vehicle.price,
                  name: vehicle.priceName,
                  priceType: vehicle.priceType,
                  issuingState: vehicle.issuingState,
                  enumeratingState: vehicle.enumeratingState,
                  enumeratingLga: vehicle.enumeratingLga,
                );
                Navigator.pushNamed(context, '/transaction');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    if (viewmodel.vehicleNotFound) {
      return SingleChildScrollView(
        child: Column(
          children: [
            VehicleNotFoundCard(
              licensePlate: viewmodel.searchedLicense ?? '',
              onRegister: () {
                AppLogger.info(_tag, 'Navigate to vehicle registration');
                Navigator.pushNamed(
                  context,
                  '/vehicle-registration',
                  arguments: {
                    'licensePlate': viewmodel.searchedLicense ?? '',
                  },
                );
              },
              onSearchAgain: () {
                AppLogger.info(_tag, 'Search again');
                viewmodel.clearSearch();
                _searchController.clear();
                FocusScope.of(context).requestFocus(
                  FocusNode(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return _buildInitialState();
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_car, size: 80, color: Color(0xFFBDBDBD)),
          SizedBox(height: 16),
          Text(
            'Search for a vehicle',
            style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
          ),
          SizedBox(height: 8),
          Text(
            'Enter a license plate number above to get started',
            style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitFadingCircle(color: Color(0xFF1A237E), size: 50),
          SizedBox(height: 16),
          Text(
            'Looking up vehicle...',
            style: TextStyle(fontSize: 14, color: Color(0xFF1A237E)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VehicleSearchViewModel viewmodel) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Color(0xFFC62828)),
          const SizedBox(height: 12),
          const Text(
            'Search Failed',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              viewmodel.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              viewmodel.clearSearch();
              _searchController.clear();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
