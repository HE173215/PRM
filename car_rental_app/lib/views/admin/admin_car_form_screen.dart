import 'package:flutter/material.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AdminCarFormScreen extends StatefulWidget {
  final CarModel? car;

  const AdminCarFormScreen({super.key, this.car});

  @override
  State<AdminCarFormScreen> createState() => _AdminCarFormScreenState();
}

class _AdminCarFormScreenState extends State<AdminCarFormScreen> {
  final formKey = GlobalKey<FormState>();
  final CarService carService = CarService();

  late TextEditingController nameController;
  late TextEditingController brandController;
  late TextEditingController priceController;
  late TextEditingController seatsController;
  late TextEditingController locationController;
  late TextEditingController licensePlateController;
  late TextEditingController yearController;
  late TextEditingController imageController;
  late TextEditingController descriptionController;

  String transmission = 'Tự động';
  String fuelType = 'Xăng';
  String status = 'available';
  bool isSaving = false;

  final List<String> transmissionOptions = ['Tự động', 'Số sàn'];
  final List<String> fuelOptions = ['Xăng', 'Dầu', 'Điện', 'Hybrid'];
  final List<String> statusOptions = ['available', 'rented', 'maintenance'];

  @override
  void initState() {
    super.initState();
    final car = widget.car;
    nameController = TextEditingController(text: car?.name ?? '');
    brandController = TextEditingController(text: car?.brand ?? '');
    priceController = TextEditingController(
      text: car != null ? car.pricePerDay.toStringAsFixed(0) : '',
    );
    seatsController = TextEditingController(
      text: car != null ? car.seats.toString() : '5',
    );
    locationController = TextEditingController(text: car?.location ?? 'Hồ Chí Minh');
    licensePlateController = TextEditingController(text: car?.licensePlate ?? '');
    yearController = TextEditingController(text: car != null ? car.year.toString() : '2023');
    imageController = TextEditingController(text: car?.image ?? '');
    descriptionController = TextEditingController(text: car?.description ?? '');

    if (car != null) {
      if (transmissionOptions.contains(car.transmission)) {
        transmission = car.transmission;
      }
      if (fuelOptions.contains(car.fuelType)) {
        fuelType = car.fuelType;
      }
      if (statusOptions.contains(car.status.toLowerCase())) {
        status = car.status.toLowerCase();
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    priceController.dispose();
    seatsController.dispose();
    locationController.dispose();
    licensePlateController.dispose();
    yearController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveCar() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      final carData = {
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'pricePerDay': double.tryParse(priceController.text.trim()) ?? 0,
        'seats': int.tryParse(seatsController.text.trim()) ?? 5,
        'transmission': transmission,
        'fuelType': fuelType,
        'location': locationController.text.trim(),
        'licensePlate': licensePlateController.text.trim(),
        'year': int.tryParse(yearController.text.trim()) ?? 2023,
        'images': imageController.text.trim().isNotEmpty
            ? [imageController.text.trim()]
            : [],
        'description': descriptionController.text.trim(),
        'status': status,
      };

      if (widget.car == null) {
        await carService.createCar(carData);
      } else {
        await carService.updateCar(widget.car!.id, carData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.car == null ? 'Thêm xe mới thành công' : 'Cập nhật xe thành công',
          ),
          backgroundColor: AppColors.emerald,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.rose,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.car != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Chỉnh sửa xe' : 'Thêm xe mới',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Card
              _buildSectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: nameController,
                label: 'Tên xe *',
                hintText: 'Ví dụ: VinFast VF8, Mazda CX-5',
                prefixIcon: Icons.directions_car_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên xe' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: brandController,
                      label: 'Hãng xe *',
                      hintText: 'VinFast, Toyota...',
                      prefixIcon: Icons.business_rounded,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nhập hãng xe' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: priceController,
                      label: 'Giá thuê / ngày (VNĐ) *',
                      hintText: 'Ví dụ: 1200000',
                      prefixIcon: Icons.attach_money_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Nhập giá thuê';
                        final num = double.tryParse(val.trim());
                        if (num == null || num <= 0) return 'Giá phải > 0';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: seatsController,
                      label: 'Số ghế ngồi *',
                      hintText: '4, 5, 7...',
                      prefixIcon: Icons.event_seat_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final num = int.tryParse(val?.trim() ?? '');
                        if (num == null || num <= 0) return 'Số ghế > 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: yearController,
                      label: 'Năm sản xuất',
                      hintText: '2023',
                      prefixIcon: Icons.calendar_today_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Specs & Dropdowns
              _buildSectionTitle('Thông số & Vận hành'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Hộp số',
                      value: transmission,
                      items: transmissionOptions,
                      onChanged: (val) => setState(() => transmission = val!),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Nhiên liệu',
                      value: fuelType,
                      items: fuelOptions,
                      onChanged: (val) => setState(() => fuelType = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status Dropdown
              _buildDropdown(
                label: 'Trạng thái xe trong hệ thống',
                value: status,
                items: statusOptions,
                itemLabel: (s) {
                  switch (s) {
                    case 'available':
                      return 'Sẵn sàng cho thuê (Available)';
                    case 'rented':
                      return 'Đang được thuê (Rented)';
                    case 'maintenance':
                      return 'Bảo dưỡng / Sửa chữa (Maintenance)';
                    default:
                      return s;
                  }
                },
                onChanged: (val) => setState(() => status = val!),
              ),
              const SizedBox(height: 24),

              // Location & Image
              _buildSectionTitle('Vị trí & Hình ảnh'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: locationController,
                label: 'Địa điểm giao xe *',
                hintText: 'Quận 1, Hồ Chí Minh...',
                prefixIcon: Icons.location_on_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? 'Nhập địa điểm giao xe' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: licensePlateController,
                label: 'Biển số xe',
                hintText: '51K-123.45',
                prefixIcon: Icons.credit_card_rounded,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: imageController,
                label: 'Link hình ảnh xe (URL)',
                hintText: 'https://images.unsplash.com/...',
                prefixIcon: Icons.image_outlined,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: descriptionController,
                label: 'Mô tả chi tiết',
                hintText: 'Thông tin tiện nghi, cảm giác lái, ưu đãi kèm theo...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: isEdit ? 'Cập nhật xe' : 'Tạo xe mới',
                icon: Icons.check_circle_rounded,
                isLoading: isSaving,
                onPressed: saveCar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    String Function(String)? itemLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          dropdownColor: AppColors.surface,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                itemLabel != null ? itemLabel(item) : item,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
