import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/routes.dart';
import '../../data/models/transaction_model.dart';

class TransactionSuccessViewModel extends ChangeNotifier {
  final TransactionModel transaction;

  bool isCopied = false;
  bool isSharing = false;

  TransactionSuccessViewModel({required this.transaction});

  String _buildReceiptText() {
    final t = transaction;
    final sb = StringBuffer();
    sb.writeln('══════════════════════════════════════');
    sb.writeln('       CYBER1 TMS — RECEIPT');
    sb.writeln('══════════════════════════════════════');
    sb.writeln();
    sb.writeln(
        'Transaction Ref:  ${t.transactionReference}');
    sb.writeln('Status:           ${t.status.toUpperCase()}');
    sb.writeln('Date:             ${t.createdAt}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('CUSTOMER DETAILS');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Name:             ${t.customerName}');
    sb.writeln('Vehicle:          ${t.vehicleLicense}');
    final tripType = t.transactionType == 'single'
        ? 'Single Trip'
        : 'Complete Trip';
    sb.writeln('Trip Type:        $tripType');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('ROUTE');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('From:  ${t.originLga}, ${t.originState}');
    sb.writeln('To:    ${t.destinationLga}, ${t.destinationState}');
    sb.writeln();
    sb.writeln('──────────────────────────────────────');
    sb.writeln('PAYMENT');
    sb.writeln('──────────────────────────────────────');
    sb.writeln('Base Amount:      ${t.formattedAmount}');
    sb.writeln('Service Fee:      ${t.formattedServiceFee}');
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
    sb.writeln('     Thank you for using Cyber1 TMS');
    return sb.toString();
  }

  Future<void> copyReceipt() async {
    try {
      await Clipboard.setData(ClipboardData(text: _buildReceiptText()));
      isCopied = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 2500));
      isCopied = false;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> shareReceipt() async {
    try {
      isSharing = true;
      notifyListeners();
      await Share.share(
        _buildReceiptText(),
        subject:
            'Cyber1 TMS Receipt - ${transaction.transactionReference}',
      );
    } catch (_) {}
    isSharing = false;
    notifyListeners();
  }

  void newTransaction(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.vehicleSearch,
      ModalRoute.withName(AppRoutes.agentDashboard),
    );
  }

  void goToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.agentDashboard,
      (route) => false,
    );
  }
}
