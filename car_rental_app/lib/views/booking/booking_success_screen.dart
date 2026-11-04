import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import '../payment/payment_screen.dart';
import 'booking_detail_screen.dart';
import 'booking_history_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingSuccessScreen({super.key, required this.booking});

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Đặt xe thành công'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Success glowing icon
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald.withAlpha(30),
                  border: Border.all(color: AppColors.emerald.withAlpha(90), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withAlpha(60),
                      blurRadius: 30,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 50,
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Đặt xe thành công!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Yêu cầu của bạn đã được ghi nhận. Bạn có thể thanh toán ngay để xác nhận đơn thuê!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),

              // Receipt Ticket Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car name & brand
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.car.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.car.brand.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: AppColors.surfaceBorder, height: 1),
                    const SizedBox(height: 18),

                    // Trip Dates
                    _ticketRow('Ngày nhận', formatDate(booking.startDate)),
                    const SizedBox(height: 12),
                    _ticketRow('Ngày trả', formatDate(booking.endDate)),
                    const SizedBox(height: 12),
                    _ticketRow('Thời lượng', '${booking.totalDays} ngày'),
                    const SizedBox(height: 12),
                    _ticketRow(
                      'Thanh toán',
                      booking.paymentStatus,
                      isBadge: true,
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: AppColors.surfaceBorder, height: 1),
                    const SizedBox(height: 18),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng tiền thanh toán',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(booking.totalAmount),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Actions: Phase 6 Requirements
              // 1. Thanh toán ngay
              CustomButton(
                text: 'Thanh toán ngay',
                icon: Icons.payment_rounded,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(booking: booking),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // 2. Thanh toán sau -> Flow B: Điều hướng sang BookingHistoryScreen
              CustomButton(
                text: 'Thanh toán sau',
                isOutlined: true,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingHistoryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Secondary action: Xem chi tiết đơn
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailScreen(bookingId: booking.id),
                    ),
                  );
                },
                child: const Text(
                  'Xem chi tiết đơn thuê',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketRow(String label, String value, {bool isBadge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        if (isBadge)
          StatusBadge(status: value, isPayment: true)
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}
