import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import 'payment_success_screen.dart';

class InvoiceScreen extends StatefulWidget {
  final BookingModel booking;

  const InvoiceScreen({super.key, required this.booking});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final BookingService bookingService = BookingService();
  bool isProcessing = false;

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void confirmPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thanh toán'),
        content: const Text(
          'Bạn có chắc chắn muốn xác nhận đã thanh toán cho đơn thuê này không?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              handleMarkAsPaid();
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> handleMarkAsPaid() async {
    try {
      setState(() {
        isProcessing = true;
      });

      final updatedBooking = await bookingService.markAsPaid(widget.booking.id);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(booking: updatedBooking),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: AppColors.rose,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isPaid = booking.paymentStatus.toLowerCase() == 'paid';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Hóa đơn điện tử'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          children: [
            // Invoice Card (Ticket style)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Invoice Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_rounded,
                            color: AppColors.secondary,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'HÓA ĐƠN THUÊ XE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã hóa đơn: #${booking.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dashed divider line with cutouts
                  _buildDashedLineWithNotches(),

                  // Invoice Details
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle Info
                        _invoiceRow('Xe thuê', booking.car.name, isBold: true),
                        const SizedBox(height: 12),
                        _invoiceRow('Hãng sản xuất', booking.car.brand),
                        const SizedBox(height: 12),
                        _invoiceRow('Ngày nhận xe', formatDate(booking.startDate)),
                        const SizedBox(height: 12),
                        _invoiceRow('Ngày trả xe', formatDate(booking.endDate)),
                        const SizedBox(height: 12),
                        _invoiceRow('Thời gian thuê', '${booking.totalDays} ngày'),
                        const SizedBox(height: 12),
                        _invoiceRow(
                          'Đơn giá',
                          CurrencyFormatter.formatPerDay(booking.pricePerDay),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Trạng thái đơn',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            StatusBadge(status: booking.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Trạng thái thanh toán',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            StatusBadge(
                              status: booking.paymentStatus,
                              isPayment: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1, color: AppColors.surfaceBorder),
                        const SizedBox(height: 20),

                        // Total Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TỔNG THANH TOÁN',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(booking.totalAmount),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Stamp / Watermark when already paid
                  if (isPaid) ...[
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.emerald.withAlpha(80), width: 1.5),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_rounded, color: AppColors.emerald, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'HÓA ĐƠN ĐÃ ĐƯỢC THANH TOÁN',
                            style: TextStyle(
                              color: AppColors.emerald,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            if (!isPaid) ...[
              CustomButton(
                text: 'Đã thanh toán',
                icon: Icons.check_circle_outline_rounded,
                isLoading: isProcessing,
                onPressed: isProcessing ? null : confirmPayment,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Quay lại',
                isOutlined: true,
                onPressed: isProcessing ? null : () => Navigator.pop(context),
              ),
            ] else ...[
              CustomButton(
                text: 'Quay lại',
                isOutlined: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDashedLineWithNotches() {
    return Row(
      children: [
        // Left cutout notch
        Container(
          width: 14,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
        ),
        // Dashed middle divider
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 6.0;
              const dashSpace = 4.0;
              final dashCount = (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (_) {
                  return const SizedBox(
                    width: dashWidth,
                    height: 1.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.surfaceBorder),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        // Right cutout notch
        Container(
          width: 14,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _invoiceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
