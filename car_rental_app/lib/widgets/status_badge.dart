import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPayment;

  const StatusBadge({super.key, required this.status, this.isPayment = false});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status.toLowerCase());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withAlpha(28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.color.withAlpha(90), width: 1),
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
              boxShadow: [
                BoxShadow(color: config.color.withAlpha(150), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label.toUpperCase(),
            style: TextStyle(
              color: config.color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  static String labelFor(String status, {bool isPayment = false}) {
    final normalizedStatus = status.toLowerCase();
    if (isPayment) {
      switch (normalizedStatus) {
        case 'paid':
          return 'Đã thanh toán';
        case 'pending':
        case 'unpaid':
          return 'Chưa thanh toán';
        case 'failed':
          return 'Thanh toán thất bại';
        case 'refunded':
          return 'Đã hoàn tiền';
        case 'refund_requested':
          return 'Chờ hoàn tiền';
      }
    } else {
      switch (normalizedStatus) {
        case 'pending':
          return 'Chờ duyệt';
        case 'confirmed':
          return 'Đã xác nhận';
        case 'in_progress':
        case 'ongoing':
          return 'Đang thuê';
        case 'completed':
          return 'Hoàn thành';
        case 'cancelled':
          return 'Đã hủy';
      }
    }

    return status;
  }

  _StatusConfig _getStatusConfig(String rawStatus) {
    if (isPayment) {
      switch (rawStatus) {
        case 'paid':
          return _StatusConfig(
            label: 'Đã thanh toán',
            color: AppColors.emerald,
          );
        case 'pending':
        case 'unpaid':
          return _StatusConfig(
            label: 'Chưa thanh toán',
            color: AppColors.amber,
          );
        case 'failed':
          return _StatusConfig(label: 'Thất bại', color: AppColors.rose);
        case 'refunded':
          return _StatusConfig(
            label: 'Đã hoàn tiền',
            color: AppColors.secondary,
          );
        case 'refund_requested':
          return _StatusConfig(label: 'Chờ hoàn tiền', color: AppColors.amber);
        default:
          return _StatusConfig(
            label: rawStatus,
            color: AppColors.textSecondary,
          );
      }
    }

    switch (rawStatus) {
      case 'pending':
        return _StatusConfig(label: 'Chờ duyệt', color: AppColors.amber);
      case 'confirmed':
        return _StatusConfig(label: 'Đã xác nhận', color: AppColors.secondary);
      case 'in_progress':
      case 'ongoing':
        return _StatusConfig(label: 'Đang thuê', color: AppColors.primary);
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
