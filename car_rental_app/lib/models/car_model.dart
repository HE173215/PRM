class CarModel {
  final String id;
  final String name;
  final String brand;
  final String image;
  final double pricePerDay;
  final int seats;
  final String transmission;
  final String fuelType;
  final String location;
  final double rating;
  final String description;
  final String status; // 'available', 'rented', 'maintenance'
  final String licensePlate;
  final int year;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.image,
    required this.pricePerDay,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    required this.location,
    required this.rating,
    required this.description,
    this.status = 'available',
    this.licensePlate = '',
    this.year = 2023,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'];
    String imageUrl = '';

    if (images is List && images.isNotEmpty) {
      imageUrl = images.first.toString();
    } else if (json['image'] != null) {
      imageUrl = json['image'].toString();
    }

    return CarModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      image: imageUrl,
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0,
      seats: (json['seats'] as num?)?.toInt() ?? 4,
      transmission: json['transmission']?.toString() ?? 'Tự động',
      fuelType: json['fuelType']?.toString() ?? 'Xăng',
      location: json['location']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'available',
      licensePlate: json['licensePlate']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 2023,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'images': image.isNotEmpty ? [image] : [],
      'pricePerDay': pricePerDay,
      'seats': seats,
      'transmission': transmission,
      'fuelType': fuelType,
      'location': location,
      'description': description,
      'status': status,
      'licensePlate': licensePlate,
      'year': year,
    };
  }
}