import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPayment;

  const StatusBadge({
    super.key,
    required this.status,
    this.isPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status.toLowerCase());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withAlpha(35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: config.color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(String rawStatus) {
    if (isPayment) {
      switch (rawStatus) {
        case 'paid':
          return _StatusConfig(label: 'Đã thanh toán', color: AppColors.emerald);
        case 'pending':
        case 'unpaid':
          return _StatusConfig(label: 'Chưa thanh toán', color: AppColors.amber);
        case 'failed':
          return _StatusConfig(label: 'Thanh toán thất bại', color: AppColors.rose);
        case 'refunded':
          return _StatusConfig(label: 'Đã hoàn tiền', color: AppColors.secondary);
        default:
          return _StatusConfig(label: rawStatus.toUpperCase(), color: AppColors.textSecondary);
      }
    }

    switch (rawStatus) {
      case 'pending':
        return _StatusConfig(label: 'Chờ xác nhận', color: AppColors.amber);
      case 'confirmed':
        return _StatusConfig(label: 'Đã xác nhận', color: AppColors.secondary);
      case 'in_progress':
      case 'ongoing':
        return _StatusConfig(label: 'Đang thuê', color: AppColors.primaryLight);
      case 'completed':
        return _StatusConfig(label: 'Hoàn thành', color: AppColors.emerald);
      case 'cancelled':
        return _StatusConfig(label: 'Đã hủy', color: AppColors.rose);
      default:
        return _StatusConfig(label: rawStatus, color: AppColors.textSecondary);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  _StatusConfig({required this.label, required this.color});
}
