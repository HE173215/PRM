import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/empty_state.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final AdminService adminService = AdminService();
  final AuthService authService = AuthService();
  final TextEditingController searchController = TextEditingController();

  List<AdminUserModel> users = [];
  bool isLoading = true;
  String? errorMessage;
  String searchText = '';
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadUsers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final results = await Future.wait([
        adminService.getUsers(),
        authService.getProfile().catchError((_) => <String, dynamic>{}),
      ]);

      if (!mounted) return;

      final userList = results[0] as List<AdminUserModel>;
      final profile = results[1] as Map<String, dynamic>;
      final profileData = profile['data'] as Map<String, dynamic>?;

      setState(() {
        users = userList;
        currentUserId = profileData?['_id']?.toString() ?? profileData?['id']?.toString();
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

  Future<void> toggleUserStatus(AdminUserModel user) async {
    final isBlocked = user.status.toLowerCase() == 'blocked';
    final newStatus = isBlocked ? 'active' : 'blocked';

    // Phase 7 rule: Không cho admin tự khóa chính mình
    if (newStatus == 'blocked' && currentUserId != null && user.id == currentUserId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thao tác không hợp lệ'),
          content: const Text(
            'Admin cannot block own account.\n(Quản trị viên không thể tự khóa tài khoản của chính mình).',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBlocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
        content: Text(
          isBlocked
              ? 'Mở khóa tài khoản cho "${user.fullName}"? Người dùng này sẽ có thể đăng nhập và thuê xe trở lại.'
              : 'Bạn có chắc chắn muốn khóa tài khoản "${user.fullName}"? Người dùng bị khóa sẽ không thể truy cập hệ thống.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocked ? AppColors.emerald : AppColors.rose,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(isBlocked ? 'Mở khóa' : 'Khóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await adminService.updateUserStatus(user.id, newStatus);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBlocked
                ? 'Đã mở khóa tài khoản thành công'
                : 'Đã khóa tài khoản thành công',
          ),
          backgroundColor: isBlocked ? AppColors.emerald : AppColors.amber,
        ),
      );

      loadUsers();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.rose,
        ),
      );
    }
  }

  List<AdminUserModel> get filteredUsers {
    final keyword = searchText.toLowerCase().trim();
    if (keyword.isEmpty) return users;

    return users.where((u) {
      return u.fullName.toLowerCase().contains(keyword) ||
          u.email.toLowerCase().contains(keyword) ||
          u.phone.contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredUsers;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý Người dùng',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: loadUsers,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => setState(() => searchText = val),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm theo họ tên, email, số điện thoại...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary, size: 20),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // User Count Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng số: ${filtered.length} người dùng',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // User List
          Expanded(child: _buildList(filtered)),
        ],
      ),
    );
  }

  Widget _buildList(List<AdminUserModel> filtered) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    if (errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Lỗi tải người dùng',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadUsers,
      );
    }

    if (filtered.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline_rounded,
        title: 'Không tìm thấy người dùng',
        message: 'Không có tài khoản nào khớp với từ khóa tìm kiếm.',
      );
    }

    return RefreshIndicator(
      onRefresh: loadUsers,
      color: AppColors.secondary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final user = filtered[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(AdminUserModel user) {
    final isBlocked = user.status.toLowerCase() == 'blocked';
    final isAdmin = user.role.toLowerCase() == 'admin';
    final isMe = currentUserId != null && user.id == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBlocked
              ? AppColors.rose.withAlpha(50)
              : AppColors.surfaceBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isAdmin
                      ? AppColors.primary.withAlpha(40)
                      : AppColors.surfaceLight,
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? AppColors.secondary : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMe)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Bạn',
                                style: TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (user.phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.phone,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.surfaceBorder),
            const SizedBox(height: 10),

            // Badges & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAdmin ? AppColors.amber.withAlpha(25) : AppColors.secondary.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAdmin ? 'ADMIN' : 'CUSTOMER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isAdmin ? AppColors.amber : AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isBlocked ? AppColors.rose.withAlpha(25) : AppColors.emerald.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBlocked ? 'ĐÃ KHÓA' : 'HOẠT ĐỘNG',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isBlocked ? AppColors.rose : AppColors.emerald,
                        ),
                      ),
                    ),
                  ],
                ),

                // Block/Unblock action
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBlocked ? AppColors.emerald.withAlpha(30) : AppColors.rose.withAlpha(30),
                    foregroundColor: isBlocked ? AppColors.emerald : AppColors.rose,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => toggleUserStatus(user),
                  icon: Icon(
                    isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                    size: 14,
                  ),
                  label: Text(
                    isBlocked ? 'Mở khóa' : 'Khóa tài khoản',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
