import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsets? padding;
  final Color? titleColor;
  final bool responsive;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding,
    this.titleColor,
    this.responsive = true,
  });

  @override
  Widget build(BuildContext context) {
    final actualPadding = padding ??
        (responsive
            ? EdgeInsets.all(ResponsiveHelper.cardPadding(context))
            : const EdgeInsets.all(16));
    final titleSize = responsive
        ? ResponsiveHelper.fontSize(context, 16)
        : 16.0;

    return Card(
      child: Padding(
        padding: actualPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: titleColor ?? const Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const Divider(height: 20, color: Color(0xFFE0E0E0)),
            child,
          ],
        ),
      ),
    );
  }
}
