import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class AppText extends StatelessWidget {
  final String text;
  final double baseSize;
  final FontWeight weight;
  final Color? color;
  final TextAlign align;
  final int? maxLines;
  final TextOverflow overflow;

  const AppText({
    super.key,
    required this.text,
    required this.baseSize,
    this.weight = FontWeight.normal,
    this.color,
    this.align = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ResponsiveHelper.fontSize(context, baseSize),
        fontWeight: weight,
        color: color,
      ),
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
