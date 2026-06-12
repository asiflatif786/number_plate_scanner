import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/models/transaction_draft_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../core/session/session_manager.dart';

class TransactionCreationViewModel extends ChangeNotifier {
  final TransactionDraftModel draft;
  final TransactionRepository _repository = TransactionRepository();
  final TextEditingController payerNameController;
  final TextEditingController payerPhoneController;

  TransactionCreationViewModel({required this.draft})
      : payerNameController = TextEditingController(
            text: draft.vehicle.customerName != 'N/A'
                ? draft.vehicle.customerName
                : ''),
        payerPhoneController = TextEditingController(
            text: draft.vehicle.phoneNumber ?? '');

  String selectedPaymentMethod = 'card';
  bool isSubmitting = false;
  String? errorMessage;

  static const List<Map<String, dynamic>> paymentMethods = [
    {
      'value': 'card',
      'label': 'Card Payment',
      'icon': Icons.credit_card,
      'color': Colors.blue,
      'subtitle': 'Tap or swipe card at terminal',
    },
    {
      'value': 'wallet',
      'label': 'Wallet',
      'icon': Icons.account_balance_wallet,
      'color': Colors.purple,
      'subtitle': "Deduct from customer's wallet balance",
    },
    {
      'value': 'transfer',
      'label': 'Bank Transfer',
      'icon': Icons.swap_horiz,
      'color': Colors.green,
      'subtitle': 'Customer pays via bank transfer',
    },
  ];

  void onPaymentMethodChanged(String method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    final session = await SessionManager.instance;
    final agentNumber = session.agentNumber;
    final terminalId = session.terminalId;

    if (agentNumber == null || agentNumber.isEmpty) {
      errorMessage =
          'Session error. Agent number missing. Please restart.';
      isSubmitting = false;
      notifyListeners();
      return;
    }

    final result = await _repository.createTransaction(
      draft,
      selectedPaymentMethod,
      payerName: payerNameController.text.isNotEmpty
          ? payerNameController.text
          : draft.vehicle.vehicleLicense,
      payerPhone: payerPhoneController.text,
    );

    if (result.success && result.data != null) {
      final pendingTransaction =
          TransactionModel.fromDraftAndResponse(
        draft,
        selectedPaymentMethod,
        result.data!,
        agentNumber,
        terminalId ?? '',
      );

      isSubmitting = false;
      notifyListeners();

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.paymentProcessing,
        arguments: pendingTransaction,
      );
    } else {
      errorMessage = _mapFailureMessage(result.failure!.message);
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    payerNameController.dispose();
    payerPhoneController.dispose();
    super.dispose();
  }

  String _mapFailureMessage(String message) {
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('internet')) {
      return 'No internet connection. Check your network';
    }
    if (message.toLowerCase().contains('auth') ||
        message.toLowerCase().contains('key')) {
      return 'API authentication error. Contact your administrator';
    }
    if (message.toLowerCase().contains('already exists')) {
      return 'A transaction already exists for this vehicle';
    }
    if (message.toLowerCase().contains('terminal')) {
      return 'Terminal not recognized. Contact your administrator';
    }
    if (message.toLowerCase().contains('agent not found')) {
      return 'Agent account not found. Please re-login';
    }
    return 'Transaction creation failed. Please try again';
  }
}
