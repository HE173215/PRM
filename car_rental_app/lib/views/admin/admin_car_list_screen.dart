import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/empty_state.dart';
import 'admin_car_form_screen.dart';

class AdminCarListScreen extends StatefulWidget {
  const AdminCarListScreen({super.key});

  @override
  State<AdminCarListScreen> createState() => _AdminCarListScreenState();
}

class _AdminCarListScreenState extends State<AdminCarListScreen> {
  final CarService carService = CarService();
  final TextEditingController searchController = TextEditingController();

  List<CarModel> cars = [];
  bool isLoading = true;
  String? errorMessage;
  String searchText = '';
  String selectedStatusFilter = 'Tất cả';

  final List<String> statusFilters = [
    'Tất cả',
    'available',
    'rented',
    'maintenance',
  ];

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadCars() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await carService.getCars();
      if (!mounted) return;

      setState(() {
        cars = result;
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

  Future<void> deleteCar(CarModel car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa xe'),
        content: Text(
          'Bạn có chắc chắn muốn xóa xe "${car.name}" khỏi hệ thống?\n\nLưu ý: Nếu xe đã có lịch sử đơn thuê, hệ thống sẽ từ chối xóa vật lý để bảo toàn dữ liệu.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa xe'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await carService.deleteCar(car.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa xe "${car.name}" thành công'),
          backgroundColor: AppColors.emerald,
        ),
      );

      loadCars();
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

  List<CarModel> get filteredCars {
    return cars.where((car) {
      final keyword = searchText.toLowerCase().trim();
      final matchesSearch = keyword.isEmpty ||
          car.name.toLowerCase().contains(keyword) ||
          car.brand.toLowerCase().contains(keyword) ||
          car.licensePlate.toLowerCase().contains(keyword);

      final matchesStatus = selectedStatusFilter == 'Tất cả' ||
          car.status.toLowerCase() == selectedStatusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredCars;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý Đội xe',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: loadCars,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm xe mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AdminCarFormScreen()),
          );
          if (added == true) {
            loadCars();
          }
        },
      ),
      body: Column(
        children: [
          // Search Bar
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
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên xe, hãng, biển số...',
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

          // Status Filter Tabs
          SizedBox(
            height: 44,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: statusFilters.length,
              itemBuilder: (context, index) {
                final status = statusFilters[index];
                final isSelected = selectedStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_statusLabel(status)),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryLight : AppColors.surfaceBorder,
                    ),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) => setState(() => selectedStatusFilter = status),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Car List
          Expanded(child: _buildList(filtered)),
        ],
      ),
    );
  }

  Widget _buildList(List<CarModel> filtered) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    if (errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Lỗi tải danh sách xe',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadCars,
      );
    }

    if (filtered.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.directions_car_outlined,
        title: 'Không tìm thấy xe',
        message: 'Không có xe nào khớp với điều kiện tìm kiếm hoặc bộ lọc.',
      );
    }

    return RefreshIndicator(
      onRefresh: loadCars,
      color: AppColors.secondary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final car = filtered[index];
          return _buildCarCard(car);
        },
      ),
    );
  }

  Widget _buildCarCard(CarModel car) {
    final statusColor = _statusColor(car.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: car.image.isNotEmpty
                      ? Image.network(
                          car.image,
                          width: 80,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              car.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withAlpha(80)),
                            ),
                            child: Text(
                              _statusLabel(car.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${car.brand} • ${car.seats} chỗ • ${car.transmission}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatPerDay(car.pricePerDay),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.surfaceBorder),
            const SizedBox(height: 6),

            // Actions row: Edit and Delete
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminCarFormScreen(car: car),
                      ),
                    );
                    if (updated == true) {
                      loadCars();
                    }
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryLight),
                  label: const Text('Chỉnh sửa', style: TextStyle(color: AppColors.primaryLight, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => deleteCar(car),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.rose),
                  label: const Text('Xóa', style: TextStyle(color: AppColors.rose, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 70,
      color: AppColors.surfaceLight,
      child: const Icon(Icons.directions_car_rounded, color: AppColors.textMuted, size: 30),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Sẵn sàng';
      case 'rented':
        return 'Đang thuê';
      case 'maintenance':
        return 'Bảo dưỡng';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.emerald;
      case 'rented':
        return AppColors.secondary;
      case 'maintenance':
        return AppColors.amber;
      default:
        return AppColors.textSecondary;
    }
  }
}
