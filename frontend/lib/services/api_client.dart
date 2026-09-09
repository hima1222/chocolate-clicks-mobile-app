import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chocolate_clicks/models/user_model.dart';
import 'package:chocolate_clicks/services/storage_service.dart';

/// Exception thrown when API call fails
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Base API client for all HTTP communication
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    return 'http://10.0.2.2:5000/api';
  }

  static const Duration timeout = Duration(seconds: 30);

  /// Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url, headers: headers).timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          message: 'GET request failed: $endpoint',
          statusCode: response.statusCode,
          originalError: response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'GET request failed: $endpoint',
        originalError: e,
      );
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: json.encode(body),
      ).timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          message: 'POST request failed: $endpoint',
          statusCode: response.statusCode,
          originalError: response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'POST request failed: $endpoint',
        originalError: e,
      );
    }
  }

  /// Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: json.encode(body),
      ).timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          message: 'PUT request failed: $endpoint',
          statusCode: response.statusCode,
          originalError: response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'PUT request failed: $endpoint',
        originalError: e,
      );
    }
  }

  /// Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(url, headers: headers).timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          message: 'DELETE request failed: $endpoint',
          statusCode: response.statusCode,
          originalError: response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'DELETE request failed: $endpoint',
        originalError: e,
      );
    }
  }
}

/// Session management - shared across all services
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal() {
    _loadStoredSession();
  }

  String? _token;
  String? _refreshToken;
  User? _user;
  final StorageService _storage = StorageService();

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  User? get user => _user;

  Future<void> setSession({
    required String token,
    String? refreshToken,
    required User user,
  }) async {
    _token = token;
    _refreshToken = refreshToken;
    _user = user;
    await _storage.save('auth_token', token);
    await _storage.save('user_data', json.encode(user.toJson()));
    if (refreshToken != null) {
      await _storage.save('refresh_token', refreshToken);
    }
  }

  Future<void> clearSession() async {
    _token = null;
    _refreshToken = null;
    _user = null;
    await _storage.delete('auth_token');
    await _storage.delete('user_data');
    await _storage.delete('refresh_token');
  }

  bool get isLoggedIn => _token != null && _user != null;

  Future<void> _loadStoredSession() async {
    try {
      final token = await _storage.getString('auth_token');
      final userData = await _storage.getString('user_data');
      final refreshToken = await _storage.getString('refresh_token');

      if (token != null && userData != null) {
        _token = token;
        _refreshToken = refreshToken;
        _user = User.fromJson(json.decode(userData));
      }
    } catch (e) {
      // Silent fail on startup
      await clearSession();
    }
  }
}
