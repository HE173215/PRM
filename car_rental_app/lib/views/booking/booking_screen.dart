import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'booking_success_screen.dart';

class BookingScreen extends StatefulWidget {
  final CarModel car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService bookingService = BookingService();
  final TextEditingController noteController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> selectStartDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      startDate = selected;
      if (endDate != null && !endDate!.isAfter(startDate!)) {
        endDate = null;
      }
    });
  }

  Future<void> selectEndDate() async {
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày nhận xe trước'),
          backgroundColor: AppColors.amber,
        ),
      );
      return;
    }

    final minEndDate = startDate!.add(const Duration(days: 1));
    final selected = await showDatePicker(
      context: context,
      initialDate: endDate ?? minEndDate,
      firstDate: minEndDate,
      lastDate: startDate!.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.secondary,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null) return;

    setState(() {
      endDate = selected;
    });
  }

  int get totalDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays;
  }

  double get estimatedTotal {
    return totalDays * widget.car.pricePerDay;
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> submitBooking() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày nhận và ngày trả xe'),
          backgroundColor: AppColors.amber,
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final booking = await bookingService.createBooking(
        carId: widget.car.id,
        startDate: startDate!,
        endDate: endDate!,
        note: noteController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(booking: booking),
        ),
      );
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
          isLoading = false;
        });
      }
    }
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
        title: const Text('Xác nhận đặt xe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Summary Header Card
            _buildCarHeaderCard(),
            const SizedBox(height: 24),

            // Rental Dates Selection
            const Text(
              'Thời gian thuê xe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildDateSelector(),
            const SizedBox(height: 24),

            // Additional Notes
            const Text(
              'Ghi chú thêm (Tùy chọn)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: noteController,
              hintText: 'Yêu cầu điểm giao nhận, thời gian cụ thể...',
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // Price Breakdown Card
            _buildPriceBreakdownCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCarHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.car.image.isNotEmpty
                ? Image.network(
                    widget.car.image,
                    width: 85,
                    height: 75,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.car.brand.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.car.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatPerDay(widget.car.pricePerDay),
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
    );
  }

  Widget _carPlaceholder() {
    return Container(
      width: 85,
      height: 75,
      color: AppColors.surfaceLight,
      child: const Icon(
        Icons.directions_car_rounded,
        color: AppColors.textMuted,
        size: 32,
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  title: 'Ngày nhận xe',
                  dateStr: formatDate(startDate),
                  isSelected: startDate != null,
                  onTap: selectStartDate,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: _buildDateTile(
                  title: 'Ngày trả xe',
                  dateStr: formatDate(endDate),
                  isSelected: endDate != null,
                  onTap: selectEndDate,
                ),
              ),
            ],
          ),
          if (totalDays > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.emerald.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.emerald.withAlpha(70)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 16, color: AppColors.emerald),
                  const SizedBox(width: 6),
                  Text(
                    'Thời lượng thuê: $totalDays ngày ($totalDays đêm)',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required String title,
    required String dateStr,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: isSelected ? AppColors.secondary : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return Container(
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
            'Bảng kê chi phí dự kiến',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _priceRow(
            label: 'Đơn giá thuê',
            value: CurrencyFormatter.formatPerDay(widget.car.pricePerDay),
          ),
          const SizedBox(height: 10),
          _priceRow(
            label: 'Số ngày thuê',
            value: '$totalDays ngày',
          ),
          const SizedBox(height: 10),
          _priceRow(
            label: 'Bảo hiểm vật chất',
            value: 'Đã bao gồm',
            valueColor: AppColors.emerald,
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
                CurrencyFormatter.format(estimatedTotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.secondary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
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

  Widget _buildBottomBar() {
    return Container(
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
                  'Tổng cộng',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  CurrencyFormatter.format(estimatedTotal),
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
                text: 'Xác nhận đặt xe',
                isLoading: isLoading,
                onPressed: submitBooking,
                icon: Icons.check_circle_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}