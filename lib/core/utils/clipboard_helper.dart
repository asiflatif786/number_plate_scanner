import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logger.dart';

class ClipboardHelper {
  static Future<void> copyToClipboard(
    BuildContext context,
    String value,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    AppLogger.debug('ClipboardHelper', '$label copied');
  }
}
