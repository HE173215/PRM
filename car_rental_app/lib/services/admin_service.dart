import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'token_service.dart';

class DashboardStats {
  final int totalUsers;
  final int totalCars;
  final int availableCars;
  final int rentedCars;
  final int maintenanceCars;
  final int totalBookings;
  final int pendingBookings;
  final int confirmedBookings;
  final int ongoingBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double totalRevenue;

  DashboardStats({
    required this.totalUsers,
    required this.totalCars,
    required this.availableCars,
    required this.rentedCars,
    required this.maintenanceCars,
    required this.totalBookings,
    required this.pendingBookings,
    required this.confirmedBookings,
    required this.ongoingBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalCars: (json['totalCars'] as num?)?.toInt() ?? 0,
      availableCars: (json['availableCars'] as num?)?.toInt() ?? 0,
      rentedCars: (json['rentedCars'] as num?)?.toInt() ?? 0,
      maintenanceCars: (json['maintenanceCars'] as num?)?.toInt() ?? 0,
      totalBookings: (json['totalBookings'] as num?)?.toInt() ?? 0,
      pendingBookings: (json['pendingBookings'] as num?)?.toInt() ?? 0,
      confirmedBookings: (json['confirmedBookings'] as num?)?.toInt() ?? 0,
      ongoingBookings: (json['ongoingBookings'] as num?)?.toInt() ?? 0,
      completedBookings: (json['completedBookings'] as num?)?.toInt() ?? 0,
      cancelledBookings: (json['cancelledBookings'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RevenueMonth {
  final int month;
  final double revenue;

  RevenueMonth({required this.month, required this.revenue});

  factory RevenueMonth.fromJson(Map<String, dynamic> json) {
    return RevenueMonth(
      month: (json['month'] as num?)?.toInt() ?? 1,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TopCarItem {
  final String carId;
  final String name;
  final int bookingCount;
  final double revenue;

  TopCarItem({
    required this.carId,
    required this.name,
    required this.bookingCount,
    required this.revenue,
  });

  factory TopCarItem.fromJson(Map<String, dynamic> json) {
    return TopCarItem(
      carId: json['carId']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      bookingCount: (json['bookingCount'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AdminUserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String status; // 'active' | 'blocked'
  final DateTime? createdAt;

  AdminUserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.createdAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    if (json['createdAt'] != null) {
      try {
        created = DateTime.parse(json['createdAt']).toLocal();
      } catch (_) {}
    }

    return AdminUserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      status: json['status']?.toString() ?? 'active',
      createdAt: created,
    );
  }
}

class AdminService {
  final TokenService tokenService = TokenService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await tokenService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập hoặc token đã hết hạn');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw Exception('Lỗi máy chủ (${response.statusCode})');
    }
  }

  // 1. Dashboard Overview
  Future<DashboardStats> getDashboardStats() async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/admin/dashboard');

    final response = await http.get(url, headers: headers);
    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      final statsData = data['data'] ?? data;
      return DashboardStats.fromJson(statsData);
    }

    throw Exception(data['message'] ?? 'Không thể tải thống kê Dashboard');
  }

  // 2. Revenue Report by Year
  Future<List<RevenueMonth>> getRevenueReport({int? year}) async {
    final headers = await _authHeaders();
    final queryYear = year ?? DateTime.now().year;
    final url = Uri.parse('${ApiService.baseUrl}/admin/reports/revenue?year=$queryYear');

    final response = await http.get(url, headers: headers);
    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      final List<dynamic> list = data['data'] ?? (data is List ? data : []);
      return list.map((item) => RevenueMonth.fromJson(item)).toList();
    }

    throw Exception(data['message'] ?? 'Không thể tải báo cáo doanh thu');
  }

  // 3. Booking Stats
  Future<Map<String, dynamic>> getBookingStats() async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/admin/reports/bookings');

    final response = await http.get(url, headers: headers);
    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      return data['data'] ?? data;
    }

    throw Exception(data['message'] ?? 'Không thể tải thống kê đơn thuê');
  }

  // 4. Top Rented Cars
  Future<List<TopCarItem>> getTopCars({int limit = 5}) async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/admin/reports/top-cars?limit=$limit');

    final response = await http.get(url, headers: headers);
    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      final List<dynamic> list = data['data'] ?? (data is List ? data : []);
      return list.map((item) => TopCarItem.fromJson(item)).toList();
    }

    throw Exception(data['message'] ?? 'Không thể tải danh sách xe thuê nhiều');
  }

  // 5. User Management
  Future<List<AdminUserModel>> getUsers() async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/admin/users');

    final response = await http.get(url, headers: headers);
    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      final List<dynamic> list = data['data'] ?? [];
      return list.map((item) => AdminUserModel.fromJson(item)).toList();
    }

    throw Exception(data['message'] ?? 'Không thể tải danh sách người dùng');
  }

  Future<AdminUserModel> getUserById(String id) async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/admin/users/$id');

    final response = await http.get(url, headers: headers);
    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      return AdminUserModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Không tìm thấy người dùng');
  }

  Future<void> updateUserStatus(String id, String status) async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/admin/users/$id/status');

    final response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    final data = _parseResponse(response);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Không thể cập nhật trạng thái người dùng');
    }
  }
}
