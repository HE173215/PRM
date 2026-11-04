import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final AdminService adminService = AdminService();

  int selectedYear = DateTime.now().year;
  List<RevenueMonth> revenueData = [];
  Map<String, dynamic>? bookingStats;
  List<TopCarItem> topCars = [];

  bool isLoading = true;
  String? errorMessage;

  final List<int> availableYears = [2024, 2025, 2026, 2027];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    loadAllReports();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> loadAllReports() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final results = await Future.wait([
        adminService.getRevenueReport(year: selectedYear).catchError((_) => <RevenueMonth>[]),
        adminService.getBookingStats().catchError((_) => <String, dynamic>{}),
        adminService.getTopCars(limit: 10).catchError((_) => <TopCarItem>[]),
      ]);

      if (!mounted) return;

      setState(() {
        revenueData = results[0] as List<RevenueMonth>;
        bookingStats = results[1] as Map<String, dynamic>;
        topCars = results[2] as List<TopCarItem>;
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

  Future<void> loadRevenueForYear(int year) async {
    setState(() {
      selectedYear = year;
    });

    try {
      final res = await adminService.getRevenueReport(year: year);
      if (!mounted) return;
      setState(() {
        revenueData = res;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải doanh thu năm $year: $error')),
      );
    }
  }

  double get totalYearRevenue {
    return revenueData.fold(0.0, (sum, item) => sum + item.revenue);
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
          'Báo cáo & Thống kê',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        bottom: TabBar(
          controller: tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Doanh thu'),
            Tab(text: 'Đơn thuê'),
            Tab(text: 'Top xe thuê'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
          : errorMessage != null
              ? EmptyStateWidget(
                  icon: Icons.error_outline_rounded,
                  title: 'Lỗi tải báo cáo',
                  message: errorMessage!,
                  buttonText: 'Thử lại',
                  onButtonPressed: loadAllReports,
                )
              : TabBarView(
                  controller: tabController,
                  children: [
                    _buildRevenueTab(),
                    _buildBookingTab(),
                    _buildTopCarsTab(),
                  ],
                ),
    );
  }

  // TAB 1: DOANH THU THEO THÁNG
  Widget _buildRevenueTab() {
    return RefreshIndicator(
      onRefresh: () => loadRevenueForYear(selectedYear),
      color: AppColors.secondary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn năm báo cáo:',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: DropdownButton<int>(
                    value: selectedYear,
                    dropdownColor: AppColors.surface,
                    underline: const SizedBox.shrink(),
                    items: availableYears.map((y) {
                      return DropdownMenuItem<int>(
                        value: y,
                        child: Text(
                          'Năm $y',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) loadRevenueForYear(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Year Revenue Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.primaryLight.withAlpha(70)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TỔNG DOANH THU NĂM $selectedYear',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.emerald,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    CurrencyFormatter.format(totalYearRevenue),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tổng hợp dữ liệu doanh thu các giao dịch đã hoàn tất',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Breakdown List
            const Text(
              'Chi tiết 12 tháng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildMonthlyBars(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBars() {
    // Tìm doanh thu lớn nhất để tính tỉ lệ phần trăm thanh bar
    double maxRevenue = 1;
    for (final item in revenueData) {
      if (item.revenue > maxRevenue) maxRevenue = item.revenue;
    }

    return Column(
      children: List.generate(12, (index) {
        final monthNumber = index + 1;
        final monthItem = revenueData.firstWhere(
          (item) => item.month == monthNumber,
          orElse: () => RevenueMonth(month: monthNumber, revenue: 0),
        );

        final percent = (monthItem.revenue / maxRevenue).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tháng $monthNumber',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(monthItem.revenue),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: monthItem.revenue > 0 ? AppColors.secondary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    monthItem.revenue > 0 ? AppColors.secondary : AppColors.surfaceBorder,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // TAB 2: THỐNG KÊ ĐƠN THUÊ
  Widget _buildBookingTab() {
    final stats = bookingStats;
    if (stats == null) {
      return const EmptyStateWidget(
        title: 'Chưa có thống kê',
        message: 'Không tìm thấy dữ liệu thống kê đơn thuê.',
      );
    }

    final total = stats['total'] ?? 0;
    final byStatus = stats['byStatus'] as Map<String, dynamic>? ?? {};

    final pending = byStatus['pending'] ?? 0;
    final confirmed = byStatus['confirmed'] ?? 0;
    final ongoing = byStatus['ongoing'] ?? byStatus['in_progress'] ?? 0;
    final completed = byStatus['completed'] ?? 0;
    final cancelled = byStatus['cancelled'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Bookings Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TỔNG SỐ ĐƠN THUÊ', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('$total đơn', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.secondary, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Phân bố theo trạng thái',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),

          _buildStatusProgressTile('Chờ xác nhận (Pending)', pending, total, AppColors.amber),
          _buildStatusProgressTile('Đã xác nhận (Confirmed)', confirmed, total, AppColors.secondary),
          _buildStatusProgressTile('Đang thuê (Ongoing)', ongoing, total, AppColors.primaryLight),
          _buildStatusProgressTile('Hoàn thành (Completed)', completed, total, AppColors.emerald),
          _buildStatusProgressTile('Đã hủy (Cancelled)', cancelled, total, AppColors.rose),
        ],
      ),
    );
  }

  Widget _buildStatusProgressTile(String label, dynamic countVal, dynamic totalVal, Color color) {
    final count = (countVal as num?)?.toInt() ?? 0;
    final total = (totalVal as num?)?.toInt() ?? 1;
    final ratio = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final percentStr = (ratio * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                '$count đơn ($percentStr%)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: TOP XE THUÊ NHIỀU
  Widget _buildTopCarsTab() {
    if (topCars.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.directions_car_outlined,
        title: 'Chưa có dữ liệu Top xe',
        message: 'Hệ thống chưa ghi nhận lượt thuê xe thành công nào.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: topCars.length,
      itemBuilder: (context, index) {
        final item = topCars[index];
        final rank = index + 1;
        final isTop3 = rank <= 3;

        Color rankColor = AppColors.textMuted;
        if (rank == 1) rankColor = AppColors.amber;
        if (rank == 2) rankColor = Colors.grey.shade300;
        if (rank == 3) rankColor = Colors.brown.shade300;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isTop3 ? rankColor.withAlpha(80) : AppColors.surfaceBorder,
              width: isTop3 ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isTop3 ? rankColor.withAlpha(30) : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: rankColor),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isTop3 ? rankColor : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.bookingCount} lượt thuê thành công',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Revenue generated
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Doanh thu', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
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
            ],
          ),
        );
      },
    );
  }
}
