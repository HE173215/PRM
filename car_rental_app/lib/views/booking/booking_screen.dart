import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import '../../models/booking_model.dart';
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
  List<BookingPeriod> bookedPeriods = [];
  bool isLoading = false;
  bool isAvailabilityLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final periods = await bookingService.getCarAvailability(widget.car.id);
      if (!mounted) return;
      setState(() {
        bookedPeriods = periods;
        isAvailabilityLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isAvailabilityLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.rose,
        ),
      );
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> selectStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: today,
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: (date) => _isStartDateAvailable(date),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
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
      selectableDayPredicate: (date) => _isEndDateAvailable(date),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
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

  bool _isStartDateAvailable(DateTime date) {
    return !bookedPeriods.any(
      (period) =>
          date.isBefore(period.endDate) && !date.isBefore(period.startDate),
    );
  }

  bool _isEndDateAvailable(DateTime date) {
    if (startDate == null) return false;

    return !bookedPeriods.any(
      (period) =>
          startDate!.isBefore(period.endDate) && date.isAfter(period.startDate),
    );
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

  String formatBookedPeriod(BookingPeriod period) {
    return '${formatDate(period.startDate)} - ${formatDate(period.endDate)}';
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('XÁC NHẬN ĐẶT XE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCarHeaderCard(),
            const SizedBox(height: 26),

            const Text(
              'LỊCH TRÌNH THUÊ XE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            _buildDateSelector(),
            const SizedBox(height: 26),

            const Text(
              'GHI CHÚ ĐẶC BIỆT (TÙY CHỌN)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: noteController,
              hintText: 'Yêu cầu điểm giao nhận, giờ nhận cụ thể...',
              maxLines: 3,
            ),
            const SizedBox(height: 26),

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
                    width: 90,
                    height: 76,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(28),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.car.brand.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.car.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatPerDay(widget.car.pricePerDay),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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
      width: 90,
      height: 76,
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
          if (isAvailabilityLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Đang tải lịch đặt xe...',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          if (!isAvailabilityLoading && bookedPeriods.isNotEmpty)
            _buildBookedPeriods(),
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  title: 'NHẬN XE',
                  dateStr: formatDate(startDate),
                  isSelected: startDate != null,
                  onTap: isAvailabilityLoading ? () {} : selectStartDate,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildDateTile(
                  title: 'TRẢ XE',
                  dateStr: formatDate(endDate),
                  isSelected: endDate != null,
                  onTap: isAvailabilityLoading ? () {} : selectEndDate,
                ),
              ),
            ],
          ),
          if (totalDays > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.emerald.withAlpha(24),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.emerald.withAlpha(80)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 16,
                    color: AppColors.emerald,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TỔNG THỜI LƯỢNG: $totalDays NGÀY ($totalDays ĐÊM)',
                    style: const TextStyle(
                      color: AppColors.emerald,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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

  Widget _buildBookedPeriods() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.rose.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.rose.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_busy_rounded, size: 16, color: AppColors.rose),
              SizedBox(width: 6),
              Text(
                'NGÀY ĐÃ CÓ LỊCH',
                style: TextStyle(
                  color: AppColors.rose,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            bookedPeriods.map(formatBookedPeriod).join('  •  '),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Các ngày này sẽ không thể chọn trong lịch.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BẢNG KÊ CHI PHÍ DỰ KIẾN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          _priceRow(
            label: 'Đơn giá thuê tiêu chuẩn',
            value: CurrencyFormatter.formatPerDay(widget.car.pricePerDay),
          ),
          const SizedBox(height: 10),
          _priceRow(label: 'Thời lượng thuê', value: '$totalDays ngày'),
          const SizedBox(height: 10),
          _priceRow(
            label: 'Bảo hiểm chuyến đi',
            value: 'MIỄN PHÍ',
            valueColor: AppColors.emerald,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TỔNG TẠM TÍNH',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                CurrencyFormatter.format(estimatedTotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
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
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
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
            color: Colors.black.withAlpha(150),
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
                  'TỔNG THANH TOÁN',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(estimatedTotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: CustomButton(
                text: 'XÁC NHẬN ĐẶT XE',
                isLoading: isLoading,
                onPressed: submitBooking,
                icon: Icons.check_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
