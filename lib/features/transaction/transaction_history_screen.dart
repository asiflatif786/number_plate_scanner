import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'transaction_history_viewmodel.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionHistoryViewModel()..loadInitial(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          actions: [
            Consumer<TransactionHistoryViewModel>(
              builder: (context, vm, _) => IconButton(
                icon: Badge(
                  isLabelVisible: vm.selectedStatus != null ||
                      vm.startDate != null,
                  child: const Icon(Icons.filter_list),
                ),
                tooltip: 'Filters',
                onPressed: () => _showFilterSheet(context, vm),
              ),
            ),
          ],
        ),
        body: Consumer<TransactionHistoryViewModel>(
          builder: (context, vm, _) => Column(
            children: [
              _buildSearchBar(vm),
              if (vm.selectedStatus != null || vm.startDate != null)
                _buildActiveFilterBar(vm),
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search plate or customer name...',
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
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: vm.onSearchChanged,
      ),
    );
  }

  Widget _buildActiveFilterBar(TransactionHistoryViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          if (vm.selectedStatus != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(
                label: Text(
                  vm.selectedStatus!.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => vm.onStatusFilterChanged(null),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          if (vm.startDate != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Chip(
                label: Text(
                  '${_formatShort(vm.startDate!)} - ${vm.endDate != null ? _formatShort(vm.endDate!) : ''}',
                  style: const TextStyle(fontSize: 11),
                ),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => vm.onDateRangeChanged(null, null),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          const Spacer(),
          InkWell(
            onTap: () {
              _searchController.clear();
              vm.clearFilters();
            },
            child: const Text('Clear All',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TransactionHistoryViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.allTransactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(vm.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => vm.loadInitial(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (vm.allTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No transactions yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            const Text(
              'Completed transactions will appear here',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (vm.filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No transactions match your filters',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
            const SizedBox(height: 4),
            const Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSummaryHeader(vm),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => vm.refresh(),
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: vm.filteredTransactions.length,
              itemBuilder: (context, index) =>
                  _buildTransactionItem(vm, vm.filteredTransactions[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(TransactionHistoryViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        'Showing ${vm.filteredTransactions.length} of ${vm.allTransactions.length} transactions',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      TransactionHistoryViewModel vm, dynamic t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => vm.onTransactionTapped(context, t),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: t.statusColor,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(10)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.customerName.isNotEmpty
                                    ? t.customerName
                                    : 'N/A',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121),
                                ),
                                overflow: TextOverflow.ellipsis,
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.vehicleLicense.isNotEmpty
                                    ? t.vehicleLicense
                                    : 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            _buildSmallStatusChip(t.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${t.originLga} \u2192 ${t.destinationLga}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.sync, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                              tooltip: 'Verify Status',
                              onPressed: () =>
                                  vm.verifyStatus(context, t),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStatusChip(String status) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status == 'approved'
            ? Colors.green.shade50
            : status == 'pending'
                ? Colors.amber.shade50
                : status == 'declined'
                    ? Colors.red.shade50
                    : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: status == 'approved'
              ? Colors.green
              : status == 'pending'
                  ? Colors.amber.shade800
                  : status == 'declined'
                      ? Colors.red
                      : Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showFilterSheet(
      BuildContext context, TransactionHistoryViewModel vm) {
    DateTime? tempStart = vm.startDate;
    DateTime? tempEnd = vm.endDate;
    String? tempStatus = vm.selectedStatus;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom:
                  MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Transactions',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Status',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                      'All',
                      tempStatus == null,
                      Colors.grey,
                      () => setSheetState(
                          () => tempStatus = null),
                    ),
                    _buildFilterChip(
                      'Approved',
                      tempStatus == 'approved',
                      Colors.green,
                      () => setSheetState(() =>
                          tempStatus = 'approved'),
                    ),
                    _buildFilterChip(
                      'Pending',
                      tempStatus == 'pending',
                      Colors.amber,
                      () => setSheetState(() =>
                          tempStatus = 'pending'),
                    ),
                    _buildFilterChip(
                      'Declined',
                      tempStatus == 'declined',
                      Colors.red,
                      () => setSheetState(() =>
                          tempStatus = 'declined'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Date Range',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        ctx,
                        'From',
                        tempStart,
                        (d) =>
                            setSheetState(() => tempStart = d),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        ctx,
                        'To',
                        tempEnd,
                        (d) =>
                            setSheetState(() => tempEnd = d),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempStatus = null;
                            tempStart = null;
                            tempEnd = null;
                          });
                        },
                        child: const Text('Clear Filters'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          vm.onStatusFilterChanged(tempStatus);
                          vm.onDateRangeChanged(
                              tempStart, tempEnd);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    bool selected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? color : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? value,
    ValueChanged<DateTime> onSelected,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate:
              DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              value != null
                  ? _formatShort(value)
                  : label,
              style: TextStyle(
                fontSize: 13,
                color: value != null
                    ? const Color(0xFF212121)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
