import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/status_badge.dart';
import '../booking/booking_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final BookingService bookingService = BookingService();
  bool isLoading = true;
  String? errorMessage;
  List<BookingModel> bookings = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final result = await bookingService.getMyBookings();
      if (!mounted) return;
      setState(() {
        bookings = result;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<_NotificationItem> get notifications {
    final now = DateTime.now();
    final items = <_NotificationItem>[];

    for (final booking in bookings) {
      final status = booking.status.toLowerCase();
      final payment = booking.paymentStatus.toLowerCase();
      if (status == 'pending') {
        items.add(
          _NotificationItem(
            icon: Icons.hourglass_top_rounded,
            color: AppColors.amber,
            title: 'Đơn đang chờ xác nhận',
            message: 'Đơn #${booking.id} đang chờ admin xử lý.',
            booking: booking,
          ),
        );
      } else if (status == 'confirmed') {
        items.add(
          _NotificationItem(
            icon: Icons.verified_rounded,
            color: AppColors.secondary,
            title: 'Đơn đã được xác nhận',
            message: 'Xe ${booking.car.name} đã sẵn sàng cho chuyến đi.',
            booking: booking,
          ),
        );
      } else if (status == 'cancelled') {
        items.add(
          _NotificationItem(
            icon: Icons.cancel_rounded,
            color: AppColors.rose,
            title: 'Đơn đã bị hủy',
            message: 'Đơn #${booking.id} đã được chuyển sang trạng thái hủy.',
            booking: booking,
          ),
        );
      }

      if (payment == 'paid') {
        items.add(
          _NotificationItem(
            icon: Icons.payments_rounded,
            color: AppColors.emerald,
            title: 'Thanh toán thành công',
            message: 'Đơn #${booking.id} đã được ghi nhận thanh toán.',
            booking: booking,
          ),
        );
      } else if (payment == 'refund_requested') {
        items.add(
          _NotificationItem(
            icon: Icons.assignment_late_rounded,
            color: AppColors.amber,
            title: 'Yêu cầu hoàn tiền đang xử lý',
            message: 'Admin đang xem xét yêu cầu hoàn tiền của bạn.',
            booking: booking,
          ),
        );
      } else if (payment == 'refunded') {
        items.add(
          _NotificationItem(
            icon: Icons.currency_exchange_rounded,
            color: AppColors.secondary,
            title: 'Đã hoàn tiền',
            message: 'Khoản tiền của đơn #${booking.id} đã được hoàn.',
            booking: booking,
          ),
        );
      }

      final daysUntilPickup = booking.startDate.difference(now).inDays;
      if (daysUntilPickup >= 0 &&
          daysUntilPickup <= 3 &&
          status != 'cancelled' &&
          status != 'completed') {
        items.add(
          _NotificationItem(
            icon: Icons.event_available_rounded,
            color: AppColors.primary,
            title: 'Sắp đến ngày nhận xe',
            message:
                'Bạn sẽ nhận xe vào ngày ${_formatDate(booking.startDate)}.',
            booking: booking,
          ),
        );
      }
    }

    return items;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final items = notifications;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            onPressed: loadNotifications,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : items.isEmpty
          ? const Center(
              child: Text(
                'Chưa có thông báo mới',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildNotification(items[index]);
              },
            ),
    );
  }

  Widget _buildNotification(_NotificationItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(bookingId: item.booking.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: item.color, size: 23),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(status: item.booking.status),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final BookingModel booking;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.booking,
  });
}
