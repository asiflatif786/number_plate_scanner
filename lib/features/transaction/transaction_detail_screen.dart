import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/transaction_model.dart';
import 'transaction_detail_viewmodel.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends State<TransactionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final transaction =
        ModalRoute.of(context)!.settings.arguments as TransactionModel;

    return ChangeNotifierProvider(
      create: (_) =>
          TransactionDetailViewModel(transaction: transaction),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('Transaction Details'),
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share Receipt',
              onPressed: () =>
                  _shareReceipt(context, transaction),
            ),
          ],
        ),
        body: Consumer<TransactionDetailViewModel>(
          builder: (context, vm, _) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildReceipt(vm.transaction),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorBanner(vm),
                ],
                const SizedBox(height: 16),
                if (vm.hasBankDetails || vm.agentWalletNumber != null) ...[
                  _buildPaymentSystemDetailsCard(vm),
                  const SizedBox(height: 16),
                ],
                if (vm.transaction.status.toLowerCase() == 'pending' || 
                    vm.transaction.status.toLowerCase() == 'created') 
                  _buildPaymentButtons(vm),
                const SizedBox(height: 16),
                _buildVerifySection(vm),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSystemDetailsCard(TransactionDetailViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: Colors.indigo.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment System Details',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (vm.hasBankDetails) ...[
            const Text(
              'Bank Transfer Details:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            _buildBankInfoRow('Bank Name', vm.bankName ?? 'N/A'),
            const SizedBox(height: 8),
            _buildBankInfoRow(
              'Account Number', 
              vm.accountNumber ?? 'N/A', 
              isCopyable: true,
            ),
            const SizedBox(height: 8),
            _buildBankInfoRow('Account Name', vm.accountName ?? 'N/A'),
            const Divider(height: 24),
          ],
          if (vm.agentWalletNumber != null) ...[
            const Text(
              'Agent Wallet Details:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            _buildBankInfoRow(
              'Wallet Number', 
              vm.agentWalletNumber!, 
              isCopyable: true,
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.amber.shade900),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'After payment, click "Verify Current Status" below to confirm.',
                    style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(String label, String value, {bool isCopyable = false}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (isCopyable && value != 'N/A')
          IconButton(
            icon: const Icon(Icons.copy, size: 16, color: Colors.indigo),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label copied to clipboard'), duration: const Duration(seconds: 1)),
              );
            },
          ),
      ],
    );
  }

  Widget _buildErrorBanner(TransactionDetailViewModel vm) {
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

  Widget _buildPaymentButtons(TransactionDetailViewModel vm) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: vm.isProcessingPayment ? null : () => vm.payWithWallet(),
            icon: vm.isProcessingPayment
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.account_balance_wallet),
            label: const Text('Pay with CCA Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: vm.isProcessingPayment ? null : () => vm.payWithSquadCo(),
            icon: const Icon(Icons.payment),
            label: const Text('Pay with SquadCo', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifySection(TransactionDetailViewModel vm) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: vm.isVerifying ? null : () => vm.verifyStatus(),
          icon: vm.isVerifying
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync, size: 18),
          label: Text(
              vm.isVerifying ? 'Verifying...' : 'Verify Current Status'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        if (vm.verifyMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              vm.verifyMessage!,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  void _shareReceipt(BuildContext context, t) {
    final text = _buildReceiptText(t);
    Share.share(text,
        subject: 'Consolidated Haulage Levy Receipt - ${t.transactionReference}');
  }

  String _buildReceiptText(t) {
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
    if (t.customerPhone != null) sb.writeln('Phone:            ${t.customerPhone}');
    sb.writeln('Vehicle:          ${t.vehicleLicense}');
    if (t.vehicleType != null) sb.writeln('Vehicle Type:     ${t.vehicleType}');
    final tripType =
        t.transactionType == 'single' ? 'Single Trip' : 'Complete Trip';
    sb.writeln('Trip Type:        $tripType');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('ROUTE');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('From:  ${t.originLga}, ${t.originState}${t.originTown != null ? ' (${t.originTown})' : ''}');
    sb.writeln('To:    ${t.destinationLga}, ${t.destinationState}${t.destinationTown != null ? ' (${t.destinationTown})' : ''}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('PAYMENT');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Base Amount:      ${t.formattedAmount}');
    sb.writeln('Convenience Fee:  ${t.formattedServiceFee}');
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

  Widget _buildReceipt(t) {
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
            _buildReceiptHeader(t),
            const Divider(),
            _buildTransactionInfo(t),
            const Divider(),
            _buildCustomerVehicle(t),
            const Divider(),
            _buildRouteSection(t),
            const Divider(),
            _buildPaymentBreakdown(t),
            const Divider(),
            _buildProcessedBy(t),
            const Divider(),
            _buildReceiptFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader(t) {
    return Row(
      children: [
        const Icon(Icons.receipt_long,
            size: 20, color: Color(0xFF1A237E)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('Transaction Receipt',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121))),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _copyReceipt(t),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.content_copy,
                    size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Copy',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copyReceipt(t) async {
    try {
      await Clipboard.setData(
          ClipboardData(text: _buildReceiptText(t)));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Receipt copied to clipboard'),
              duration: Duration(seconds: 2)),
        );
      }
    } catch (_) {}
  }

  Widget _buildTransactionInfo(t) {
    return Column(
      children: [
        _buildInfoRow(
            'Transaction Ref', t.transactionReference,
            isSelectable: true),
        const SizedBox(height: 6),
        _buildInfoRow('Date & Time', t.createdAt),
        const SizedBox(height: 6),
        _buildStatusRow(t),
      ],
    );
  }

  Widget _buildCustomerVehicle(t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Customer Name', t.customerName),
        const SizedBox(height: 6),
        if (t.customerPhone != null) ...[
          _buildInfoRow('Customer Phone', t.customerPhone!),
          const SizedBox(height: 6),
        ],
        _buildInfoRow('License Plate', t.vehicleLicense,
            isMonospace: true, isSelectable: true),
        const SizedBox(height: 6),
        if (t.vehicleType != null && t.vehicleType != 'N/A') ...[
          _buildInfoRow('Vehicle Type', t.vehicleType!),
          const SizedBox(height: 6),
        ],
        _buildTripTypeChip(t.transactionType),
      ],
    );
  }

  Widget _buildRouteSection(t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Expanded(
            child: Text('Route',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    letterSpacing: 1)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(t.originLga,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121))),
                  Text(t.originState,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  if (t.originTown != null)
                    Text(t.originTown!,
                        style: const TextStyle(fontSize: 10, color: Colors.indigo)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_forward,
                  size: 20, color: Color(0xFF1A237E)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SelectableText(t.destinationLga,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121))),
                  Text(t.destinationState,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  if (t.destinationTown != null)
                    Text(t.destinationTown!,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 10, color: Colors.indigo)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdown(t) {
    return Column(
      children: [
        _buildFeeRow('Base Amount', t.formattedAmount),
        const SizedBox(height: 6),
        _buildFeeRow('Convenience Fee', t.formattedServiceFee),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(thickness: 1.5),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.05),
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
              const SizedBox(width: 8),
              Flexible(
                child: SelectableText(
                  t.formattedTotal,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodRow(t),
      ],
    );
  }

  Widget _buildProcessedBy(t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Processed By',
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        _buildSmallRow('Agent Number', t.agentNumber),
        const SizedBox(height: 4),
        _buildSmallRow('Terminal ID', t.terminalId),
      ],
    );
  }

  Widget _buildReceiptFooter() {
    return Column(
      children: [
        Center(
          child: Text('- - - - - - - - - - - - - - - -',
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text('Thank you for using Consolidated Haulage Levy',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey)),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text('Powered by Cyber1 Systems',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isMonospace = false, bool isSelectable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: isSelectable
              ? SelectableText(
                  value.isEmpty ? 'N/A' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                    fontFamily: isMonospace ? 'monospace' : null,
                    letterSpacing: isMonospace ? 1 : null,
                  ),
                )
              : Text(
                  value.isEmpty ? 'N/A' : value,
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

  Widget _buildStatusRow(t) {
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text('Status',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Flexible(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: t.statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              t.status.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: t.statusColor,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripTypeChip(String transactionType) {
    final isSingle = transactionType == 'single';
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSingle
            ? Colors.blue.withOpacity(0.1)
            : Colors.purple.withOpacity(0.1),
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

  Widget _buildFeeRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: SelectableText(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121))),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodRow(t) {
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
      case 'squad':
        icon = Icons.payment;
        break;
      default:
        icon = Icons.payment;
    }
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text('Payment Method',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(t.paymentMethodDisplay,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121))),
        ),
      ],
    );
  }

  Widget _buildSmallRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Colors.grey)),
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
