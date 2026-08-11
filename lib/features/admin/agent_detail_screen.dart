import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/detail_row.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/shimmer_loader.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/agent_model.dart';
import 'add_bank_account_viewmodel.dart';
import 'agent_detail_viewmodel.dart';

class AgentDetailScreen extends StatefulWidget {
  final AgentModel agent;
  const AgentDetailScreen({super.key, required this.agent});

  @override
  State<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends State<AgentDetailScreen> {
  final Map<String, bool> _revealed = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AgentDetailViewModel>();
      vm.loadAgentHealth();
      vm.loadTerminalDetails();
      vm.checkAgentExistence();
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

  void _handleMapAgentToCompany(BuildContext context) async {
    final vm = context.read<AgentDetailViewModel>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await vm.mapAgentToCompany();
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.successMessage ?? 'Agent mapped to company successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh detail view
        vm.loadTerminalDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Failed to map agent to company'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAddAgentToPayment(BuildContext context, AgentModel agent) async {
    final vm = context.read<AddBankAccountViewModel>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Prepare data as requested
    final Map<String, dynamic> payload = {
      'title': agent.title,
      'first_name': agent.firstName,
      'last_name': agent.lastName,
      'gender': agent.gender,
      'marital_status': agent.maritalStatus,
      'date_of_birth': agent.dateOfBirth,
      'email': agent.email,
      'phone': agent.phoneNumber, // Map phone_number to phone
      'address': agent.address,
      'city': agent.city,
      'state': agent.state,
      'lga': agent.lga,
      'state_of_origin': agent.stateOfOrigin,
      'lga_of_origin': agent.lgaOfOrigin,
      'bvn': agent.bvn,
      'nin': agent.nin,
      'id_type': agent.idType,
    };

    // Call the add-agent-bank API
    final success = await vm.addAgentBank(payload);
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Pre-populate VM for the next step (otp/generate)
        vm.setFromAgent(agent); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.successMessage ?? 'Agent added to payment system successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh detail view state to show the "Next" button
        context.read<AgentDetailViewModel>().checkAgentExistence();
        
        // We STAY on this screen as requested. The button will change to "Next".
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.errorMessage ?? 'Failed to add agent to payment system'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentDetailViewModel>(
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
        body: RefreshIndicator(
          onRefresh: vm.refreshAgent,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildAgentHeader(vm),
              const SizedBox(height: 16),
              _buildTerminalDetails(vm),
              const SizedBox(height: 12),
              _buildPersonalInfo(vm.agent),
              const SizedBox(height: 12),
              _buildAddressInfo(vm.agent),
              const SizedBox(height: 12),
              _buildIdentityVerification(vm.agent),
              const SizedBox(height: 12),
              _buildBankingDetails(vm.agent),
              const SizedBox(height: 12),
              _buildCompanyAssociation(vm.agent),
              const SizedBox(height: 32),
              _buildBottomActionButtons(context, vm),
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

    final bool hasValidStatus = vm.agentStatus != null &&
        vm.agentStatus!.toLowerCase() != 'unknown';

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
                const ShimmerField(height: 24, width: 80)
              else if (hasValidStatus)
                StatusChip(status: vm.agentStatus!),
            ],
          ),
        ],
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

  Widget _buildTerminalDetails(AgentDetailViewModel vm) {
    return _buildSectionCard(
      title: 'POS TERMINAL DETAILS',
      accentColor: Colors.blueGrey,
      children: [
        if (vm.isLoadingTerminals)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (vm.terminals.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text('No terminals assigned', style: TextStyle(color: Colors.grey, fontSize: 13)),
          )
        else
          ...vm.terminals.map((terminal) => Column(
                children: [
                  DetailRow(label: 'Terminal ID', value: terminal.terminalId),
                  DetailRow(label: 'Serial Number', value: terminal.serialNumber),
                  if (terminal != vm.terminals.last) const Divider(height: 16),
                ],
              )),
      ],
    );
  }

  Widget _buildCompanyAssociation(AgentModel a) {
    return _buildSectionCard(
      title: 'COMPANY ASSOCIATION',
      accentColor: Colors.purple,
      children: [
        DetailRow(label: 'Company Number', value: a.companyNumber),
        DetailRow(label: 'RC Number', value: a.rcNumber.isNotEmpty ? a.rcNumber : 'N/A'),
        DetailRow(label: 'Map To Company', value: a.mapToCompany.toString()),
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

  Widget _buildBottomActionButtons(BuildContext context, AgentDetailViewModel vm) {
    if (vm.isLoadingExistence || vm.isLoadingTerminals) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.agent.mapToCompany == 0) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => _handleMapAgentToCompany(context),
          icon: const Icon(Icons.link),
          label: const Text('Map To Company'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade800,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    if (vm.agentExistsInPaymentSystem == true) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.agentBankVerification, arguments: vm.agent);
          },
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Next'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _handleAddAgentToPayment(context, vm.agent),
        icon: const Icon(Icons.account_balance),
        label: const Text('Add Agent To Payment System'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1A237E)),
          foregroundColor: const Color(0xFF1A237E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
