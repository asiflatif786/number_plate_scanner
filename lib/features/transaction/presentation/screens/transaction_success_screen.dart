import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionSuccessScreen extends StatefulWidget {
  final TransactionEntity transaction;

  const TransactionSuccessScreen({super.key, required this.transaction});

  @override
  State<TransactionSuccessScreen> createState() =>
      _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen>
    with SingleTickerProviderStateMixin {
  static const String _tag = 'TransactionSuccessScreen';
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
    AppLogger.info(_tag,
        'Success: ${widget.transaction.transactionRef}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.transaction;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Transaction Complete'),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildAnimatedCheckmark(),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildReceiptCard(txn),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildDoneButton(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCheckmark() {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: Container(
            width: ResponsiveHelper.iconSize(context, 100),
            height: ResponsiveHelper.iconSize(context, 100),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: ResponsiveHelper.iconSize(context, 60),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptCard(TransactionEntity txn) {
    final cardContent = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long,
                  size: 20, color: Color(0xFF1A237E)),
              SizedBox(width: 8),
              Text(
                'Payment Receipt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildReceiptRow('Reference', txn.transactionRef),
          const SizedBox(height: 8),
          _buildReceiptRow(
              'License Plate', txn.vehicleLicense),
          const SizedBox(height: 8),
          _buildReceiptRow('Vehicle Type', txn.vehicleType),
          const SizedBox(height: 8),
          _buildReceiptRow(
              'Payer', '${txn.payerFirstName} ${txn.payerLastName}'),
          const SizedBox(height: 8),
          _buildReceiptRow('Phone', txn.payerPhone),
          const SizedBox(height: 8),
          _buildReceiptRow(
              'Payment Method', txn.paymentMethod.toUpperCase()),
          const SizedBox(height: 8),
          _buildReceiptRow(
              'Trip Type',
              txn.transactionType == 'complete'
                  ? 'Complete Trip'
                  : 'Single Trip'),
          const Divider(height: 16),
          _buildReceiptRow(
            'Total Paid',
            CurrencyFormatter.format(txn.totalAmount),
            isBold: true,
            color: const Color(0xFF2E7D32),
          ),
          if (txn.createdAt != null) ...[
            const Divider(height: 16),
            _buildReceiptRow('Date', txn.createdAt!),
          ],
        ],
      ),
    );
    final card = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: cardContent,
    );
    if (ResponsiveHelper.isTablet(context)) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: card,
        ),
      );
    }
    return card;
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? const Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton() {
    final button = SizedBox(
      width: double.infinity,
      height: ResponsiveHelper.buttonHeight(context),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
        icon: const Icon(Icons.home, color: Colors.white),
        label: const Text(
          'Done',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          ),
        ),
      ),
    );
    if (ResponsiveHelper.isTablet(context)) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: button,
        ),
      );
    }
    return button;
  }
}
