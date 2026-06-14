import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusChip({super.key, required this.status, this.fontSize});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: config.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              fontSize: fontSize ?? 11,
              fontWeight: FontWeight.bold,
              color: config.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _config(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return _StatusConfig(Colors.green, 'APPROVED');
      case 'declined':
        return _StatusConfig(Colors.red, 'DECLINED');
      case 'pending':
        return _StatusConfig(Colors.orange, 'PENDING');
      case 'abandoned':
        return _StatusConfig(Colors.grey, 'ABANDONED');
      case 'invalidated':
        return _StatusConfig(Colors.deepPurple, 'INVALIDATED');
      case 'active':
        return _StatusConfig(Colors.green, 'ACTIVE');
      case 'inactive':
        return _StatusConfig(Colors.red, 'INACTIVE');
      default:
        return _StatusConfig(Colors.blue, status.toUpperCase());
    }
  }
}

class _StatusConfig {
  final Color color;
  final String label;
  _StatusConfig(this.color, this.label);
}
