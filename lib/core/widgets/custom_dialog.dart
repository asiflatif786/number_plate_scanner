import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../utils/responsive_helper.dart';

class CustomDialog {
  static const String _tag = 'CustomDialog';

  static EdgeInsets _insetPadding(BuildContext context) {
    return ResponsiveHelper.isTablet(context)
        ? const EdgeInsets.symmetric(horizontal: 80, vertical: 60)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 40);
  }

  static double _iconSize(BuildContext context) {
    return ResponsiveHelper.iconSize(context, 64);
  }

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onClose,
  }) {
    AppLogger.debug(_tag, 'Showing success dialog: $title');
    return _show(
      context: context,
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF2E7D32),
      title: title,
      message: message,
      buttonText: buttonText,
      buttonColor: const Color(0xFF2E7D32),
      onClose: onClose,
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onClose,
  }) {
    AppLogger.debug(_tag, 'Showing error dialog: $title');
    return _show(
      context: context,
      icon: Icons.error_rounded,
      iconColor: const Color(0xFFC62828),
      title: title,
      message: message,
      buttonText: buttonText,
      buttonColor: const Color(0xFFC62828),
      onClose: onClose,
    );
  }

  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onClose,
  }) {
    AppLogger.debug(_tag, 'Showing warning dialog: $title');
    return _show(
      context: context,
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFF57C00),
      title: title,
      message: message,
      buttonText: buttonText,
      buttonColor: const Color(0xFFF57C00),
      onClose: onClose,
    );
  }

  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    AppLogger.debug(_tag, 'Showing confirm dialog: $title');
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: _insetPadding(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline_rounded,
                    color: const Color(0xFF0288D1), size: _iconSize(context)),
                const SizedBox(height: 16),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: Text(cancelText),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ) ?? false;
  }

  static Future<void> _show({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String buttonText,
    required Color buttonColor,
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: _insetPadding(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: _iconSize(context)),
                const SizedBox(height: 16),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onClose?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @Deprecated('Use showSuccess, showError, showWarning, or showConfirm instead')
  static Future<void> show({
    required BuildContext context,
    required DialogType type,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    switch (type) {
      case DialogType.success:
        return showSuccess(context, title: title, message: message,
            onClose: onConfirm);
      case DialogType.error:
        return showError(context, title: title, message: message,
            onClose: onConfirm);
      case DialogType.warning:
        return showWarning(context, title: title, message: message,
            onClose: onConfirm);
      case DialogType.confirm:
        return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _CustomDialogContent(
            type: type,
            title: title,
            message: message,
            onConfirm: onConfirm,
            onCancel: onCancel,
          ),
        );
    }
  }
}

enum DialogType { success, error, warning, confirm }

class _CustomDialogContent extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _CustomDialogContent({
    required this.type,
    required this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    IconData getIcon() {
      switch (type) {
        case DialogType.success:
          return Icons.check_circle_rounded;
        case DialogType.error:
          return Icons.cancel_rounded;
        case DialogType.warning:
          return Icons.warning_rounded;
        case DialogType.confirm:
          return Icons.help_rounded;
      }
    }

    Color getColor() {
      switch (type) {
        case DialogType.success:
          return const Color(0xFF2E7D32);
        case DialogType.error:
          return const Color(0xFFC62828);
        case DialogType.warning:
          return const Color(0xFFF57C00);
        case DialogType.confirm:
          return const Color(0xFF0288D1);
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(getIcon(), color: getColor(), size: 64),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            if (type == DialogType.confirm) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onCancel?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0288D1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColor(),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
