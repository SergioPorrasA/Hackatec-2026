import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static Future<List<Map<String, dynamic>>> getReports({String? status}) async {
    final response = await http.get(
      _uri('/reports', status == null ? null : {'status': status}),
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
  }) async {
    final response = await http.post(
      _uri('/reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'locationText': locationText,
        'lat': lat,
        'lng': lng,
        'userName': userName,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('No se pudo crear el reporte');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getRiskZones() async {
    final response = await http.get(_uri('/risk-zones'));
    if (response.statusCode != 200) {
      throw Exception('No se pudieron obtener zonas de riesgo');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getFeedPosts() async {
    final response = await http.get(_uri('/feed'));
    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el feed');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
