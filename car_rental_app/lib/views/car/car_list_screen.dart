import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/car_card.dart';
import '../../widgets/empty_state.dart';

class CarListScreen extends StatefulWidget {
  final bool isTab;
  final String? initialBrand;

  const CarListScreen({super.key, this.isTab = false, this.initialBrand});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final CarService carService = CarService();
  final TextEditingController searchController = TextEditingController();

  List<CarModel> cars = [];
  bool isLoading = true;
  String? errorMessage;
  String searchText = '';
  late String selectedBrand;

  final List<String> brands = [
    'All',
    'VinFast',
    'Mazda',
    'Toyota',
    'Hyundai',
    'Kia',
  ];

  @override
  void initState() {
    super.initState();
    selectedBrand = widget.initialBrand ?? 'All';
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

  List<CarModel> get filteredCars {
    return cars.where((car) {
      final keyword = searchText.toLowerCase().trim();
      final matchesSearch =
          keyword.isEmpty ||
          car.name.toLowerCase().contains(keyword) ||
          car.brand.toLowerCase().contains(keyword) ||
          car.location.toLowerCase().contains(keyword);

      final matchesBrand =
          selectedBrand == 'All' ||
          car.brand.toLowerCase() == selectedBrand.toLowerCase();

      return matchesSearch && matchesBrand;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredCars;

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
          'ĐỘI XE CHO THUÊ',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadCars,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên xe, hãng, địa điểm...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  suffixIcon: searchText.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              searchText = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Brand Filter Pills Horizontal
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final isSelected = selectedBrand == brand;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedBrand = brand;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceBorder,
                        ),
                      ),
                      child: Text(
                        (brand == 'All' ? 'Tất cả hãng' : brand).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Result Count indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KẾT QUẢ // ${filtered.length} XE KHẢ DỤNG',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                if (searchText.isNotEmpty || selectedBrand != 'All')
                  GestureDetector(
                    onTap: () {
                      searchController.clear();
                      setState(() {
                        searchText = '';
                        selectedBrand = 'All';
                      });
                    },
                    child: const Text(
                      'XÓA BỘ LỌC',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Car List Content
          Expanded(child: buildContent(filtered)),
        ],
      ),
    );
  }

  Widget buildContent(List<CarModel> filtered) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (errorMessage != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Không thể tải dữ liệu',
        message: errorMessage!,
        buttonText: 'Thử lại',
        onButtonPressed: loadCars,
      );
    }

    if (filtered.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.directions_car_outlined,
        title: 'Không tìm thấy xe phù hợp',
        message: 'Hãy thử tìm kiếm với từ khóa khác hoặc bỏ chọn bộ lọc thương hiệu.',
        buttonText: 'Xem tất cả xe',
        onButtonPressed: () {
          searchController.clear();
          setState(() {
            searchText = '';
            selectedBrand = 'All';
          });
        },
      );
    }

    return RefreshIndicator(
      onRefresh: loadCars,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final car = filtered[index];
          return CarCard(car: car);
        },
      ),
    );
  }
}
