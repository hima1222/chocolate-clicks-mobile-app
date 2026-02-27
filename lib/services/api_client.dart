import 'package:chocolate_clicks/models/user_model.dart';

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
/// TODO: Replace mock implementations with real http/dio calls
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String baseUrl = 'https://your-api.com/api';
  static const Duration timeout = Duration(seconds: 30);

  /// Generic GET request
  /// TODO: Implement with http/dio
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // Placeholder - replace with actual http call
      return {'success': true, 'data': {}};
    } catch (e) {
      throw ApiException(
        message: 'GET request failed: $endpoint',
        originalError: e,
      );
    }
  }

  /// Generic POST request
  /// TODO: Implement with http/dio
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // Placeholder - replace with actual http call
      return {'success': true, 'data': {}};
    } catch (e) {
      throw ApiException(
        message: 'POST request failed: $endpoint',
        originalError: e,
      );
    }
  }

  /// Generic PUT request
  /// TODO: Implement with http/dio
  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // Placeholder - replace with actual http call
      return {'success': true, 'data': {}};
    } catch (e) {
      throw ApiException(
        message: 'PUT request failed: $endpoint',
        originalError: e,
      );
    }
  }

  /// Generic DELETE request
  /// TODO: Implement with http/dio
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // Placeholder - replace with actual http call
      return {'success': true, 'data': {}};
    } catch (e) {
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
  SessionManager._internal();

  String? _token;
  String? _refreshToken;
  User? _user;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  User? get user => _user;

  void setSession({
    required String token,
    String? refreshToken,
    required User user,
  }) {
    _token = token;
    _refreshToken = refreshToken;
    _user = user;
    // TODO: Persist tokens to secure storage
  }

  void clearSession() {
    _token = null;
    _refreshToken = null;
    _user = null;
    // TODO: Clear secure storage
  }

  bool get isLoggedIn => _token != null && _user != null;
}
