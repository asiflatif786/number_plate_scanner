import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isText;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? height;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isText = false,
    this.icon,
    this.color,
    this.textColor,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF1A237E);
    final effectiveTextColor = textColor ??
        (isOutlined || isText ? effectiveColor : Colors.white);
    final effectiveHeight = height ?? 50.0;

    Widget button;
    if (isText) {
      button = TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: effectiveTextColor,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          minimumSize: Size(0, effectiveHeight),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                  Text(label, style: TextStyle(fontSize: fontSize ?? 15, fontWeight: FontWeight.bold)),
                ],
              ),
      );
    } else if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(color: effectiveColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: Size(0, effectiveHeight),
        ),
        child: _buildContent(),
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveColor.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: Size(0, effectiveHeight),
        ),
        child: _buildContent(),
      );
    }

    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: 22, height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: fontSize ?? 15, fontWeight: FontWeight.bold)),
        ],
      );
    }
    return Text(label, style: TextStyle(fontSize: fontSize ?? 15, fontWeight: FontWeight.bold));
  }
}
