import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/agent_model.dart';
import 'agent_detail_viewmodel.dart';

class AgentDetailScreen extends StatefulWidget {
  const AgentDetailScreen({super.key});

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  final Map<String, bool> _revealed = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgentDetailViewModel>().loadAgentHealth();
    });
  }

  void _toggleReveal(String key) {
    setState(() {
      _revealed[key] = !(_revealed[key] ?? false);
    });
  }

  String _maskField(String value, {int showLast = 4}) {
    if (value.length <= showLast) return value;
    return '${'*' * (value.length - showLast)}${value.substring(value.length - showLast)}';
  }

  @override
  Widget build(BuildContext context) {
    final agent = ModalRoute.of(context)!.settings.arguments as AgentModel;

    return ChangeNotifierProvider(
      create: (_) => AgentDetailViewModel(agent: agent),
      child: Consumer<AgentDetailViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Agent Details'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => vm.refreshAgent(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAgentHeader(vm),
              const SizedBox(height: 16),
              _buildPersonalInfo(vm.agent),
              const SizedBox(height: 12),
              _buildAddressInfo(vm.agent),
              const SizedBox(height: 12),
              _buildIdentityVerification(vm.agent),
              const SizedBox(height: 12),
              _buildBankingDetails(vm.agent),
              const SizedBox(height: 12),
              _buildCompanyAssociation(vm.agent),
              if (vm.kycComplete == false) ...[
                const SizedBox(height: 12),
                _buildKycWarning(vm),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgentHeader(AgentDetailViewModel vm) {
    final agent = vm.agent;
    final initials = agent.firstName.isNotEmpty && agent.lastName.isNotEmpty
        ? '${agent.firstName[0]}${agent.lastName[0]}'
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            agent.fullName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            agent.agentNumber,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'monospace'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (vm.isLoadingStatus)
                ShimmerField(height: 24, width: 80)
              else
                StatusChip(status: vm.agentStatus ?? 'Unknown'),
              const SizedBox(width: 12),
              if (vm.isLoadingStatus)
                ShimmerField(height: 24, width: 100)
              else
                _buildKycChip(vm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKycChip(AgentDetailViewModel vm) {
    if (vm.isLoadingStatus) {
      return const ShimmerField(height: 24, width: 100);
    }
    final complete = vm.kycComplete == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (complete ? Colors.green : Colors.amber).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        complete ? 'KYC Complete' : 'KYC Pending',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: complete ? Colors.green : Colors.amber.shade800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    Color? accentColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: accentColor ?? const Color(0xFF1A237E),
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12)),
            ),
          ),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: title, fontSize: 13),
                  const Divider(),
                  ...children,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _maskedRow(String label, String value, String key) {
    final revealed = _revealed[key] ?? false;
    final display = revealed ? value : _maskField(value);
    return DetailRow(
      label: label,
      value: display,
      isMonospace: true,
      trailingIcon: revealed ? Icons.visibility_off : Icons.visibility,
      onTrailingTap: () => _toggleReveal(key),
    );
  }

  Widget _buildPersonalInfo(AgentModel a) {
    return _buildSectionCard(
      title: 'PERSONAL INFORMATION',
      children: [
        DetailRow(label: 'Title', value: a.title),
        DetailRow(label: 'Full Name', value: a.fullName),
        DetailRow(label: 'Gender', value: a.gender),
        DetailRow(label: 'Date of Birth', value: a.dateOfBirth),
        DetailRow(label: 'Marital Status', value: a.maritalStatus),
        DetailRow(label: 'Nationality', value: a.nationality),
        DetailRow(label: 'Phone Number', value: a.phoneNumber),
        DetailRow(label: 'Email', value: a.email),
      ],
    );
  }

  Widget _buildAddressInfo(AgentModel a) {
    return _buildSectionCard(
      title: 'ADDRESS',
      accentColor: Colors.teal,
      children: [
        DetailRow(label: 'Residential Address', value: a.address),
        DetailRow(label: 'City', value: a.city),
        DetailRow(label: 'State', value: a.state),
        DetailRow(label: 'LGA', value: a.lga),
        DetailRow(label: 'State of Origin', value: a.stateOfOrigin),
        DetailRow(label: 'LGA of Origin', value: a.lgaOfOrigin),
      ],
    );
  }

  Widget _buildIdentityVerification(AgentModel a) {
    return _buildSectionCard(
      title: 'IDENTITY & VERIFICATION',
      accentColor: Colors.orange,
      children: [
        _maskedRow('BVN', a.bvn, 'bvn'),
        _maskedRow('NIN', a.nin, 'nin'),
        DetailRow(label: 'ID Type', value: a.idType),
        DetailRow(label: 'Identity Number', value: a.identityNumber),
        DetailRow(label: 'TIN', value: a.tin ?? 'N/A'),
      ],
    );
  }

  Widget _buildBankingDetails(AgentModel a) {
    final accountKey = 'account_${a.accountNumber}';
    final revealed = _revealed[accountKey] ?? false;
    return _buildSectionCard(
      title: 'BANKING DETAILS',
      accentColor: Colors.green,
      children: [
        DetailRow(label: 'Bank Name', value: a.bankName),
        DetailRow(
          label: 'Account Number',
          value: revealed ? a.accountNumber : _maskField(a.accountNumber),
          trailingIcon: revealed ? Icons.visibility_off : Icons.visibility,
          onTrailingTap: () => _toggleReveal(accountKey),
        ),
        DetailRow(label: 'Account Name', value: a.accountName),
        DetailRow(label: 'Sort Code', value: a.sortCode ?? 'N/A'),
      ],
    );
  }

  Widget _buildCompanyAssociation(AgentModel a) {
    return _buildSectionCard(
      title: 'COMPANY ASSOCIATION',
      accentColor: Colors.purple,
      children: [
        DetailRow(label: 'Company Number', value: a.companyNumber),
        DetailRow(
          label: 'Agent Number',
          value: a.agentNumber,
          isMonospace: true,
          isSelectable: true,
          trailingIcon: Icons.copy,
          onTrailingTap: () {
            Clipboard.setData(ClipboardData(text: a.agentNumber));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Agent number copied to clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildKycWarning(AgentDetailViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KYC verification is incomplete for this agent. They may be unable to process transactions.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5D4037)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contact: technology@cyber1systemsnetwork.com',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
