import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'token_service.dart';

class AuthService {
  final TokenService tokenService =
  TokenService();

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/auth/register',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data['message'] ??
          'Đăng ký thất bại',
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/auth/login',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token =
      data['token']?.toString();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Server không trả về token',
        );
      }

      await tokenService.saveToken(
        token,
      );

      return data;
    }

    throw Exception(
      data['message'] ??
          'Đăng nhập thất bại',
    );
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token =
    await tokenService.getToken();

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        'Bạn chưa đăng nhập',
      );
    }

    final url = Uri.parse(
      '${ApiService.baseUrl}/auth/profile',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type':
        'application/json',
        'Authorization':
        'Bearer $token',
      },
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    if (response.statusCode == 401) {
      await tokenService.removeToken();
    }

    throw Exception(
      data['message'] ??
          'Không thể tải thông tin người dùng',
    );
  }

  Future<void> logout() async {
    await tokenService.removeToken();
  }

  Future<bool> isLoggedIn() async {
    return tokenService.hasToken();
  }
}