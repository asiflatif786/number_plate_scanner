import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;
  final bool isSelectable;
  final Color? valueColor;
  final FontWeight? fontWeight;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.isSelectable = false,
    this.valueColor,
    this.fontWeight,
    this.trailingIcon,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: valueColor ?? const Color(0xFF212121),
      fontFamily: isMonospace ? 'monospace' : null,
      letterSpacing: isMonospace ? 1 : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: isSelectable
                ? SelectableText(
                    value.isEmpty ? 'N/A' : value,
                    style: textStyle,
                  )
                : Text(
                    value.isEmpty ? 'N/A' : value,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (trailingIcon != null)
            InkWell(
              onTap: onTrailingTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(trailingIcon, size: 18, color: const Color(0xFF1A237E)),
              ),
            ),
        ],
      ),
    );
  }
}
