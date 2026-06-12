import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/session/session_manager.dart';
import '../../core/utils/logger.dart';

class OnboardingCompleteViewModel extends ChangeNotifier {
  static const String _tag = 'OnboardCompleteVM';

  String agentNumber = '';
  String companyNumber = '';
  String terminalId = '';
  String agentEmail = '';
  String agentFullName = '';
  bool isCopied = false;

  Future<void> loadCredentials() async {
    final session = await SessionManager.instance;
    agentNumber = session.agentNumber ?? 'N/A';
    companyNumber = session.companyNumber ?? 'N/A';
    terminalId = session.terminalId ?? 'N/A';
    agentEmail = session.agentEmail ?? 'N/A';
    agentFullName = session.agentFullName.isNotEmpty
        ? session.agentFullName
        : 'N/A';
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
    Navigator.pushReplacementNamed(context, '/agent-dashboard');
  }
}
