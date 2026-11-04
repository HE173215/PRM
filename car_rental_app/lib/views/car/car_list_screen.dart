import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/car_card.dart';
import '../../widgets/empty_state.dart';

class CarListScreen extends StatefulWidget {
  final bool isTab;
  final String? initialBrand;

  const CarListScreen({
    super.key,
    this.isTab = false,
    this.initialBrand,
  });

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
      final matchesSearch = keyword.isEmpty ||
          car.name.toLowerCase().contains(keyword) ||
          car.brand.toLowerCase().contains(keyword) ||
          car.location.toLowerCase().contains(keyword);

      final matchesBrand =
          selectedBrand == 'All' || car.brand.toLowerCase() == selectedBrand.toLowerCase();

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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Danh mục xe',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder, width: 1),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên xe, hãng, địa điểm...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.secondary,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Brand Filter Pills Horizontal
          SizedBox(
            height: 44,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final isSelected = selectedBrand == brand;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(brand == 'All' ? 'Tất cả hãng' : brand),
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
                        selectedBrand = brand;
                      });
                    },
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
                  'Tìm thấy ${filtered.length} xe',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
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

          const SizedBox(height: 8),

          // Car List Content
          Expanded(
            child: buildContent(filtered),
          ),
        ],
      ),
    );
  }

  Widget buildContent(List<CarModel> filtered) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
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
      color: AppColors.secondary,
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