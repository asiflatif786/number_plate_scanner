import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_model.dart';
import 'transaction_success_viewmodel.dart';

class TransactionSuccessScreen extends StatefulWidget {
  const TransactionSuccessScreen({super.key});

  @override
  State<TransactionSuccessScreen> createState() =>
      _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _panelFade;
  late final Animation<double> _checkScale;
  late final Animation<double> _textFade;
  late final Animation<double> _refFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;
  late final Animation<double> _buttonsFade;
  late final Animation<double> _shareFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _panelFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _checkScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.47, curve: Curves.elasticOut),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.53, curve: Curves.easeIn),
    );
    _refFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.47, 0.65, curve: Curves.easeIn),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.59, 0.82, curve: Curves.easeOut),
    ));
    _cardFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.59, 0.82, curve: Curves.easeIn),
    );
    _buttonsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.76, 0.94, curve: Curves.easeIn),
    );
    _shareFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaction =
        ModalRoute.of(context)!.settings.arguments as TransactionModel;

    return ChangeNotifierProvider(
      create: (_) =>
          TransactionSuccessViewModel(transaction: transaction),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Transaction Complete'),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            actions: [
              Consumer<TransactionSuccessViewModel>(
                builder: (context, vm, _) => IconButton(
                  icon: vm.isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share),
                  tooltip: 'Share Receipt',
                  onPressed: vm.isSharing ? null : () => vm.shareReceipt(),
                ),
              ),
            ],
          ),
          body: _SuccessBody(
            panelFade: _panelFade,
            checkScale: _checkScale,
            textFade: _textFade,
            refFade: _refFade,
            cardSlide: _cardSlide,
            cardFade: _cardFade,
            buttonsFade: _buttonsFade,
            shareFade: _shareFade,
          ),
        ),
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  final Animation<double> panelFade;
  final Animation<double> checkScale;
  final Animation<double> textFade;
  final Animation<double> refFade;
  final Animation<Offset> cardSlide;
  final Animation<double> cardFade;
  final Animation<double> buttonsFade;
  final Animation<double> shareFade;

  const _SuccessBody({
    required this.panelFade,
    required this.checkScale,
    required this.textFade,
    required this.refFade,
    required this.cardSlide,
    required this.cardFade,
    required this.buttonsFade,
    required this.shareFade,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionSuccessViewModel>(
      builder: (context, vm, _) {
        final t = vm.transaction;
        return SingleChildScrollView(
          child: Column(
            children: [
              FadeTransition(
                opacity: panelFade,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                      24, 16, 24, 40),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: checkScale,
                        child: const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: textFade,
                        child: const Text(
                          'Transaction Successful',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: refFade,
                        child: Text(
                          'Ref: ${t.transactionReference}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: refFade,
                        child: _buildStatusChip(t.status),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: FadeTransition(
                  opacity: cardFade,
                  child: SlideTransition(
                    position: cardSlide,
                    child: _buildReceiptCard(context, vm),
                  ),
                ),
              ),
              FadeTransition(
                opacity: buttonsFade,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              vm.newTransaction(context),
                          icon: const Icon(
                              Icons.add_circle_outline),
                          label: const Text(
                            'New Transaction',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1A237E),
                            foregroundColor: Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              vm.goToDashboard(context),
                          icon: const Icon(Icons.dashboard),
                          label: const Text(
                            'Back to Dashboard',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color(0xFF1A237E),
                            side: const BorderSide(
                                color: Color(0xFF1A237E)),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: shareFade,
                child: Consumer<TransactionSuccessViewModel>(
                  builder: (context, vm, _) => TextButton.icon(
                    onPressed:
                        vm.isSharing ? null : () => vm.shareReceipt(),
                    icon: vm.isSharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : const Icon(Icons.share, size: 18),
                    label: Text(
                      vm.isSharing
                          ? 'Sharing...'
                          : 'Share Receipt',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    final isApproved = status == 'approved';
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isApproved
            ? Colors.green.shade600
            : Colors.amber.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isApproved ? 'APPROVED' : 'PENDING',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
      BuildContext context, TransactionSuccessViewModel vm) {
    final t = vm.transaction;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
            _buildReceiptHeader(vm),
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

  Widget _buildReceiptHeader(
      TransactionSuccessViewModel vm) {
    return Row(
      children: [
        const Icon(Icons.receipt_long,
            size: 20, color: Color(0xFF1A237E)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Transaction Receipt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
        ),
        InkWell(
          onTap: () => vm.copyReceipt(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: vm.isCopied
                    ? Colors.green
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  vm.isCopied
                      ? Icons.check
                      : Icons.content_copy,
                  size: 16,
                  color: vm.isCopied
                      ? Colors.green
                      : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  vm.isCopied ? 'Copied \u2713' : 'Copy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: vm.isCopied
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionInfo(t) {
    return Column(
      children: [
        _buildInfoRow('Transaction Ref',
            t.transactionReference, isSelectable: true),
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
        _buildInfoRow('License Plate', t.vehicleLicense,
            isMonospace: true, isSelectable: true),
        const SizedBox(height: 6),
        _buildTripTypeChip(t.transactionType),
      ],
    );
  }

  Widget _buildRouteSection(t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Route',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      letterSpacing: 1)),
            ),
          ],
        ),
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
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward,
                size: 20, color: Color(0xFF1A237E)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SelectableText(t.destinationLga,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121))),
                  Text(t.destinationState,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey)),
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
        _buildFeeRow('Service Fee', t.formattedServiceFee),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(thickness: 1.5),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E)
                .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text('Total Paid',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121))),
              ),
              SelectableText(
                t.formattedTotal,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
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
          child: Text(
            '- - - - - - - - - - - - - - - -',
            style: TextStyle(
                fontSize: 12, color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Thank you for using Cyber1 TMS',
            style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            'Powered by Cyber1 Systems',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isMonospace = false,
      bool isSelectable = false}) {
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
                    fontFamily:
                        isMonospace ? 'monospace' : null,
                    letterSpacing:
                        isMonospace ? 1 : null,
                  ),
                )
              : Text(
                  value.isEmpty ? 'N/A' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                    fontFamily:
                        isMonospace ? 'monospace' : null,
                    letterSpacing:
                        isMonospace ? 1 : null,
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
              style: TextStyle(
                  fontSize: 12, color: Colors.grey)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: t.statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            t.status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: t.statusColor,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTripTypeChip(String transactionType) {
    final isSingle = transactionType == 'single';
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 4),
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

  Widget _buildFeeRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey)),
        ),
        SelectableText(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
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
      default:
        icon = Icons.payment;
    }
    return Row(
      children: [
        const SizedBox(
          width: 120,
          child: Text('Payment Method',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey)),
        ),
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          t.paymentMethodDisplay,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
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
