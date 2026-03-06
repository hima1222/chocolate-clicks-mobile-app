import 'package:chocolate_clicks/models/user_model.dart';

/// Repository pattern for API calls related to authentication
/// This acts as an intermediary between the AuthService and backend API
class AuthRepository {
  // Base API URL - update this with your actual backend URL
  static const String _baseUrl = 'https://your-api.com/api';

  // Private constructor for singleton pattern
  AuthRepository._();

  // Singleton instance
  static final AuthRepository _instance = AuthRepository._();

  factory AuthRepository() {
    return _instance;
  }

  /// Mock POST request for login
  /// In production, replace this with actual HTTP client (dio, http package)
  Future<AuthResponse> postLogin({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      // TODO: Implement actual API call using http or dio package
      // Example with http package:
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'emailOrUsername': emailOrUsername,
      //     'password': password,
      //   }),
      // );
      //
      // if (response.statusCode == 200) {
      //   return AuthResponse.fromJson(jsonDecode(response.body));
      // } else {
      //   throw AuthException(
      //     message: 'Login failed: ${response.statusCode}',
      //     code: 'API_ERROR',
      //   );
      // }

      // Mock response - remove in production
      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        success: true,
        message: 'Login successful',
        user: User(
          id: 'user_123',
          firstName: 'John',
          lastName: 'Doe',
          email: emailOrUsername,
          phone: '9876543210',
          createdAt: DateTime.now(),
        ),
        token: 'mock_token_123',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mock POST request for signup
  /// In production, replace this with actual HTTP client
  Future<AuthResponse> postSignup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // TODO: Implement actual API call using http or dio package
      // Example with http package:
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/signup'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'firstName': firstName,
      //     'lastName': lastName,
      //     'email': email,
      //     'phone': phone,
      //     'password': password,
      //   }),
      // );
      //
      // if (response.statusCode == 201) {
      //   return AuthResponse.fromJson(jsonDecode(response.body));
      // } else {
      //   throw AuthException(
      //     message: 'Signup failed: ${response.statusCode}',
      //     code: 'API_ERROR',
      //   );
      // }

      // Mock response - remove in production
      await Future.delayed(const Duration(seconds: 2));
      return AuthResponse(
        success: true,
        message: 'Account created successfully',
        user: User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
        ),
        token: 'mock_token_456',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mock POST request to verify OTP
  Future<AuthResponse> postVerifyOtp({
    required String otp,
    required String userId,
    required String verifyType,
  }) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/verify-otp'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode({
      //     'otp': otp,
      //     'userId': userId,
      //     'verifyType': verifyType,
      //   }),
      // );

      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        success: true,
        message: '$verifyType verified successfully',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mock POST request to resend OTP
  Future<AuthResponse> postResendOtp({
    required String userId,
    required String verifyType,
  }) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/resend-otp'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode({
      //     'userId': userId,
      //     'verifyType': verifyType,
      //   }),
      // );

      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(success: true, message: 'OTP sent successfully');
    } catch (e) {
      rethrow;
    }
  }

  /// Mock POST request for password reset
  Future<AuthResponse> postResetPassword({required String email}) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/reset-password'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'email': email}),
      // );

      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        success: true,
        message: 'Password reset link sent to email',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mock POST request to update password
  Future<AuthResponse> postUpdatePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/update-password'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode({
      //     'userId': userId,
      //     'oldPassword': oldPassword,
      //     'newPassword': newPassword,
      //   }),
      // );

      await Future.delayed(const Duration(seconds: 1));
      return AuthResponse(
        success: true,
        message: 'Password updated successfully',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mock POST request to get current user
  Future<User> getUser({required String token}) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/user/profile'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //   },
      // );

      await Future.delayed(const Duration(milliseconds: 500));
      return User(
        id: 'user_123',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john@example.com',
        phone: '9876543210',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mock PUT request to update user profile
  Future<User> putUpdateProfile({
    required String userId,
    required Map<String, dynamic> updateData,
    required String token,
  }) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.put(
      //   Uri.parse('$_baseUrl/user/$userId/profile'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode(updateData),
      // );

      await Future.delayed(const Duration(seconds: 1));
      return User(
        id: userId,
        firstName: updateData['firstName'] ?? 'John',
        lastName: updateData['lastName'] ?? 'Doe',
        email: updateData['email'] ?? 'john@example.com',
        phone: updateData['phone'] ?? '9876543210',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Mock POST request for logout
  Future<bool> postLogout({required String token}) async {
    try {
      // TODO: Implement actual API call to invalidate token on backend
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/logout'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //   },
      // );

      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Mock POST request to refresh token
  Future<String> postRefreshToken({required String refreshToken}) async {
    try {
      // TODO: Implement actual API call
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/refresh-token'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'refreshToken': refreshToken}),
      // );

      await Future.delayed(const Duration(milliseconds: 500));
      return 'new_mock_token_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      rethrow;
    }
  }
}
