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
    if (configuredBaseUrl.isNotEmpty) {
      return [configuredBaseUrl];
    }

    if (Platform.isIOS) {
      return const ['http://127.0.0.1:3000', 'http://localhost:3000'];
    }

    return _fallbackBaseUrls;
  }

  static String get baseUrl => _baseUrls.first;

  // WebSocket for real-time notifications
  static IO.Socket? _socket;
  static Function(Map<String, dynamic>)? _onStatusUpdated;

  /// Initialize WebSocket connection for real-time notifications
  static void initializeWebSocket({
    required Function(Map<String, dynamic>) onStatusUpdated,
  }) {
    _onStatusUpdated = onStatusUpdated;
    _connectWebSocket();
  }

  static void _connectWebSocket() {
    final wsBaseUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');

    try {
      _socket = IO.io(
        wsBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(99999)
            .build(),
      );

      _socket!.onConnect((_) {
        print('✓ WebSocket conectado: ${_socket!.id}');
        // Notify app that we're connected and ready for updates
        _socket!.emit('subscribe_to_updates', {'phone': 'app_user'});
      });

      _socket!.onDisconnect((_) {
        print('✗ WebSocket desconectado');
      });

      // Listen for status updates from backend
      _socket!.on('status_updated', (data) {
        print('📢 Notificación recibida: $data');
        if (_onStatusUpdated != null) {
          _onStatusUpdated!(Map<String, dynamic>.from(data as Map));
        }
      });

      _socket!.onError((error) {
        print('❌ Error WebSocket: $error');
      });
    } catch (e) {
      print('Error al conectar WebSocket: $e');
    }
  }

  /// Disconnect WebSocket
  static void disconnectWebSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Get WebSocket connection status
  static bool get isWebSocketConnected => _socket?.connected ?? false;

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

    throw Exception('No se pudo conectar al backend: $lastError');
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

    throw Exception('No se pudo conectar al backend: $lastError');
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
      throw Exception('No se pudo iniciar sesión');
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
