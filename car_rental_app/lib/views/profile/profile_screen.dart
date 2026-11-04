import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import '../admin/admin_dashboard_screen.dart';
import '../booking/booking_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isTab;

  const ProfileScreen({super.key, this.isTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();

  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await authService.getProfile();
      if (!mounted) return;

      setState(() {
        user = result['data'] as Map<String, dynamic>;
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

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất tài khoản'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi phiên làm việc hiện tại không?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await authService.logout();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        leading: !widget.isTab
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'HỒ SƠ CÁ NHÂN',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadProfile,
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
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Không thể tải thông tin',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadProfile,
      );
    }

    if (user == null) {
      return const EmptyStateWidget(
        title: 'Không có dữ liệu',
        message: 'Không tìm thấy hồ sơ người dùng',
      );
    }

    final fullName = user!['fullName'] ?? 'Người dùng';
    final email = user!['email'] ?? '';
    final phone = user!['phone'] ?? 'Chưa cập nhật';
    final role = user!['role'] ?? 'customer';
    final isAdmin = role == 'admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Neo-Minimalist Identity Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(70),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                          color: isAdmin
                              ? AppColors.amber.withAlpha(30)
                              : AppColors.secondary.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAdmin
                                ? AppColors.amber.withAlpha(90)
                                : AppColors.secondary.withAlpha(90),
                          ),
                        ),
                        child: Text(
                          isAdmin ? 'SYSTEM ADMIN' : 'VERIFIED MEMBER',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isAdmin
                                ? AppColors.amber
                                : AppColors.secondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Admin Console Access Banner
          if (isAdmin) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppColors.surface,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.terminal_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text(
                  'TRUNG TÂM QUẢN TRỊ // CMS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
                subtitle: const Text(
                  'Quản lý Đội xe, Đơn thuê, Người dùng & Báo cáo doanh thu',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.north_east_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboardScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Contact Information
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
                  'THÔNG TIN ĐỊNH DANH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 16),
                _profileDetailItem(
                  icon: Icons.alternate_email_rounded,
                  title: 'ĐỊA CHỈ EMAIL',
                  value: email,
                ),
                const Divider(height: 24, color: AppColors.surfaceBorder),
                _profileDetailItem(
                  icon: Icons.phone_outlined,
                  title: 'SỐ ĐIỆN THOẠI',
                  value: phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Options
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Lịch sử đặt xe',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingHistoryScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                _menuTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Chính sách bảo hiểm & Điều khoản',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tất cả chuyến đi đều được bảo hiểm 2 chiều',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                _menuTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Tổng đài cứu hộ & Hỗ trợ 24/7',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hotline hỗ trợ khẩn cấp: 1900 8888'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          CustomButton(
            text: 'ĐĂNG XUẤT TÀI KHOẢN',
            isOutlined: true,
            icon: Icons.logout_rounded,
            backgroundColor: AppColors.rose.withAlpha(20),
            onPressed: logout,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _profileDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.north_east_rounded,
        size: 14,
        color: AppColors.textMuted,
      ),
    );
  }
}
