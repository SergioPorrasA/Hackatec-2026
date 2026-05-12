import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ApiService {
  static const String configuredBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: '',
  );

  static const List<String> _fallbackBaseUrls = [
    'http://10.0.2.2:3000',
    'http://127.0.0.1:3000',
    'http://localhost:3000',
  ];

  static List<String> get _baseUrls {
    final urls = <String>[];

    if (configuredBaseUrl.isNotEmpty) {
      urls.add(configuredBaseUrl);
    }

    if (Platform.isIOS) {
      urls.addAll(const ['http://127.0.0.1:3000', 'http://localhost:3000']);
    } else {
      urls.addAll(_fallbackBaseUrls);
    }

    return urls.toSet().toList();
  }

  static String get baseUrl => _baseUrls.first;

  static Future<http.Response> _getWithFallback(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    Object? lastError;

    for (final baseUrl in _baseUrls) {
      try {
        final uri = Uri.parse('$baseUrl$path').replace(
          queryParameters: query?.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
        return await http.get(uri).timeout(const Duration(seconds: 8));
      } catch (error) {
        lastError = error;
      }
    }

    throw Exception(
      'No se pudo conectar al backend: $lastError. ${_connectionHint()}',
    );
  }

  static Future<http.Response> _postWithFallback(
    String path, {
    required Map<String, String> headers,
    required Object body,
  }) async {
    Object? lastError;

    for (final baseUrl in _baseUrls) {
      try {
        final uri = Uri.parse('$baseUrl$path');
        return await http
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 8));
      } catch (error) {
        lastError = error;
      }
    }

    throw Exception(
      'No se pudo conectar al backend: $lastError. ${_connectionHint()}',
    );
  }

  static Future<List<Map<String, dynamic>>> getReports({String? status}) async {
    final response = await _getWithFallback(
      '/reports',
      query: status == null ? null : {'status': status},
    );
    if (response.statusCode != 200) {
      throw Exception('No se pudieron obtener reportes');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> createReport({
    required String title,
    required String description,
    required String locationText,
    required double lat,
    required double lng,
    String category = 'bache',
    String userName = 'Ciudadano',
    String userPhone = '',
  }) async {
    final response = await _postWithFallback(
      '/reports',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'locationText': locationText,
        'lat': lat,
        'lng': lng,
        'userName': userName,
        'userPhone': userPhone,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo crear el reporte');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getRiskZones() async {
    final response = await _getWithFallback('/risk-zones');
    if (response.statusCode != 200) {
      throw Exception('No se pudieron obtener zonas de riesgo');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getFeedPosts() async {
    final response = await _getWithFallback('/feed');
    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el feed');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String phone,
    required String password,
  }) async {
    final response = await _postWithFallback(
      '/auth/login',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      String message = 'No se pudo iniciar sesión';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] is String) {
          message = decoded['message'] as String;
        }
      } catch (_) {
        if (response.body.trim().isNotEmpty) {
          message = response.body.trim();
        }
      }

      throw Exception('$message (HTTP ${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getNotifications({
    required String phone,
  }) async {
    final response = await _getWithFallback(
      '/notifications',
      query: {'phone': phone},
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron obtener notificaciones');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
