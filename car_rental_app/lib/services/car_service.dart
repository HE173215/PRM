import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/car_model.dart';
import 'api_service.dart';
import 'token_service.dart';

class CarService {
  final TokenService tokenService = TokenService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await tokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Lỗi máy chủ (${response.statusCode}): Phản hồi không hợp lệ.',
      );
    }
  }

  Future<List<CarModel>> getCars() async {
    final url = Uri.parse('${ApiService.baseUrl}/cars');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = _parseResponse(response);
      final List<dynamic> data = jsonData['data'] ?? [];
      return data.map((item) => CarModel.fromJson(item)).toList();
    }

    throw Exception('Không thể tải danh sách xe');
  }

  Future<CarModel> getCarById(String id) async {
    final url = Uri.parse('${ApiService.baseUrl}/cars/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = _parseResponse(response);
      return CarModel.fromJson(jsonData['data']);
    }

    throw Exception('Không tìm thấy thông tin xe');
  }

  // ==== ADMIN CRUD METHODS ====

  Future<CarModel> createCar(Map<String, dynamic> carData) async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/cars');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(carData),
    );

    final data = _parseResponse(response);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return CarModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Không thể tạo xe mới');
  }

  Future<CarModel> updateCar(String id, Map<String, dynamic> carData) async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/cars/$id');

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(carData),
    );

    final data = _parseResponse(response);
    if (response.statusCode == 200) {
      return CarModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Không thể cập nhật xe');
  }

  Future<void> deleteCar(String id) async {
    final headers = await _authHeaders();
    final url = Uri.parse('${ApiService.baseUrl}/cars/$id');

    final response = await http.delete(url, headers: headers);
    final data = _parseResponse(response);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(data['message'] ?? 'Không thể xóa xe');
    }
  }
}