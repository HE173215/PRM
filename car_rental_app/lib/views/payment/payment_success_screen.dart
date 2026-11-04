import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import '../booking/booking_detail_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final BookingModel booking;

  const PaymentSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kết quả thanh toán'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Success glowing checkmark
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emerald.withAlpha(30),
                  border: Border.all(color: AppColors.emerald.withAlpha(90), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withAlpha(60),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 56,
                  color: AppColors.emerald,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Thanh toán thành công!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Đơn thuê của bạn đã được xác nhận. Chúc bạn có một hành trình an toàn và trọn vẹn!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Success Summary Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mã đơn thuê',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(
                          '#${booking.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tên xe',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(
                          booking.car.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trạng thái đơn',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const StatusBadge(status: 'confirmed'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thanh toán',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const StatusBadge(status: 'paid', isPayment: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.surfaceBorder),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Số tiền đã thanh toán',
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

              // Action Buttons
              CustomButton(
                text: 'Xem đơn thuê',
                icon: Icons.receipt_long_rounded,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingDetailScreen(bookingId: booking.id),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: 'Về trang chủ',
                isOutlined: true,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
