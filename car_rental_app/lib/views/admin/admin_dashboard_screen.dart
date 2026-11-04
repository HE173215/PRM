import 'package:flutter/material.dart';

import '../../services/admin_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';
import 'admin_booking_list_screen.dart';
import 'admin_car_list_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_user_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService adminService = AdminService();

  DashboardStats? stats;
  List<TopCarItem> topCars = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final results = await Future.wait([
        adminService.getDashboardStats(),
        adminService.getTopCars(limit: 5).catchError((_) => <TopCarItem>[]),
      ]);

      if (!mounted) return;

      setState(() {
        stats = results[0] as DashboardStats;
        topCars = results[1] as List<TopCarItem>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Admin CMS & Dashboard',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: loadDashboardData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
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
        title: 'Lỗi tải Dashboard',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadDashboardData,
      );
    }

    final data = stats;
    if (data == null) {
      return const EmptyStateWidget(
        title: 'Không có dữ liệu',
        message: 'Không thể kết nối dữ liệu quản trị',
      );
    }

    return RefreshIndicator(
      onRefresh: loadDashboardData,
      color: AppColors.secondary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Revenue Hero Card
            _buildRevenueCard(data.totalRevenue),
            const SizedBox(height: 20),

            // CMS Navigation Grid
            const Text(
              'Phân hệ quản trị',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildNavigationGrid(),
            const SizedBox(height: 24),

            // Booking Statistics Overview
            const Text(
              'Tổng quan đơn thuê',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildBookingStatsGrid(data),
            const SizedBox(height: 24),

            // Vehicle Fleet Statistics
            const Text(
              'Trạng thái đội xe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildCarStatsGrid(data),
            const SizedBox(height: 24),

            // Top Rented Cars Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Xe được thuê nhiều nhất',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminReportsScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Xem báo cáo',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTopCarsList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withAlpha(110), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withAlpha(28),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.emerald.withAlpha(90)),
                ),
                child: const Text(
                  'TỔNG DOANH THU THỰC TẾ',
                  style: TextStyle(
                    color: AppColors.emerald,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Icon(
                Icons.trending_up_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.format(revenue),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Chỉ ghi nhận từ các đơn thuê đã thanh toán thành công',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildNavCard(
          title: 'Quản lý Xe',
          subtitle: '${stats?.totalCars ?? 0} xe trong hệ thống',
          icon: Icons.directions_car_rounded,
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminCarListScreen()),
            );
          },
        ),
        _buildNavCard(
          title: 'Quản lý Đơn thuê',
          subtitle: '${stats?.totalBookings ?? 0} đơn đặt',
          icon: Icons.receipt_long_rounded,
          color: AppColors.primaryLight,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminBookingListScreen()),
            );
          },
        ),
        _buildNavCard(
          title: 'Quản lý User',
          subtitle: '${stats?.totalUsers ?? 0} người dùng',
          icon: Icons.people_alt_rounded,
          color: AppColors.amber,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
            );
          },
        ),
        _buildNavCard(
          title: 'Báo cáo & Thống kê',
          subtitle: 'Doanh thu & Top xe',
          icon: Icons.bar_chart_rounded,
          color: AppColors.emerald,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildBookingStatsGrid(DashboardStats data) {
    return Container(
      padding: const EdgeInsets.all(18),
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
                child: _buildMiniStat(
                  'Tổng đơn',
                  '${data.totalBookings}',
                  AppColors.textPrimary,
                  Icons.all_inbox_rounded,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  'Chờ duyệt',
                  '${data.pendingBookings}',
                  AppColors.amber,
                  Icons.hourglass_top_rounded,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  'Đã xác nhận',
                  '${data.confirmedBookings}',
                  AppColors.secondary,
                  Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.surfaceBorder),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Đang thuê',
                  '${data.ongoingBookings}',
                  AppColors.primaryLight,
                  Icons.directions_car_filled_rounded,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  'Hoàn thành',
                  '${data.completedBookings}',
                  AppColors.emerald,
                  Icons.task_alt_rounded,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  'Đã hủy',
                  '${data.cancelledBookings}',
                  AppColors.rose,
                  Icons.cancel_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarStatsGrid(DashboardStats data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              'Tổng xe',
              '${data.totalCars}',
              AppColors.textPrimary,
              Icons.garage_rounded,
            ),
          ),
          Expanded(
            child: _buildMiniStat(
              'Sẵn sàng',
              '${data.availableCars}',
              AppColors.emerald,
              Icons.check_circle_rounded,
            ),
          ),
          Expanded(
            child: _buildMiniStat(
              'Đang thuê',
              '${data.rentedCars}',
              AppColors.secondary,
              Icons.car_rental_rounded,
            ),
          ),
          Expanded(
            child: _buildMiniStat(
              'Bảo dưỡng',
              '${data.maintenanceCars}',
              AppColors.amber,
              Icons.build_circle_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopCarsList() {
    if (topCars.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: const Center(
          child: Text(
            'Chưa có dữ liệu thống kê xe thuê nhiều',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: topCars.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.bookingCount} lượt thuê',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(item.revenue),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
