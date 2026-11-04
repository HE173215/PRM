import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'booking_detail_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  final bool isTab;

  const BookingHistoryScreen({super.key, this.isTab = false});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final BookingService bookingService = BookingService();

  bool isLoading = true;
  String? errorMessage;
  List<BookingModel> bookings = [];
  String selectedFilter = 'Tất cả';

  final List<String> filters = [
    'Tất cả',
    'Chờ duyệt',
    'Đã xác nhận',
    'Đang thuê',
    'Hoàn thành',
    'Đã hủy',
  ];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

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

  List<BookingModel> get filteredBookings {
    if (selectedFilter == 'Tất cả') return bookings;

    return bookings.where((b) {
      switch (selectedFilter) {
        case 'Chờ duyệt':
          return b.status.toLowerCase() == 'pending';
        case 'Đã xác nhận':
          return b.status.toLowerCase() == 'confirmed';
        case 'Đang thuê':
          return b.status.toLowerCase() == 'in_progress';
        case 'Hoàn thành':
          return b.status.toLowerCase() == 'completed';
        case 'Đã hủy':
          return b.status.toLowerCase() == 'cancelled';
        default:
          return true;
      }
    }).toList();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredBookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        leading: !widget.isTab
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Đơn thuê của tôi',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: loadBookings,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Horizontal status filter chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.surfaceBorder,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Expanded(child: buildBody(filtered)),
        ],
      ),
    );
  }

  Widget buildBody(List<BookingModel> filtered) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Không thể tải đơn thuê',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadBookings,
      );
    }

    if (filtered.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: selectedFilter == 'Tất cả'
            ? 'Bạn chưa có đơn thuê nào'
            : 'Không có đơn thuê "$selectedFilter"',
        message: 'Hãy chọn xe bạn ưng ý và đặt ngay để bắt đầu hành trình!',
        buttonText: selectedFilter != 'Tất cả' ? 'Xem tất cả đơn' : null,
        onButtonPressed: selectedFilter != 'Tất cả'
            ? () {
                setState(() {
                  selectedFilter = 'Tất cả';
                });
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: loadBookings,
      color: AppColors.secondary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final booking = filtered[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailScreen(bookingId: booking.id),
              ),
            );
            loadBookings();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Car info & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: booking.car.image.isNotEmpty
                                ? Image.network(
                                    booking.car.image,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _carIcon(),
                                  )
                                : _carIcon(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.car.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mã đơn: #${booking.id.length > 8 ? booking.id.substring(booking.id.length - 8) : booking.id}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: booking.status),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                const SizedBox(height: 14),

                // Middle: Dates
                Row(
                  children: [
                    const Icon(
                      Icons.date_range_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${formatDate(booking.startDate)} → ${formatDate(booking.endDate)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${booking.totalDays} ngày',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom: Price & Arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Tổng: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          TextSpan(
                            text: CurrencyFormatter.format(booking.totalAmount),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Chi tiết',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.primaryLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _carIcon() {
    return Container(
      width: 48,
      height: 48,
      color: AppColors.surfaceLight,
      child: const Icon(
        Icons.directions_car_rounded,
        color: AppColors.textSecondary,
        size: 26,
      ),
    );
  }
}
