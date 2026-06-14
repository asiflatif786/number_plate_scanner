import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/detail_row.dart';
import '../../../../core/widgets/section_header.dart';

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
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Payment Receipt', fontSize: 16.0),
        const Divider(height: 24),
        DetailRow(label: 'Reference', value: txn.transactionRef),
        DetailRow(
            label: 'License Plate', value: txn.vehicleLicense),
        DetailRow(label: 'Vehicle Type', value: txn.vehicleType),
        DetailRow(
            label: 'Payer',
            value: '${txn.payerFirstName} ${txn.payerLastName}'),
        DetailRow(label: 'Phone', value: txn.payerPhone),
        DetailRow(
            label: 'Payment Method',
            value: txn.paymentMethod.toUpperCase()),
        DetailRow(
          label: 'Trip Type',
          value: txn.transactionType == 'complete'
              ? 'Complete Trip'
              : 'Single Trip',
        ),
        const Divider(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 110,
              child: Text('Total Paid',
                  style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
            ),
            Expanded(
              child: Text(
                CurrencyFormatter.format(txn.totalAmount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
        if (txn.createdAt != null) ...[
          const Divider(height: 16),
          DetailRow(label: 'Date', value: txn.createdAt!),
        ],
      ],
    );
    final card = AppCard(
      elevation: 3,
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
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

  Widget _buildDoneButton() {
    final button = AppButton(
      label: 'Done',
      onPressed: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      icon: Icons.home,
      color: const Color(0xFF1A237E),
      textColor: Colors.white,
      height: ResponsiveHelper.buttonHeight(context),
      fontSize: 16,
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
