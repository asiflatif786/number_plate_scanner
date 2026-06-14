import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/custom_dialog.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../viewmodels/transaction_viewmodel.dart';
import 'transaction_success_screen.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/section_header.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  static const String _tag = 'TransactionScreen';
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _feesExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionViewModel>().loadAgentInfo();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onProceedPayment() async {
    final viewmodel = context.read<TransactionViewModel>();
    viewmodel.setPayerInfo(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
    );

    final success = await viewmodel.submitTransaction();
    if (!mounted) return;

    if (success && viewmodel.currentTransaction != null) {
      AppLogger.info(_tag, 'Transaction created, navigating to success');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionSuccessScreen(
            transaction: viewmodel.currentTransaction!,
          ),
        ),
      );
    }
  }

  void _onCancel() async {
    final viewmodel = context.read<TransactionViewModel>();
    await viewmodel.abandonCurrentTransaction();
    if (!mounted) return;

    final confirmed = await CustomDialog.showConfirm(
      context,
      title: 'Abandon Transaction?',
      message: 'Are you sure you want to abandon this transaction?',
    );

    if (confirmed && mounted) {
      viewmodel.clearState();
      Navigator.pop(context);
    }
  }

  void _onError(TransactionViewModel viewmodel) {
    if (viewmodel.errorMessage == null) return;
    final msg = viewmodel.errorMessage!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomDialog.showError(
        context,
        title: 'Transaction Failed',
        message: msg,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewmodel, _) {
        _onError(viewmodel);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await viewmodel.abandonCurrentTransaction();
            if (context.mounted) Navigator.pop(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Process Payment'),
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: ResponsiveHelper.isTablet(context) ? 64 : kToolbarHeight,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await viewmodel.abandonCurrentTransaction();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ),
            body: LoadingOverlay(
              isLoading: viewmodel.isSubmitting,
              message: 'Processing transaction...',
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveHelper.horizontalPadding(context)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPayerSection(),
                      const SizedBox(height: 16),
                      _buildTripDetailsSection(viewmodel),
                      const SizedBox(height: 16),
                      _buildPaymentMethodSection(viewmodel),
                      const SizedBox(height: 16),
                      _buildFeeSummarySection(viewmodel),
                      const SizedBox(height: 24),
                      _buildActionButtons(viewmodel),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayerSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Payer Information', fontSize: 16),
          ResponsiveFieldRow(
            context: context,
            firstField: AppTextField(
              label: 'First Name',
              controller: _firstNameController,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            secondField: AppTextField(
              label: 'Last Name',
              controller: _lastNameController,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ),
          AppTextField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (v.trim().length < 11) return 'Min 11 digits';
              return null;
            },
          ),
          AppTextField(
            label: 'Email (optional)',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsSection(TransactionViewModel viewmodel) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Trip Details', fontSize: 16),
            _buildDetailRow(
                Icons.directions_car, 'License Plate', viewmodel.vehicleLicense ?? ''),
            const SizedBox(height: 8),
            _buildDetailRow(
                Icons.category, 'Vehicle Type', viewmodel.vehicleType ?? ''),
            const SizedBox(height: 8),
            _buildDetailRow(
                Icons.location_on, 'Issuing State', viewmodel.issuingState ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow(
                Icons.map, 'Enumerating State', viewmodel.enumeratingState ?? 'N/A'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.zoom_out_map, 'LGA',
                viewmodel.enumeratingLga ?? 'N/A'),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: viewmodel.selectedTransactionType == 'complete'
                        ? const Color(0xFF0288D1)
                        : const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    viewmodel.selectedTransactionType == 'complete'
                        ? 'COMPLETE TRIP'
                        : 'SINGLE TRIP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.format(viewmodel.totalAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1A237E)),
        const SizedBox(width: 8),
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(TransactionViewModel viewmodel) {
    const methods = [
      {'key': 'cash', 'label': 'Cash', 'icon': Icons.money},
      {'key': 'transfer', 'label': 'Transfer', 'icon': Icons.account_balance},
      {'key': 'pos', 'label': 'POS', 'icon': Icons.point_of_sale},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Payment Method', fontSize: 16),
            Row(
              children: methods.map((m) {
                final key = m['key'] as String;
                final isSelected = viewmodel.selectedPaymentMethod == key;
                final card = Padding(
                  padding: EdgeInsets.only(
                    left: key == 'transfer' ? 8 : 0,
                    right: key == 'transfer' ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => viewmodel.setPaymentMethod(key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A237E)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A237E)
                              : const Color(0xFFBDBDBD),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            m['icon'] as IconData,
                            size: 24,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF757575),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (ResponsiveHelper.isMobile(context)) {
                  return Expanded(child: card);
                }
                return card;
              }).toList(),
            ),
          ],
        ),
    );
  }

  Widget _buildFeeSummarySection(TransactionViewModel viewmodel) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _feesExpanded = !_feesExpanded),
            child: Row(
              children: [
                SectionHeader(title: 'Fee Summary', fontSize: 16),
                  const Spacer(),
                  Icon(
                    _feesExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF1A237E),
                  ),
                ],
              ),
            ),
            if (_feesExpanded) ...[
              _buildFeeRow('Base Fee', CurrencyFormatter.format(viewmodel.baseFee)),
              const Divider(height: 16),
              _buildFeeRow('Admin Fee (2%)',
                  CurrencyFormatter.format(viewmodel.adminFee)),
              const Divider(height: 16),
              _buildFeeRow('Transaction Fee',
                  CurrencyFormatter.format(viewmodel.transactionFee)),
              const Divider(height: 16),
              _buildFeeRow(
                  'VAT (7.5%)', CurrencyFormatter.format(viewmodel.vat)),
              const Divider(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      CurrencyFormatter.format(viewmodel.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF616161)),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TransactionViewModel viewmodel) {
    return Column(
      children: [
        AppButton(
          label: 'Proceed with Payment',
          onPressed: viewmodel.isSubmitting ? null : _onProceedPayment,
          isLoading: viewmodel.isSubmitting,
          icon: Icons.payment,
          color: const Color(0xFF2E7D32),
          height: ResponsiveHelper.buttonHeight(context),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Cancel Transaction',
          onPressed: viewmodel.isSubmitting ? null : _onCancel,
          icon: Icons.cancel_outlined,
          isOutlined: true,
          textColor: const Color(0xFFC62828),
          color: const Color(0xFFC62828),
          height: 48,
        ),
      ],
    );
  }

}
