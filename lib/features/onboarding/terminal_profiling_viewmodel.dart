import 'package:flutter/material.dart';

import '../../core/errors/failure.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';
import '../repositories/onboarding_repository.dart';

class TerminalProfilingViewModel extends ChangeNotifier {
  static const String _tag = 'TermProfVM';

  final OnboardingRepository _repository;

  TerminalProfilingViewModel({OnboardingRepository? repository})
      : _repository = repository ?? OnboardingRepository();

  bool isLoading = false;
  String? errorMessage;

  final serialNumberController = TextEditingController();
  final terminalIdController = TextEditingController();

  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  String _friendlyMessage(Failure failure) {
    final msg = failure.message.toLowerCase();
    if (msg.contains('terminal') && msg.contains('already')) {
      return 'This terminal ID is already assigned to another agent';
    }
    if (msg.contains('serial')) {
      return 'Invalid serial number. Check the device label.';
    }
    if (failure is NetworkFailure) {
      return 'No internet connection. Check your network.';
    }
    if (failure is AuthFailure) {
      return 'API authentication error. Contact your administrator.';
    }
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Terminal setup failed. Please try again.';
  }

  Future<void> submit(BuildContext context) async {
    final serial = serialNumberController.text.trim().toUpperCase();
    final terminalId = terminalIdController.text.trim().toUpperCase();

    if (serial.isEmpty) {
      errorMessage = 'Device serial number is required';
      notifyListeners();
      return;
    }
    if (terminalId.isEmpty) {
      errorMessage = 'Terminal ID is required';
      notifyListeners();
      return;
    }

    final session = await SessionManager.instance;
    final agentNumber = session.agentNumber;

    if (agentNumber == null || agentNumber.isEmpty) {
      if (!context.mounted) return;
      await _showSessionErrorDialog(context, session);
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createTerminal(
        serialNumber: serial,
        terminalId: terminalId,
        agentNumber: agentNumber,
      );

      if (result.success) {
        final companyNumber = session.companyNumber;
        final email = session.agentEmail;
        final firstName = session.agentFirstName;
        final lastName = session.agentLastName;

        await session.saveOnboardingComplete(
          companyNumber: companyNumber,
          agentNumber: agentNumber,
          terminalId: terminalId,
          serialNumber: serial,
          email: email,
          firstName: firstName,
          lastName: lastName,
          role: 'Agent',
        );

        AppLogger.logInfo(
            _tag, 'Terminal linked — ID: $terminalId, Serial: $serial');

        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/onboarding-complete');
      } else if (result.failure != null) {
        errorMessage = _friendlyMessage(result.failure!);
        AppLogger.logWarning(
            _tag, 'Create terminal failed: ${result.failure!.message}');
      } else {
        errorMessage = 'Terminal setup failed. Please try again.';
      }
    } catch (e) {
      errorMessage = 'Terminal setup failed. Please try again.';
      AppLogger.logError(_tag, 'submit error', e);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _showSessionErrorDialog(
      BuildContext context, SessionManager session) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Error'),
        content: const Text(
          'Session error detected. Agent registration data is missing. '
          'Please restart onboarding.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await session.clearSession();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(
                  context, '/corporate-registration');
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    serialNumberController.dispose();
    terminalIdController.dispose();
    super.dispose();
  }
}
