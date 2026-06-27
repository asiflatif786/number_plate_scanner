import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../../data/models/transaction_model.dart';
import 'transaction_history_viewmodel.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_chip.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_state_widget.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * 0.8) {
      context.read<TransactionHistoryViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionHistoryViewModel()..loadTransactions(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          actions: [
            Consumer<TransactionHistoryViewModel>(
              builder: (context, vm, _) => IconButton(
                icon: vm.isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: vm.isRefreshing ? null : () => vm.onRefresh(),
              ),
            ),
          ],
        ),
        body: Consumer<TransactionHistoryViewModel>(
          builder: (context, vm, _) => Column(
            children: [
              _buildSearchBar(vm),
              _buildFilterChips(vm),
              _buildSummaryRow(vm),
              Expanded(child: _buildBody(vm)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(TransactionHistoryViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: AppTextField(
        label: '',
        hint: 'Search by reference, name or plate',
        controller: _searchController,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  vm.onSearchChanged('');
                },
              )
            : null,
        onChanged: vm.onSearchChanged,
        fillColor: Colors.grey.shade50,
        customPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
    );
  }

  Widget _buildFilterChips(TransactionHistoryViewModel vm) {
    final filters = <String?, String>{
      null: 'All',
      'pending': 'Pending',
      'approved': 'Approved',
      'declined': 'Declined',
    };
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: filters.entries.map((entry) {
          final value = entry.key;
          final label = entry.value;
          final selected = vm.selectedStatusFilter == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label, style: const TextStyle(fontSize: 12)),
              selected: selected,
              onSelected: (_) => vm.onStatusFilterChanged(value),
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: selected ? Theme.of(context).primaryColor : Colors.grey.shade300,
              ),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryRow(TransactionHistoryViewModel vm) {
    final count = vm.filteredTransactions.length;
    final total = vm.totalTransactions;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            'Showing $count transaction${count == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (vm.selectedStatusFilter != null)
            Text(
              ' • Filtered by: ${vm.selectedStatusFilter!.toUpperCase()}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          const Spacer(),
          if (total > 0)
            Text(
              '$total total',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(TransactionHistoryViewModel vm) {
    if (vm.isLoading) return _buildShimmerList();

    if (vm.errorMessage != null && vm.transactions.isEmpty) {
      return _buildErrorState(vm);
    }

    if (vm.transactions.isEmpty) {
      return _buildEmptyState(vm);
    }

    if (vm.filteredTransactions.isEmpty) {
      return _buildNoResultsState(vm);
    }

    return RefreshIndicator(
      onRefresh: vm.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: vm.filteredTransactions.length + 1,
        itemBuilder: (context, index) {
          if (index == vm.filteredTransactions.length) {
            return _buildPaginationFooter(vm);
          }
          return _buildTransactionCard(vm, vm.filteredTransactions[index]);
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return const ShimmerLoader(
      itemCount: 5,
      itemHeight: 120,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Widget _buildErrorState(TransactionHistoryViewModel vm) {
    return ErrorStateWidget(
      message: vm.errorMessage!,
      onRetry: () => vm.loadTransactions(refresh: true),
    );
  }

  Widget _buildEmptyState(TransactionHistoryViewModel vm) {
    final hasFilter = vm.selectedStatusFilter != null;
    return EmptyStateWidget(
      title: 'No transactions found',
      message: hasFilter
          ? 'No ${vm.selectedStatusFilter} transactions found. Try a different filter.'
          : 'No transactions yet. Process your first transaction to see it here.',
      icon: Icons.receipt_long,
    );
  }

  Widget _buildNoResultsState(TransactionHistoryViewModel vm) {
    return EmptyStateWidget(
      title: 'No results found',
      message: "No results for '${vm.searchQuery}'",
      icon: Icons.search_off,
    );
  }

  Widget _buildPaginationFooter(TransactionHistoryViewModel vm) {
    if (vm.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (vm.hasMorePages) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: AppButton(
          isOutlined: true,
          label: 'Load More',
          onPressed: () => vm.loadMore(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'All transactions loaded',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionHistoryViewModel vm, TransactionModel t) {
    final isVerifying = vm.verifyingReference == t.transactionReference;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        elevation: 1,
        borderRadius: 10,
        padding: EdgeInsets.zero,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: t.statusColor,
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _showDetailSheet(context, t, vm),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.transactionReference,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            StatusChip(status: t.status, fontSize: 10),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.customerName.isNotEmpty ? t.customerName : 'N/A',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              t.createdAt.isNotEmpty ? _formatDate(t.createdAt) : '',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.vehicleLicense.isNotEmpty ? t.vehicleLicense : 'N/A',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              t.formattedTotal,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildTripTypeChip(t.transactionType),
                            const SizedBox(width: 8),
                            Icon(
                              t.paymentMethod == 'card'
                                  ? Icons.credit_card
                                  : t.paymentMethod == 'wallet'
                                      ? Icons.account_balance_wallet
                                      : Icons.swap_horiz,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.paymentMethodDisplay,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            const Spacer(),
                            if (t.status == 'pending') ...[
                              _buildSmallActionButton(
                                label: 'Verify',
                                isLoading: isVerifying,
                                onTap: isVerifying
                                    ? null
                                    : () => vm.verifyTransaction(t.transactionReference),
                              ),
                              const SizedBox(width: 4),
                              _buildSmallActionButton(
                                label: 'Abandon',
                                isDestructive: true,
                                onTap: () => vm.abandonTransaction(t.transactionReference, context),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripTypeChip(String transactionType) {
    final isSingle = transactionType == 'single';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSingle
            ? Colors.blue.withOpacity(0.1)
            : Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isSingle ? 'Single' : 'Complete',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSingle ? Colors.blue : Colors.purple,
        ),
      ),
    );
  }

  Widget _buildSmallActionButton({
    required String label,
    bool isLoading = false,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 26,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          foregroundColor: isDestructive ? Colors.red : null,
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, TransactionModel t, TransactionHistoryViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _TransactionDetailSheet(
        transaction: t,
        viewModel: vm,
      ),
    );
  }

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('dd/MM/yy HH:mm').format(dt);
  }
}

class _TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  final TransactionHistoryViewModel viewModel;

  const _TransactionDetailSheet({
    required this.transaction,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Transaction Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReceipt(context, t),
            const SizedBox(height: 16),
            if (t.status == 'pending') ...[
              AppButton(
                isOutlined: true,
                label: 'Verify Status',
                icon: Icons.sync,
                onPressed: () {
                  Navigator.pop(context);
                  viewModel.verifyTransaction(t.transactionReference);
                },
                height: 44,
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceipt(BuildContext context, TransactionModel t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReceiptHeader(context, t),
            const Divider(),
            _buildInfoSection(context, t),
            const Divider(),
            _buildRouteSection(t),
            const Divider(),
            _buildPaymentBreakdown(t),
            const Divider(),
            _buildProcessedBy(t),
            const Divider(),
            _buildReceiptFooter(t.transactionReference),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader(BuildContext context, TransactionModel t) {
    return Row(
      children: [
        const Icon(Icons.receipt_long, size: 20, color: Color(0xFF1A237E)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('Transaction Receipt',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
        ),
        IconButton(
          icon: const Icon(Icons.print, size: 20, color: Colors.grey),
          onPressed: () => _showPrintOptions(context, viewModel, t),
        ),
        InkWell(
          onTap: () => _shareReceipt(context, t),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.share, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Share',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPrintOptions(BuildContext context, TransactionHistoryViewModel vm, TransactionModel t) {
    vm.getBluetoothDevices();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: vm,
        child: Consumer<TransactionHistoryViewModel>(
          builder: (context, vm, _) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Print Receipt',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (vm.isConnected)
                        const Chip(
                          label: Text('Connected', style: TextStyle(color: Colors.white, fontSize: 10)),
                          backgroundColor: Colors.green,
                        )
                      else
                        const Chip(
                          label: Text('Disconnected', style: TextStyle(color: Colors.white, fontSize: 10)),
                          backgroundColor: Colors.red,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!vm.isConnected) ...[
                    const Text('Select a printer to connect:'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: vm.devices.isEmpty
                          ? const Center(child: Text('No bonded devices found.'))
                          : ListView.builder(
                              itemCount: vm.devices.length,
                              itemBuilder: (context, index) {
                                final device = vm.devices[index];
                                return ListTile(
                                  leading: const Icon(Icons.print),
                                  title: Text(device.name ?? 'Unknown Device'),
                                  subtitle: Text(device.address ?? ''),
                                  onTap: () => vm.connectToDevice(device),
                                );
                              },
                            ),
                    ),
                  ] else ...[
                    const Text('Printer ready.'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: vm.isPrinting ? null : () {
                        vm.printReceipt(t);
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Confirm Print'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _shareReceipt(BuildContext context, TransactionModel t) {
    Share.share(
      _buildReceiptText(t),
      subject: 'Consolidated Haulage Levy Receipt - ${t.transactionReference}',
    );
  }

  String _buildReceiptText(TransactionModel t) {
    final sb = StringBuffer();
    sb.writeln('══════════════════════════════════════');
    sb.writeln('   CONSOLIDATED HAULAGE LEVY — RECEIPT');
    sb.writeln('══════════════════════════════════════');
    sb.writeln();
    sb.writeln('Transaction Ref:  ${t.transactionReference}');
    sb.writeln('Status:           ${t.status.toUpperCase()}');
    sb.writeln('Date:             ${t.createdAt}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('CUSTOMER DETAILS');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Name:             ${t.customerName}');
    sb.writeln('Vehicle:          ${t.vehicleLicense}');
    final tripType = t.transactionType == 'single' ? 'Single Trip' : 'Complete Trip';
    sb.writeln('Trip Type:        $tripType');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('ROUTE');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('From:  ${t.originLga}, ${t.originState}');
    sb.writeln('To:    ${t.destinationLga}, ${t.destinationState}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('PAYMENT');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Base Amount:      ${t.formattedAmount}');
    sb.writeln('Service Fee:      ${t.formattedServiceFee}');
    sb.writeln('Total Paid:       ${t.formattedTotal}');
    sb.writeln('Method:           ${t.paymentMethodDisplay}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('PROCESSED BY');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Agent:            ${t.agentNumber}');
    sb.writeln('Terminal:         ${t.terminalId}');
    sb.writeln('──────────────────────────────────────');
    sb.writeln();
    sb.writeln(' Thank you for using Consolidated Haulage Levy');
    return sb.toString();
  }

  Widget _buildInfoSection(BuildContext context, TransactionModel t) {
    return Column(
      children: [
        DetailRow(label: 'Transaction Ref', value: t.transactionReference, isSelectable: true),
        const SizedBox(height: 6),
        DetailRow(label: 'Date & Time', value: t.createdAt),
        const SizedBox(height: 6),
        _buildStatusRow(t),
        const SizedBox(height: 6),
        DetailRow(label: 'Customer Name', value: t.customerName),
        const SizedBox(height: 6),
        DetailRow(label: 'Vehicle Plate', value: t.vehicleLicense, isMonospace: true, isSelectable: true),
        const SizedBox(height: 6),
        _buildTripTypeRow(t.transactionType),
      ],
    );
  }

  Widget _buildRouteSection(TransactionModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Route', fontSize: 11),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(t.originLga,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                  Text(t.originState,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 20, color: Color(0xFF1A237E)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SelectableText(t.destinationLga,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
                  Text(t.destinationState,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdown(TransactionModel t) {
    return Column(
      children: [
        _buildFeeRow('Base Amount', t.formattedAmount),
        const SizedBox(height: 6),
        _buildFeeRow('Service Fee', t.formattedServiceFee),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(thickness: 1.5),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text('Total Paid',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
              ),
              SelectableText(
                t.formattedTotal,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _buildPaymentMethodRow(t),
      ],
    );
  }

  Widget _buildProcessedBy(TransactionModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Processed By', fontSize: 11),
        const SizedBox(height: 8),
        _buildSmallRow('Agent Number', t.agentNumber),
        const SizedBox(height: 4),
        _buildSmallRow('Terminal ID', t.terminalId),
      ],
    );
  }

  Widget _buildReceiptFooter(String reference) {
    final qrUrl = 'https://apidev.jrb-shf.com/validate-transaction?params=$reference';
    return Column(
      children: [
        Center(
          child: Text(
            '- - - - - - - - - - - - - - - -',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              QrImageView(
                data: qrUrl,
                version: QrVersions.auto,
                size: 80.0,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 4),
              const Text(
                'Scan to Validate',
                style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Thank you for using Consolidated Haulage Levy',
            style: TextStyle(
                fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(TransactionModel t) {
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text('Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        StatusChip(status: t.status, fontSize: 11),
      ],
    );
  }

  Widget _buildTripTypeRow(String transactionType) {
    final isSingle = transactionType == 'single';
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text('Trip Type', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: isSingle
                ? Colors.blue.withOpacity(0.1)
                : Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
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
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        SelectableText(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
      ],
    );
  }

  Widget _buildPaymentMethodRow(TransactionModel t) {
    IconData icon;
    switch (t.paymentMethod) {
      case 'card':
        icon = Icons.credit_card;
        break;
      case 'wallet':
        icon = Icons.account_balance_wallet;
        break;
      case 'transfer':
        icon = Icons.swap_horiz;
        break;
      default:
        icon = Icons.payment;
    }
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text('Payment Method', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(t.paymentMethodDisplay,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
      ],
    );
  }

  Widget _buildSmallRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ),
        Expanded(
          child: SelectableText(
            value.isEmpty ? 'N/A' : value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }
}
