import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/booking_model.dart';
import 'api_service.dart';
import 'token_service.dart';

class BookingService {
  final TokenService tokenService = TokenService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập');
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
      throw Exception(
        'Lỗi từ máy chủ (${response.statusCode}): Đường dẫn API không tồn tại hoặc máy chủ gặp sự cố.',
      );
    }
  }

  Future<BookingModel> createBooking({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    String note = '',
  }) async {
    final headers = await _authHeaders();

    final url = Uri.parse('${ApiService.baseUrl}/bookings');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'carId': carId,
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
        'note': note,
      }),
    );

    final data = _parseResponse(response);

    if (response.statusCode == 201) {
      return BookingModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Không thể đặt xe');
  }

  Future<List<BookingModel>> getMyBookings() async {
    final headers = await _authHeaders();

    final url = Uri.parse('${ApiService.baseUrl}/bookings/my');

    final response = await http.get(url, headers: headers);

    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      final List<dynamic> list = data['data'] ?? [];

      return list.map((item) => BookingModel.fromJson(item)).toList();
    }

    throw Exception(data['message'] ?? 'Không thể tải đơn thuê');
  }

  Future<BookingModel> getBookingById(String bookingId) async {
    final headers = await _authHeaders();

    final url = Uri.parse('${ApiService.baseUrl}/bookings/$bookingId');

    final response = await http.get(url, headers: headers);

    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Không thể tải booking');
  }

  Future<void> cancelBooking(String bookingId) async {
    final headers = await _authHeaders();

    final url = Uri.parse('${ApiService.baseUrl}/bookings/$bookingId/cancel');

    final response = await http.patch(url, headers: headers);

    final data = _parseResponse(response);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Không thể hủy đơn');
    }
  }

  Future<BookingModel> markAsPaid(String bookingId) async {
    final headers = await _authHeaders();

    final url = Uri.parse('${ApiService.baseUrl}/bookings/$bookingId/pay');

    final response = await http.patch(url, headers: headers);

    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      if (data['data'] != null && data['data'] is Map<String, dynamic>) {
        return BookingModel.fromJson(data['data']);
      }
      return await getBookingById(bookingId);
    }

    throw Exception(data['message'] ?? 'Không thể hoàn tất thanh toán');
  }

  // ==== ADMIN METHODS ====

  Future<List<BookingModel>> getAllBookings({
    String? status,
    String? paymentStatus,
    String? search,
  }) async {
    final headers = await _authHeaders();

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'tất cả' && status.toLowerCase() != 'all') {
      queryParams['status'] = status;
    }
    if (paymentStatus != null && paymentStatus.isNotEmpty && paymentStatus.toLowerCase() != 'tất cả' && paymentStatus.toLowerCase() != 'all') {
      queryParams['paymentStatus'] = paymentStatus;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final queryString = queryParams.isNotEmpty
        ? '?${Uri(queryParameters: queryParams).query}'
        : '';

    Uri url = Uri.parse('${ApiService.baseUrl}/bookings/admin/all$queryString');
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 404) {
      url = Uri.parse('${ApiService.baseUrl}/bookings$queryString');
      response = await http.get(url, headers: headers);
    }

    final data = _parseResponse(response);

    if (response.statusCode == 200) {
      final List<dynamic> list = data['data'] ?? [];
      return list.map((item) => BookingModel.fromJson(item)).toList();
    }

    throw Exception(data['message'] ?? 'Không thể tải danh sách đơn thuê');
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final headers = await _authHeaders();
    Uri url = Uri.parse('${ApiService.baseUrl}/bookings/admin/$bookingId/status');

    var response = await http.patch(
      url,
      headers: headers,
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 404) {
      url = Uri.parse('${ApiService.baseUrl}/bookings/$bookingId/status');
      response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode({'status': status}),
      );
    }

    final data = _parseResponse(response);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Không thể cập nhật trạng thái');
    }
  }
}
