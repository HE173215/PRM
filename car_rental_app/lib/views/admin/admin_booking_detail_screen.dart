import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  final String bookingId;

  const AdminBookingDetailScreen({super.key, required this.bookingId});

  @override
  State<AdminBookingDetailScreen> createState() =>
      _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  final BookingService bookingService = BookingService();

  BookingModel? booking;
  bool isLoading = true;
  String? errorMessage;

  final List<String> availableStatuses = [
    'pending',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled',
  ];

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

  Future<void> updateStatus(String newStatus) async {
    try {
      setState(() {
        isLoading = true;
      });

      await bookingService.updateBookingStatus(widget.bookingId, newStatus);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật trạng thái thành "$newStatus" thành công'),
          backgroundColor: AppColors.emerald,
        ),
      );

      await loadBooking();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.rose,
        ),
      );
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void showUpdateConfirmDialog(String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận cập nhật'),
        content: Text(
          'Bạn có chắc muốn chuyển trạng thái đơn này thành "$newStatus"?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              updateStatus(newStatus);
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
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
        title: const Text('Chi tiết đơn (Admin)'),
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
        title: 'Lỗi tải đơn',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadBooking,
      );
    }

    final data = booking;
    if (data == null) {
      return const EmptyStateWidget(
        title: 'Không tìm thấy',
        message: 'Đơn thuê không tồn tại trong hệ thống',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHI TIẾT ĐƠN HÀNG',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold,
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: data.status),
            ],
          ),
          const SizedBox(height: 20),

          // Status Action Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryLight.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cập nhật trạng thái Booking',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: availableStatuses.contains(data.status.toLowerCase())
                      ? data.status.toLowerCase()
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Chọn trạng thái mới',
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                  ),
                  dropdownColor: AppColors.surface,
                  items: availableStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    if (newStatus != null && newStatus != data.status.toLowerCase()) {
                      showUpdateConfirmDialog(newStatus);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Vehicle & Schedule Info
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
                Text(
                  data.car.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _detailRow('Ngày nhận', formatDate(data.startDate)),
                const SizedBox(height: 10),
                _detailRow('Ngày trả', formatDate(data.endDate)),
                const SizedBox(height: 10),
                _detailRow('Số ngày thuê', '${data.totalDays} ngày'),
                const SizedBox(height: 10),
                _detailRow('Giá thuê/ngày', CurrencyFormatter.formatPerDay(data.pricePerDay)),
                const SizedBox(height: 10),
                _detailRow('Ghi chú', data.note.isNotEmpty ? data.note : 'Không có'),
                const SizedBox(height: 10),
                _detailRow('Thanh toán', data.paymentStatus, isBadge: true),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng số tiền',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(data.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBadge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
