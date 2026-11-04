import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';
import 'invoice_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'mock';

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> proceedToInvoice() async {
    if (widget.booking.status.toLowerCase() == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đơn thuê đã bị hủy, không thể thực hiện thanh toán'),
          backgroundColor: AppColors.rose,
        ),
      );
      return;
    }

    if (widget.booking.paymentStatus.toLowerCase() == 'paid') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đơn thuê này đã được thanh toán trước đó'),
          backgroundColor: AppColors.emerald,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceScreen(booking: widget.booking),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final isCancelled = booking.status.toLowerCase() == 'cancelled';
    final isPaid = booking.paymentStatus.toLowerCase() == 'paid';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thanh toán đơn thuê'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.car.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã đơn: #${booking.id}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.surfaceBorder),
                  const SizedBox(height: 14),
                  _rowItem('Hãng xe', booking.car.brand),
                  const SizedBox(height: 10),
                  _rowItem('Ngày nhận xe', formatDate(booking.startDate)),
                  const SizedBox(height: 10),
                  _rowItem('Ngày trả xe', formatDate(booking.endDate)),
                  const SizedBox(height: 10),
                  _rowItem('Số ngày thuê', '${booking.totalDays} ngày'),
                  const SizedBox(height: 10),
                  _rowItem('Đơn giá', CurrencyFormatter.formatPerDay(booking.pricePerDay)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trạng thái thanh toán',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      StatusBadge(status: booking.paymentStatus, isPayment: true),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods Selection (Mock)
            const Text(
              'Phương thức thanh toán',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodOption(
              id: 'mock',
              title: 'Thanh toán giả lập (Mock Payment)',
              subtitle: 'Xác nhận thanh toán mô phỏng cho đồ án',
              icon: Icons.speed_rounded,
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodOption(
              id: 'cash',
              title: 'Tiền mặt khi nhận xe',
              subtitle: 'Thanh toán trực tiếp cho nhân viên giao xe',
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 10),
            _buildPaymentMethodOption(
              id: 'bank',
              title: 'Chuyển khoản ngân hàng (Mock)',
              subtitle: 'Mô phỏng chuyển khoản trực tiếp',
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 24),

            // Warning Notice if cancelled or paid
            if (isCancelled)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.rose.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.rose.withAlpha(60)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.rose, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Đơn thuê đã bị hủy. Không thể thực hiện thanh toán.',
                        style: TextStyle(color: AppColors.rose, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else if (isPaid)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.emerald.withAlpha(60)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.emerald, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Đơn thuê này đã được thanh toán hoàn tất.',
                        style: TextStyle(color: AppColors.emerald, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(120),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số tiền thanh toán',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  text: 'Thanh toán',
                  icon: Icons.receipt_long_rounded,
                  onPressed: (!isCancelled && !isPaid) ? proceedToInvoice : null,
                  backgroundColor: (!isCancelled && !isPaid) ? null : AppColors.surfaceLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedMethod == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.secondary.withAlpha(30)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.secondary : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
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
