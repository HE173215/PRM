import 'package:flutter/material.dart';

import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import 'admin_booking_detail_screen.dart';

class AdminBookingListScreen extends StatefulWidget {
  const AdminBookingListScreen({super.key});

  @override
  State<AdminBookingListScreen> createState() => _AdminBookingListScreenState();
}

class _AdminBookingListScreenState extends State<AdminBookingListScreen> {
  final BookingService bookingService = BookingService();
  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;
  String? errorMessage;
  List<BookingModel> bookings = [];
  String selectedFilter = 'Tất cả';
  String selectedPaymentFilter = 'Tất cả';
  String selectedTimeFilter = 'Tất cả';
  String searchText = '';

  final List<String> filters = [
    'Tất cả',
    'pending',
    'confirmed',
    'ongoing',
    'completed',
    'cancelled',
  ];

  final List<String> paymentFilters = [
    'Tất cả',
    'paid',
    'unpaid',
    'refund_requested',
    'refunded',
  ];

  final List<String> timeFilters = ['Tất cả', 'upcoming', 'overdue'];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadBookings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await bookingService.getAllBookings();
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
    return bookings.where((b) {
      final keyword = searchText.toLowerCase().trim();
      final matchesSearch =
          keyword.isEmpty ||
          b.car.name.toLowerCase().contains(keyword) ||
          b.id.toLowerCase().contains(keyword);

      final matchesStatus =
          selectedFilter == 'Tất cả' ||
          b.status.toLowerCase() == selectedFilter.toLowerCase();

      final matchesPayment =
          selectedPaymentFilter == 'Tất cả' ||
          b.paymentStatus.toLowerCase() == selectedPaymentFilter.toLowerCase();

      final now = DateTime.now();
      final isUpcoming =
          b.startDate.isAfter(now) &&
          b.startDate.difference(now).inDays <= 3 &&
          b.status.toLowerCase() != 'cancelled';
      final isOverdue =
          b.endDate.isBefore(now) && b.status.toLowerCase() == 'ongoing';
      final matchesTime =
          selectedTimeFilter == 'Tất cả' ||
          (selectedTimeFilter == 'upcoming' && isUpcoming) ||
          (selectedTimeFilter == 'overdue' && isOverdue);

      return matchesSearch && matchesStatus && matchesPayment && matchesTime;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý Đơn thuê',
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
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => setState(() => searchText = val),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm theo mã đơn hoặc tên xe...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                  suffixIcon: searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            searchController.clear();
                            setState(() => searchText = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Booking Status Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_statusLabel(filter)),
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
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (_) => setState(() => selectedFilter = filter),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Payment Status Filter Chips
          SizedBox(
            height: 36,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: paymentFilters.length,
              itemBuilder: (context, index) {
                final pf = paymentFilters[index];
                final isSelected = selectedPaymentFilter == pf;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_paymentLabel(pf)),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.secondary.withAlpha(50),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.surfaceBorder,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (_) =>
                        setState(() => selectedPaymentFilter = pf),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Time-based filters
          SizedBox(
            height: 36,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: timeFilters.length,
              itemBuilder: (context, index) {
                final filter = timeFilters[index];
                final isSelected = selectedTimeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_timeLabel(filter)),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.amber.withAlpha(55),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.amber
                          : AppColors.surfaceBorder,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (_) =>
                        setState(() => selectedTimeFilter = filter),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hiển thị: ${filtered.length} đơn thuê',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (searchText.isNotEmpty ||
                    selectedFilter != 'Tất cả' ||
                    selectedPaymentFilter != 'Tất cả' ||
                    selectedTimeFilter != 'Tất cả')
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      setState(() {
                        searchText = '';
                        selectedFilter = 'Tất cả';
                        selectedPaymentFilter = 'Tất cả';
                        selectedTimeFilter = 'Tất cả';
                      });
                    },
                    child: const Text(
                      'Đặt lại bộ lọc',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),

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
        title: 'Lỗi tải danh sách',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadBookings,
      );
    }

    if (filtered.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.inbox_outlined,
        title: 'Không có đơn thuê phù hợp',
        message:
            'Không tìm thấy đơn nào khớp với các tiêu chí tìm kiếm và bộ lọc.',
      );
    }

    return RefreshIndicator(
      onRefresh: loadBookings,
      color: AppColors.secondary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final booking = filtered[index];
          return _buildAdminCard(booking);
        },
      ),
    );
  }

  Widget _buildAdminCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminBookingDetailScreen(bookingId: booking.id),
              ),
            );
            loadBookings();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: #${booking.id}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusBadge(status: booking.status),
                        const SizedBox(height: 4),
                        StatusBadge(
                          status: booking.paymentStatus,
                          isPayment: true,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${formatDate(booking.startDate)} → ${formatDate(booking.endDate)} (${booking.totalDays} ngày)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(booking.totalAmount),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
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

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'all':
      case 'tất cả':
        return 'Tất cả trạng thái';
      case 'pending':
        return 'Chờ duyệt';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'in_progress':
      case 'ongoing':
        return 'Đang thuê';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return s;
    }
  }

  String _paymentLabel(String p) {
    switch (p.toLowerCase()) {
      case 'all':
      case 'tất cả':
        return 'Tất cả TT';
      case 'paid':
        return 'Đã thanh toán';
      case 'unpaid':
        return 'Chưa thanh toán';
      case 'refund_requested':
        return 'Chờ hoàn tiền';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return p;
    }
  }

  String _timeLabel(String value) {
    switch (value) {
      case 'upcoming':
        return 'Sắp nhận xe';
      case 'overdue':
        return 'Quá hạn trả xe';
      default:
        return 'Tất cả thời gian';
    }
  }
}
