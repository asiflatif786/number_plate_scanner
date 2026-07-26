import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../../data/models/vehicle_model.dart';

class VehicleFoundViewModel extends ChangeNotifier {
  static const String _tag = 'VehicleFoundVM';

  final VehicleModel vehicle;
  final String? paymentType; // chl-inter, chl-intra, penalty-inter, penalty-intra
  
  bool isProceeding = false;
  bool isSquadCoProceeding = false;
  String? errorMessage;

  bool _hasPenalty = false;
  bool get hasPenalty => _hasPenalty;

  VehicleFoundViewModel({required this.vehicle, this.paymentType}) {
    // If user selected 'penalty' related types, pre-check penalty
    if (paymentType != null && paymentType!.startsWith('penalty')) {
      _hasPenalty = true;
    }
    _checkRecentInvoices();
  }

  void togglePenalty(bool value) {
    _hasPenalty = value;
    notifyListeners();
  }

  double get baseAmount => vehicle.price.amount;
  
  // Use service fee from API if available (> 0), otherwise fallback to local calculation
  double get totalFee => vehicle.price.serviceFee > 0 
      ? vehicle.price.serviceFee 
      : (baseAmount * AppConstants.adminFeePercent + AppConstants.flatTransactionFee);
      
  double get penaltyAmount => _hasPenalty ? (baseAmount * 0.5) : 0.0;
  
  double get totalPayable => baseAmount + totalFee + penaltyAmount;

  String get formattedBaseAmount =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(baseAmount);
  String get formattedTotalFee =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(totalFee);
  String get formattedPenaltyAmount =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(penaltyAmount);
  String get formattedTotalPayable =>
      NumberFormat.currency(symbol: '\u20A6', decimalDigits: 2).format(totalPayable);

  Future<void> _checkRecentInvoices() async {
    AppLogger.logInfo(_tag, 'Checking recent invoices for ${vehicle.vehicleLicense}');
  }

  void proceedToPayment(BuildContext context) {
    isProceeding = true;
    errorMessage = null;
    notifyListeners();

    AppLogger.logInfo(_tag, 'Proceeding: ${vehicle.vehicleLicense}');

    Navigator.pushNamed(
      context,
      AppRoutes.transactionCreation,
      arguments: {
        'vehicle': vehicle,
        'hasPenalty': _hasPenalty,
        'penaltyAmount': penaltyAmount,
        'paymentType': paymentType,
      },
    ).then((_) {
      isProceeding = false;
      notifyListeners();
    }).catchError((error) {
      AppLogger.logError(_tag, 'Navigation error', error);
      errorMessage = error.toString();
      isProceeding = false;
      notifyListeners();
    });
  }

  Future<void> proceedWithSquadCo(BuildContext context) async {
    isSquadCoProceeding = true;
    errorMessage = null;
    notifyListeners();

    AppLogger.logInfo(_tag, 'Proceeding with SquadCo for ${vehicle.vehicleLicense}');

    final session = await SessionManager.instance;
    final email = session.agentEmail;
    final userId = session.agentNumber;

    if (email == null || email.isEmpty || userId == null || userId.isEmpty) {
      isSquadCoProceeding = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User email or ID not available"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final serverUrl = Uri.parse('https://tms-local-api.justerrand.ie/squadco/post-transaction');

    try {
      final response = await http.post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': (totalPayable * 100).toInt(), // Amount in kobo
          'email': email,
          'penalty_applied': _hasPenalty,
          'penalty_amount': penaltyAmount,
          'payment_type': paymentType,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned error: ${response.statusCode}');
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseBody['success'] != true) {
        throw Exception(responseBody['message'] ?? 'Failed to initialize transaction');
      }

      final data = responseBody['data'] as Map<String, dynamic>;
      final checkoutUrl = data['checkout_url'] as String?;
      final transactionRef = data['transaction_ref'] as String?;

      if (checkoutUrl == null || transactionRef == null) {
        throw Exception('Missing checkout URL or transaction reference');
      }

      final uri = Uri.parse(checkoutUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.transactionSuccess,
            arguments: {
              'vehicle': vehicle,
              'transactionRef': transactionRef,
              'method': 'SquadCo',
              'amount': totalPayable,
            },
          );
        }
      } else {
        throw Exception('Could not launch payment page');
      }
    } catch (e) {
      AppLogger.logError(_tag, 'SquadCo error', e);
      errorMessage = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      isSquadCoProceeding = false;
      notifyListeners();
    }
  }
}
