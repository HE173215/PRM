import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/car_card.dart';
import '../../widgets/section_header.dart';
import '../booking/booking_history_screen.dart';
import '../car/car_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Selected category in home tab
  String _selectedCategory = 'Tất cả';

  // State for home content
  final CarService _carService = CarService();
  List<CarModel> _featuredCars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedCars();
  }

  Future<void> _loadFeaturedCars() async {
    try {
      final cars = await _carService.getCars();
      if (!mounted) return;
      setState(() {
        _featuredCars = cars;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToCarList({String? brand}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarListScreen(initialBrand: brand),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const CarListScreen(isTab: true),
          const BookingHistoryScreen(isTab: true),
          const ProfileScreen(isTab: true),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadFeaturedCars,
        color: AppColors.secondary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Greeting & Notification
              _buildTopHeader(),
              const SizedBox(height: 24),

              // Search Trigger Bar
              _buildSearchBar(),
              const SizedBox(height: 24),

              // Hero Promo Banner
              _buildHeroBanner(),
              const SizedBox(height: 28),

              // Categories Filter
              SectionHeader(
                title: 'Loại xe',
                actionText: 'Tất cả',
                onActionTap: () => _navigateToCarList(),
              ),
              const SizedBox(height: 14),
              _buildCategoryList(),
              const SizedBox(height: 28),

              // Featured Cars (Horizontal Carousel)
              SectionHeader(
                title: 'Xe nổi bật hôm nay',
                actionText: 'Xem thêm',
                onActionTap: () => _navigateToCarList(),
              ),
              const SizedBox(height: 16),
              _buildFeaturedCarsList(),
              const SizedBox(height: 28),

              // Recommended For You (Vertical List preview)
              SectionHeader(
                title: 'Dành cho bạn',
                actionText: 'Xem tất cả',
                onActionTap: () => _navigateToCarList(),
              ),
              const SizedBox(height: 16),
              _buildRecommendedCarsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Xin chào',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('👋', style: TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Thuê xe ngay hôm nay',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surfaceBorder, width: 1),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không có thông báo mới')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => _navigateToCarList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder, width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.secondary, size: 22),
            SizedBox(width: 12),
            Text(
              'Tìm kiếm theo tên xe, hãng xe, địa điểm...',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3730A3).withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.primaryLight.withAlpha(50)),
      ),
      child: Stack(
        children: [
          // Background decorative circle
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondary.withAlpha(80)),
                ),
                child: const Text(
                  'ƯU ĐÃI ĐẶC BIỆT',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Giảm 20% cho\nchuyến đi đầu tiên',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _navigateToCarList(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Khám phá ngay',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {'name': 'Tất cả', 'icon': Icons.apps_rounded, 'brand': null},
      {'name': 'VinFast', 'icon': Icons.electric_car_rounded, 'brand': 'VinFast'},
      {'name': 'Mazda', 'icon': Icons.directions_car_rounded, 'brand': 'Mazda'},
      {'name': 'Toyota', 'icon': Icons.directions_car_filled_rounded, 'brand': 'Toyota'},
      {'name': 'Hyundai', 'icon': Icons.airport_shuttle_rounded, 'brand': 'Hyundai'},
      {'name': 'Kia', 'icon': Icons.car_rental_rounded, 'brand': 'Kia'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat['name'] as String;
              });
              if (cat['brand'] != null) {
                _navigateToCarList(brand: cat['brand'] as String);
              } else {
                _navigateToCarList();
              }
            },
            child: Container(
              width: 82,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryLight
                      : AppColors.surfaceBorder,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    color: isSelected ? Colors.white : AppColors.secondary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCarsList() {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    if (_featuredCars.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: const Text(
          'Chưa có xe nổi bật',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return SizedBox(
      height: 235,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredCars.length,
        itemBuilder: (context, index) {
          final car = _featuredCars[index];
          return CarCard(car: car, isHorizontal: true);
        },
      ),
    );
  }

  Widget _buildRecommendedCarsList() {
    if (_isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
      );
    }

    if (_featuredCars.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCars = _featuredCars.take(4).toList();
    return Column(
      children: displayCars.map((car) => CarCard(car: car)).toList(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textMuted,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car_filled_rounded),
            label: 'Xe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Đơn thuê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
