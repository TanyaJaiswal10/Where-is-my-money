import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (status: ${statusCode ?? "N/A"})';
}

class ApiClient {
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static const Duration timeoutDuration = Duration(seconds: 10);

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthStorageService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException("Backend unavailable. Please ensure FastAPI is running at $baseUrl.");
    } on http.ClientException catch (e) {
      throw ApiException("Network client error: ${e.message}");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Connection failed: $e");
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(timeoutDuration);
      return _processResponse(response);
    } on SocketException {
      throw ApiException("Backend unavailable. Please ensure FastAPI is running at $baseUrl.");
    } on http.ClientException catch (e) {
      throw ApiException("Network error: ${e.message}");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Failed request: $e");
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(uri, headers: headers, body: jsonEncode(body))
          .timeout(timeoutDuration);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Failed request: $e");
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(uri, headers: headers).timeout(timeoutDuration);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Failed request: $e");
    }
  }

  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      String errorMessage = "API error occurred";
      try {
        final bodyJson = jsonDecode(response.body);
        if (bodyJson is Map && bodyJson.containsKey('detail')) {
          final detail = bodyJson['detail'];
          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List && detail.isNotEmpty) {
            errorMessage = detail[0]['msg'] ?? "Invalid data format";
          }
        }
      } catch (_) {}

      if (response.statusCode == 401) {
        AuthStorageService.clearToken();
      }

      throw ApiException(errorMessage, response.statusCode);
    }
  }
}
