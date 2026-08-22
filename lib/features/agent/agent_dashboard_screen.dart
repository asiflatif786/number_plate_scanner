import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/section_header.dart';
import 'agent_dashboard_viewmodel.dart';

class AgentDashboardScreen extends StatefulWidget {
  const AgentDashboardScreen({super.key});

  @override
  State<AgentDashboardScreen> createState() => _AgentDashboardScreenState();
}

class _AgentDashboardScreenState extends State<AgentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentDashboardViewModel>().loadSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: _buildAppBar(),
        body: Consumer<AgentDashboardViewModel>(
          builder: (context, vm, _) {
            return RefreshIndicator(
              onRefresh: vm.refresh,
              color: const Color(0xFF1A237E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildWelcomeBanner(vm),
                    _buildQuickActions(vm),
                    _buildTodayActivity(vm),
                    _buildTerminalInfo(vm),
                    _buildPaymentBankDetails(vm),
                    _buildFooter(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A237E),
      automaticallyImplyLeading: false,
      title: const Text('Consolidated Haulage Levy',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.notifications),
        ),
        Consumer<AgentDashboardViewModel>(
          builder: (context, vm, _) => IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () => vm.logout(context),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner(AgentDashboardViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${vm.greeting},',
                  style: const TextStyle(fontSize: 14, color: Colors.white70)),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('CHL',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(vm.agentFullName,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text('Agent: ${vm.agentNumber}',
              style: const TextStyle(fontSize: 13, color: Colors.white60)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Wallet Balance',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 2),
                  Text(vm.formattedWalletBalance,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
              if (vm.isRefreshing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white70),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _chip(Icons.terminal, vm.terminalId),
              const SizedBox(width: 8),
              _chip(Icons.business, vm.companyNumber),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(vm.currentDate,
                style: const TextStyle(fontSize: 11, color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AgentDashboardViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121))),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => vm.navigateToVehicleSearch(context),
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text(
                    'Pay For Trips',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.walletTransactions),
                  icon: const Icon(Icons.history, color: Colors.white),
                  label: const Text(
                    'All Transaction',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayActivity(AgentDashboardViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Statistics",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121))),
              if (vm.isRefreshing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _statItem('Total', vm.totalTransactions.toString(), isFirst: true),
                _statItem('Approved', vm.approvedCount.toString()),
                _statItem('Pending', vm.pendingCount.toString()),
                _statItem('Declined', vm.declinedCount.toString(), isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pull down to refresh',
            style: TextStyle(fontSize: 11, color: Color(0xFFBDBDBD)),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String count,
      {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: (isFirst || isLast)
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFF0F0F0), width: 1),
            right: (isLast)
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: Column(
          children: [
            Text(count,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E))),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalInfo(AgentDashboardViewModel vm) {
    final notConfigured = vm.terminalId == 'N/A' || vm.terminalId.isEmpty;
    final isActive = vm.terminalStatus.toLowerCase() == 'active';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Terminal Details',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121))),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _infoRow('Terminal ID', vm.terminalId, notConfigured),
                const Divider(height: 16),
                _infoRow('Serial Number', vm.serialNumber, notConfigured),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF2E7D32).withAlpha(26)
                            : const Color(0xFFF57C00).withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        vm.terminalStatus.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFF57C00),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBankDetails(AgentDashboardViewModel vm) {
    if (vm.isBankLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!vm.hasBankDetails && vm.agentWalletNumber.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment System Details',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121))),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                ),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'PAYMENT SYSTEM STATUS', fontSize: 13),
                        const Divider(),
                        DetailRow(
                          label: 'Status',
                          value: vm.paymentStatus,
                          valueColor: vm.paymentStatus == 'ACTIVE' ? Colors.green : Colors.red,
                        ),
                        if (vm.agentWalletNumber.isNotEmpty)
                          DetailRow(
                            label: 'Wallet Number',
                            value: vm.agentWalletNumber,
                            isMonospace: true,
                            trailingIcon: Icons.copy,
                            onTrailingTap: () {
                              Clipboard.setData(ClipboardData(text: vm.agentWalletNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Wallet number copied to clipboard')),
                              );
                            },
                          ),
                        if (vm.hasBankDetails) ...[
                          DetailRow(
                            label: 'Account Number',
                            value: vm.accountNumber,
                            isMonospace: true,
                            trailingIcon: Icons.copy,
                            onTrailingTap: () {
                              Clipboard.setData(ClipboardData(text: vm.accountNumber));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Account number copied to clipboard')),
                              );
                            },
                          ),
                          DetailRow(
                            label: 'Bank',
                            value: vm.bankName,
                          ),
                          DetailRow(
                            label: 'Account Name',
                            value: vm.accountName,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this account for wallet funding via bank transfer.',
            style: TextStyle(fontSize: 11, color: Color(0xFF757575), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isFallback) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: isFallback
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF212121),
            )),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: const Column(
        children: [
          Text('Consolidated Haulage Levy v1.0.0',
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          SizedBox(height: 2),
          Text('Powered by Cyber1 Systems',
              style: TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
        ],
      ),
    );
  }
}
