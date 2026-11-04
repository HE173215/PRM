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
        title: const Text('Đăng xuất'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Tài khoản',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
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
        child: CircularProgressIndicator(color: AppColors.secondary),
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
          // User Avatar & Name Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
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
              children: [
                // Glowing Avatar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(90),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.surfaceLight,
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? AppColors.amber.withAlpha(30)
                        : AppColors.secondary.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAdmin
                          ? AppColors.amber.withAlpha(80)
                          : AppColors.secondary.withAlpha(80),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAdmin
                            ? Icons.admin_panel_settings_rounded
                            : Icons.verified_user_rounded,
                        size: 14,
                        color: isAdmin ? AppColors.amber : AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isAdmin ? 'QUẢN TRỊ VIÊN' : 'THÀNH VIÊN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isAdmin ? AppColors.amber : AppColors.secondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User Information Section
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
                  'Thông tin liên hệ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _profileDetailItem(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: email,
                ),
                const Divider(height: 20, color: AppColors.surfaceBorder),
                _profileDetailItem(
                  icon: Icons.phone_outlined,
                  title: 'Số điện thoại',
                  value: phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick actions / Admin panel
          if (isAdmin) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.primaryLight.withAlpha(80)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.amber,
                  ),
                ),
                title: const Text(
                  'Trung tâm Quản trị (Admin CMS)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                subtitle: const Text(
                  'Dashboard, Quản lý Xe, Đơn thuê, Users & Báo cáo',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white,
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

          // Other menu options
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
                  title: 'Lịch sử thuê xe',
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
                  icon: Icons.shield_outlined,
                  title: 'Chính sách bảo mật & Điều khoản',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang cập nhật điều khoản dịch vụ')),
                    );
                  },
                ),
                const Divider(height: 1, color: AppColors.surfaceBorder),
                _menuTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Trung tâm hỗ trợ 24/7',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hotline hỗ trợ: 1900 8888')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Logout Button
          CustomButton(
            text: 'Đăng xuất',
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
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 13,
        color: AppColors.textMuted,
      ),
    );
  }
}
