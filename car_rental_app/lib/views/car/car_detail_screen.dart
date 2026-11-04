import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/custom_button.dart';
import '../booking/booking_screen.dart';

class CarDetailScreen extends StatefulWidget {
  final CarModel car;

  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final car = widget.car;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable Body Content
          CustomScrollView(
            slivers: [
              // Hero Image App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background.withAlpha(200),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background.withAlpha(200),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(30)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? AppColors.rose : Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite ? 'Đã thêm vào mục yêu thích' : 'Đã xóa khỏi yêu thích',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeroImage(car.image),
                      // Top gradient for appbar icon visibility
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),
                      // Bottom gradient into dark scaffold
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 90,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, AppColors.background],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Details Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Tag & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(40),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.primaryLight.withAlpha(80)),
                            ),
                            child: Text(
                              car.brand.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  car.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '(48 đánh giá)',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Car Name
                      Text(
                        car.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.secondary, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              car.location.isNotEmpty ? car.location : 'Hồ Chí Minh, Việt Nam',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Specifications Grid
                      const Text(
                        'Thông số kỹ thuật',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpecCard(
                              icon: Icons.airline_seat_recline_normal_rounded,
                              label: 'Số ghế',
                              value: '${car.seats} chỗ',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSpecCard(
                              icon: Icons.tune_rounded,
                              label: 'Hộp số',
                              value: car.transmission.isNotEmpty ? car.transmission : 'Tự động',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSpecCard(
                              icon: Icons.local_gas_station_rounded,
                              label: 'Nhiên liệu',
                              value: car.fuelType.isNotEmpty ? car.fuelType : 'Xăng',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Features & Policies
                      const Text(
                        'Tiện ích & Quyền lợi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildBenefitTile(
                        icon: Icons.shield_outlined,
                        title: 'Bảo hiểm chuyến đi',
                        subtitle: 'Đã bao gồm gói bảo hiểm vật chất xe tiêu chuẩn',
                      ),
                      const SizedBox(height: 10),
                      _buildBenefitTile(
                        icon: Icons.event_available_outlined,
                        title: 'Hủy chuyến linh hoạt',
                        subtitle: 'Hủy miễn phí trước 24 giờ nhận xe',
                      ),
                      const SizedBox(height: 10),
                      _buildBenefitTile(
                        icon: Icons.cleaning_services_outlined,
                        title: 'Vệ sinh khử khuẩn',
                        subtitle: 'Xe được rửa sạch và kiểm tra an toàn trước khi bàn giao',
                      ),
                      const SizedBox(height: 28),

                      // Description
                      const Text(
                        'Mô tả chi tiết',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Text(
                          car.description.isNotEmpty
                              ? car.description
                              : 'Xe sang đời mới, vận hành êm ái, đầy đủ tiện nghi, phù hợp cho các chuyến công tác, du lịch gia đình hoặc trải nghiệm phong cách sống thượng lưu.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Sticky Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  top: BorderSide(color: AppColors.surfaceBorder, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(120),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Price info
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giá thuê',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: CurrencyFormatter.format(car.pricePerDay, showUnit: false),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.secondary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const TextSpan(
                                text: ' đ/ngày',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),

                    // Action Button
                    Expanded(
                      child: CustomButton(
                        text: 'Thuê xe ngay',
                        icon: Icons.calendar_today_rounded,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(car: car),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: AppColors.surfaceLight,
        child: const Icon(
          Icons.directions_car_rounded,
          size: 100,
          color: AppColors.surfaceBorder,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.surfaceLight,
          child: const Center(
            child: Icon(
              Icons.directions_car_rounded,
              size: 100,
              color: AppColors.surfaceBorder,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.emerald, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
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
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
