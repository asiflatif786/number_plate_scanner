import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../../data/models/transaction_model.dart';
import 'transaction_success_viewmodel.dart';

class TransactionSuccessScreen extends StatelessWidget {
  const TransactionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transaction =
        ModalRoute.of(context)!.settings.arguments as TransactionModel;

    return ChangeNotifierProvider(
      create: (_) => TransactionSuccessViewModel(transaction: transaction),
      child: const _TransactionSuccessAnimatedBody(),
    );
  }
}

class _TransactionSuccessAnimatedBody extends StatefulWidget {
  const _TransactionSuccessAnimatedBody();

  @override
  State<_TransactionSuccessAnimatedBody> createState() =>
      _TransactionSuccessAnimatedBodyState();
}

class _TransactionSuccessAnimatedBodyState
    extends State<_TransactionSuccessAnimatedBody>
    with TickerProviderStateMixin, WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    
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
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final vm = Provider.of<TransactionSuccessViewModel>(context, listen: false);
      final status = vm.transaction.status.toLowerCase();
      if (status == 'pending' || status == 'created') {
        vm.verifyTransaction();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionSuccessViewModel>(
      builder: (context, vm, _) {
        final t = vm.transaction;
        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Transaction Details'),
              backgroundColor: t.statusColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: 'Print Receipt',
                  onPressed: () => _showPrintOptions(context, vm),
                ),
                IconButton(
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
              ],
            ),
            body: _SuccessBody(
              vm: vm,
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
        );
      },
    );
  }

  void _showPrintOptions(BuildContext context, TransactionSuccessViewModel vm) {
    vm.getBluetoothDevices();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ChangeNotifierProvider.value(
        value: vm,
        child: Consumer<TransactionSuccessViewModel>(
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
                        vm.printReceipt();
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
}

class _SuccessBody extends StatelessWidget {
  final TransactionSuccessViewModel vm;
  final Animation<double> panelFade;
  final Animation<double> checkScale;
  final Animation<double> textFade;
  final Animation<double> refFade;
  final Animation<Offset> cardSlide;
  final Animation<double> cardFade;
  final Animation<double> buttonsFade;
  final Animation<double> shareFade;

  const _SuccessBody({
    required this.vm,
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
    final t = vm.transaction;
    final status = t.status.toLowerCase();
    
    final isFinalized = status == 'confirmed' || status == 'approved';
    final isPaid = status == 'paid' || 
                   status == 'success' || 
                   status == 'successful' || 
                   vm.isPaymentRedirected;
    final isDeclined = status == 'declined' || status == 'failed';
    final isPending = (status == 'pending' || status == 'created') && !vm.isPaymentRedirected;

    return SingleChildScrollView(
      child: Column(
        children: [
          FadeTransition(
            opacity: panelFade,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              decoration: BoxDecoration(
                color: t.statusColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: checkScale,
                    child: Icon(
                      isFinalized
                          ? Icons.check_circle
                          : (isPaid
                              ? Icons.verified_user
                              : (isDeclined
                                  ? Icons.cancel
                                  : Icons.hourglass_empty)),
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: textFade,
                    child: Text(
                      isFinalized
                          ? (status == 'approved' ? 'Transaction Approved' : 'Transaction Confirmed')
                          : (isPaid
                              ? 'Payment Verified'
                              : (isDeclined
                                  ? 'Transaction Declined'
                                  : 'Waiting for Payment')),
                      style: const TextStyle(
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
          
          if (!isFinalized && !isDeclined)
            FadeTransition(
              opacity: buttonsFade,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isPaid ? Colors.green : Colors.indigo).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (isPaid ? Colors.green : Colors.indigo).withOpacity(0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaid ? 'ACTION REQUIRED' : 'PAYMENT ACTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isPaid ? Colors.green.shade800 : Colors.indigo.shade800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (isPaid) ...[
                      _buildWideButton(
                        label: 'Approve Transaction',
                        icon: Icons.check_circle,
                        color: Colors.green.shade700,
                        isLoading: vm.isApproving,
                        onPressed: () => vm.approveTransaction(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    if (isPending) ...[
                      _buildWideButton(
                        label: 'Verify Payment Status',
                        icon: Icons.sync,
                        color: Colors.indigo.shade700,
                        isLoading: vm.isVerifying,
                        onPressed: () => vm.verifyTransaction(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    _buildWideButton(
                      label: 'Decline Transaction',
                      icon: Icons.cancel_outlined,
                      color: Colors.red,
                      isOutlined: true,
                      isLoading: vm.isDeclining,
                      onPressed: () => _confirmDecline(context, vm),
                    ),
                  ],
                ),
              ),
            ),

          FadeTransition(
            opacity: buttonsFade,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (vm.statusMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDeclined ? Colors.red.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        vm.statusMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDeclined ? Colors.red.shade800 : Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildWideButton(
                    label: 'Back to Dashboard',
                    icon: Icons.dashboard,
                    color: const Color(0xFF1A237E),
                    isOutlined: true,
                    onPressed: () => vm.goToDashboard(context),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWideButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isOutlined = false,
  }) {
    final style = isOutlined 
      ? OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50),
        )
      : ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50),
          elevation: 0,
        );

    final content = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return isOutlined 
      ? OutlinedButton(onPressed: isLoading ? null : onPressed, style: style, child: content)
      : ElevatedButton(onPressed: isLoading ? null : onPressed, style: style, child: content);
  }

  void _confirmDecline(BuildContext context, TransactionSuccessViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Transaction'),
        content: const Text(
          'Are you sure you want to decline this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.declineTransaction();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    MaterialColor chipColor;
    String label;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
      case 'confirmed':
      case 'success':
      case 'successful':
        chipColor = Colors.green;
        label = status.toUpperCase();
        break;
      case 'declined':
      case 'failed':
        chipColor = Colors.red;
        label = status.toUpperCase();
        break;
      default:
        chipColor = Colors.amber;
        label = 'PENDING';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.shade600,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
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
            _buildReceiptHeader(vm),
            const Divider(),
            _buildInfoRow('Transaction Ref', t.transactionReference,
                isMonospace: true, isSelectable: true),
            const SizedBox(height: 6),
            _buildInfoRow('Payer Name', t.customerName),
            _buildInfoRow('Vehicle Plate', t.vehicleLicense,
                isMonospace: true, isSelectable: true),
            const SizedBox(height: 4),
            _buildTripTypeChip(t.transactionType),
            const Divider(),
            _buildInfoRow('Payment Method', t.paymentMethodDisplay),
            const SizedBox(height: 6),
            _buildRouteSection(t),
            const Divider(),
            _buildPaymentBreakdown(t),
            const Divider(),
            _buildInfoRow('Date & Time', t.createdAt),
            const SizedBox(height: 4),
            _buildInfoRow('Terminal ID', t.terminalId, isMonospace: true),
            const Divider(),
            _buildReceiptFooter(t.transactionReference),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader(TransactionSuccessViewModel vm) {
    return Row(
      children: [
        const Icon(Icons.receipt_long, size: 20, color: Color(0xFF1A237E)),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Official Receipt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => vm.copyReceipt(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: vm.isCopied ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  vm.isCopied ? Icons.check : Icons.content_copy,
                  size: 16,
                  color: vm.isCopied ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  vm.isCopied ? 'Copied ✓' : 'Copy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: vm.isCopied ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteSection(t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text('Route',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey, letterSpacing: 1)),
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
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121))),
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

  Widget _buildPaymentBreakdown(t) {
    return Column(
      children: [
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
                child: Text('Total',
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
                size: 100.0,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 4),
              const Text(
                'Scan to Validate',
                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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

  Widget _buildInfoRow(String label, String value,
      {bool isMonospace = false, bool isSelectable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
      ),
    );
  }

  Widget _buildTripTypeChip(String transactionType) {
    final isSingle = transactionType == 'single';
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

  Widget _buildFeeRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
}
