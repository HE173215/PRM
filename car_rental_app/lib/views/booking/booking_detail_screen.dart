import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../payment/invoice_screen.dart';
import '../payment/payment_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService bookingService = BookingService();

  BookingModel? booking;
  bool isLoading = true;
  bool isCancelling = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadBooking();
  }

  Future<void> loadBooking() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await bookingService.getBookingById(widget.bookingId);
      if (!mounted) return;

      setState(() {
        booking = result;
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

  Future<void> cancelBooking() async {
    try {
      setState(() {
        isCancelling = true;
      });

      await bookingService.cancelBooking(widget.bookingId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hủy đơn thuê thành công'),
          backgroundColor: AppColors.emerald,
        ),
      );

      await loadBooking();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.rose,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCancelling = false;
        });
      }
    }
  }

  void showCancelConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy đơn'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy đơn thuê xe này không? Hành động này không thể hoàn tác.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Giữ lại đơn'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            onPressed: () {
              Navigator.pop(context);
              cancelBooking();
            },
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chi tiết đơn thuê'),
        actions: [
          IconButton(
            onPressed: loadBooking,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Lỗi tải đơn thuê',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadBooking,
      );
    }

    final data = booking;
    if (data == null) {
      return const EmptyStateWidget(
        title: 'Không tìm thấy',
        message: 'Đơn thuê không tồn tại hoặc đã bị xóa',
      );
    }

    final canCancel = data.status == 'pending' || data.status == 'confirmed';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MÃ ĐƠN HÀNG',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#${data.id}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: data.status),
            ],
          ),
          const SizedBox(height: 24),

          // Status Progress Stepper
          _buildProgressStepper(data.status),
          const SizedBox(height: 24),

          // Car Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: data.car.image.isNotEmpty
                      ? Image.network(
                          data.car.image,
                          width: 80,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _carPlaceholder(),
                        )
                      : _carPlaceholder(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.car.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.car.brand} • ${data.car.seats} chỗ • ${data.car.transmission}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatPerDay(data.pricePerDay),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Schedule Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch trình chuyến đi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _infoRow('Ngày nhận xe', formatDate(data.startDate)),
                const SizedBox(height: 10),
                _infoRow('Ngày trả xe', formatDate(data.endDate)),
                const SizedBox(height: 10),
                _infoRow('Tổng thời gian', '${data.totalDays} ngày'),
                if (data.note.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _infoRow('Ghi chú', data.note),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment Summary Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chi tiết thanh toán',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _infoRow('Giá thuê', CurrencyFormatter.formatPerDay(data.pricePerDay)),
                const SizedBox(height: 10),
                _infoRow('Số ngày', '${data.totalDays} ngày'),
                const SizedBox(height: 10),
                _infoRow('Bảo hiểm', 'Bao gồm', valueColor: AppColors.emerald),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trạng thái thanh toán',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    StatusBadge(status: data.paymentStatus, isPayment: true),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(data.totalAmount),
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

          // Phase 6: Payment Actions
          if (data.paymentStatus.toLowerCase() == 'unpaid' && data.status.toLowerCase() != 'cancelled') ...[
            const SizedBox(height: 28),
            CustomButton(
              text: 'Thanh toán ngay',
              icon: Icons.payment_rounded,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(booking: data),
                  ),
                );
                loadBooking();
              },
            ),
          ] else if (data.paymentStatus.toLowerCase() == 'paid') ...[
            const SizedBox(height: 28),
            CustomButton(
              text: 'Xem hóa đơn điện tử',
              icon: Icons.receipt_long_rounded,
              isOutlined: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InvoiceScreen(booking: data),
                  ),
                );
              },
            ),
          ],

          // Cancel Action
          if (canCancel) ...[
            const SizedBox(height: 14),
            CustomButton(
              text: 'Hủy đơn thuê này',
              isOutlined: true,
              isLoading: isCancelling,
              icon: Icons.cancel_outlined,
              backgroundColor: AppColors.rose.withAlpha(20),
              onPressed: showCancelConfirmDialog,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStepper(String status) {
    final steps = ['Chờ duyệt', 'Đã duyệt', 'Đang thuê', 'Hoàn tất'];
    int activeIndex = 0;
    final s = status.toLowerCase();
    if (s == 'confirmed') activeIndex = 1;
    if (s == 'in_progress') activeIndex = 2;
    if (s == 'completed') activeIndex = 3;
    if (s == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.rose.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.rose.withAlpha(60)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.rose, size: 18),
            SizedBox(width: 8),
            Text(
              'Đơn thuê này đã bị hủy',
              style: TextStyle(color: AppColors.rose, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isDone = index <= activeIndex;
          final isCurrent = index == activeIndex;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index != 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index <= activeIndex
                              ? AppColors.secondary
                              : AppColors.surfaceBorder,
                        ),
                      ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.secondary : AppColors.surfaceLight,
                        border: Border.all(
                          color: isCurrent
                              ? Colors.white
                              : (isDone ? AppColors.secondary : AppColors.surfaceBorder),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isDone ? Icons.check : Icons.circle,
                        size: 12,
                        color: isDone ? Colors.black : AppColors.textMuted,
                      ),
                    ),
                    if (index != steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < activeIndex
                              ? AppColors.secondary
                              : AppColors.surfaceBorder,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isDone ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _carPlaceholder() {
    return Container(
      width: 80,
      height: 70,
      color: AppColors.surfaceLight,
      child: const Icon(
        Icons.directions_car_rounded,
        color: AppColors.textSecondary,
        size: 30,
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
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
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
