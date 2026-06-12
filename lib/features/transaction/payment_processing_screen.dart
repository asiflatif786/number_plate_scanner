import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/transaction_model.dart';
import 'payment_processing_viewmodel.dart';

class PaymentProcessingScreen extends StatefulWidget {
  const PaymentProcessingScreen({super.key});

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<PaymentProcessingViewModel>()
          .init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transaction =
        ModalRoute.of(context)!.settings.arguments as TransactionModel;

    return ChangeNotifierProvider(
      create: (_) => PaymentProcessingViewModel(
          pendingTransaction: transaction),
      child: Consumer<PaymentProcessingViewModel>(
        builder: (context, vm, _) {
          final isProcessing =
              vm.processingState ==
                  PaymentProcessingState.processing;

          return PopScope(
            canPop: !isProcessing,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading:
                    !isProcessing,
                title: const Text(
                    'Processing Payment'),
              ),
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildContent(vm),
                      const SizedBox(height: 24),
                      if (vm.transaction
                          .transactionReference
                          .isNotEmpty)
                        Text(
                          'Ref: ${vm.transaction.transactionReference}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
      PaymentProcessingViewModel vm) {
    switch (vm.processingState) {
      case PaymentProcessingState.processing:
        return _buildProcessing(vm);
      case PaymentProcessingState.success:
        return _buildSuccess(vm);
      case PaymentProcessingState.failed:
        return _buildFailed(vm);
    }
  }

  Widget _buildProcessing(
      PaymentProcessingViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            strokeWidth: 4,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Processing Payment...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          vm.transaction.formattedTotal,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _paymentMethodIcon(
                  vm.transaction.paymentMethod),
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              vm.transaction.paymentMethodDisplay,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 20,
                  color: Colors.amber.shade800),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Please do not close the app or remove the card',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF212121),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(
      PaymentProcessingViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle,
            size: 80, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          'Payment Approved!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          vm.transaction.formattedTotal,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () =>
                vm.proceedToReceipt(context),
            icon: const Icon(Icons.receipt_long),
            label: const Text(
              'View Receipt',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailed(
      PaymentProcessingViewModel vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error,
            size: 80, color: Colors.red),
        const SizedBox(height: 16),
        const Text(
          'Payment Failed',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        if (vm.errorMessage != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              vm.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () => vm.retryPayment(),
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Try Again',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
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
                vm.cancelAndGoBack(context),
            icon: const Icon(Icons.dashboard),
            label: const Text(
              'Cancel & Return to Dashboard',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(0xFF1A237E),
              side: const BorderSide(
                  color: Color(0xFF1A237E)),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _paymentMethodIcon(String method) {
    switch (method) {
      case 'card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.payment;
    }
  }
}
