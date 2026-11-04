import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';
}
