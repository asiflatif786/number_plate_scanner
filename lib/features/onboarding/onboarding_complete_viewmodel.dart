import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';

class OnboardingCompleteViewModel extends ChangeNotifier {
  static const String _tag = 'OnboardCompleteVM';

  bool isCopied = false;
  SessionManager? _session;

  String get agentNumber => _session?.agentNumber ?? 'N/A';
  String get companyNumber => _session?.companyNumber ?? 'N/A';
  String get terminalId => _session?.terminalId ?? 'N/A';
  String get agentEmail => _session?.agentEmail ?? 'N/A';
  String get agentFullName {
    final name = _session?.agentFullName ?? '';
    return name.isNotEmpty ? name : 'N/A';
  }

  Future<void> loadCredentials() async {
    _session = await SessionManager.instance;
    AppLogger.logInfo(_tag,
        'Loaded — name: $agentFullName, email: $agentEmail, agent: $agentNumber, company: $companyNumber, terminal: $terminalId');
    notifyListeners();
  }

  Future<void> copyCredentials() async {
    final buffer = StringBuffer();
    buffer.writeln('Cyber1 TMS — Agent Credentials');
    buffer.writeln('================================');
    buffer.writeln('Name:\t\t$agentFullName');
    buffer.writeln('Email:\t\t$agentEmail');
    buffer.writeln('Agent Number:\t$agentNumber');
    buffer.writeln('Company Number:\t$companyNumber');
    buffer.writeln('Terminal ID:\t$terminalId');
    buffer.writeln('================================');
    buffer.write('Keep this information safe.');

    try {
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      isCopied = true;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 2500), () {
        isCopied = false;
        notifyListeners();
      });
    } catch (e) {
      AppLogger.logError(_tag, 'Clipboard copy failed', e);
    }
  }

  void proceedToDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRoutes.agentDashboard);
  }
}
