import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'logger.dart';

class ClipboardHelper {
  static Future<void> copyToClipboard(
    BuildContext context,
    String value,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));

    await Fluttertoast.showToast(
      msg: '$label copied to clipboard',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF323232),
      textColor: Colors.white,
      fontSize: 14,
    );

    AppLogger.debug('ClipboardHelper', '$label copied');
  }
}
