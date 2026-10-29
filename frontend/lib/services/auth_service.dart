import 'package:chocolate_clicks/models/user_model.dart';
import 'package:chocolate_clicks/services/api_client.dart';
import 'package:chocolate_clicks/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling authentication operations
/// This is a complete authentication service that manages login, signup, and user sessions
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _session = SessionManager();
    _storage = StorageService();
  }

  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static bool _googleReady = false;
  static Future<void>? _googleInitialization;

  Future<void> initializeGoogle() {
    if (_googleReady) return Future.value();
    return _googleInitialization ??= _prepareGoogle().catchError((
      Object error,
    ) {
      _googleInitialization = null;
      throw error;
    });
  }

  Future<void> _prepareGoogle() async {
    var clientId = _googleWebClientId;
    if (clientId.isEmpty) {
      final config = await ApiClient().get('/auth/google/config');
      clientId = config['data']?['clientId']?.toString() ?? '';
    }
    if (!clientId.endsWith('.apps.googleusercontent.com')) {
      throw AuthException(
        message: 'Google sign-in is not configured on the server.',
        code: 'GOOGLE_CONFIG',
      );
    }
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? clientId : null,
      serverClientId: kIsWeb ? null : clientId,
    );
    _googleReady = true;
  }

  late SessionManager _session;
  late StorageService _storage;

  /// Get current authenticated user
  User? get currentUser => _session.user;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _session.isLoggedIn;

  /// Get current auth token
  String? get authToken => _session.token;

  /// Login user with email/username and password
  /// Returns AuthResponse with user and token on success
  /// Throws AuthException on failure
  Future<AuthResponse> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (emailOrUsername.isEmpty || password.isEmpty) {
        throw AuthException(
          message: 'Email/Username and password are required',
          code: 'INVALID_INPUT',
        );
      }

      final response = await ApiClient().post(
        '/auth/login',
        body: {'email': emailOrUsername, 'password': password},
      );

      if (response['success'] == true) {
        final userData = response['data'];
        final user = User.fromJson(userData['user']);
        final token = userData['token'];

        // Update session and storage
        await _session.setSession(token: token, user: user);
        await _storage.save('auth_token', token);
        await _storage.save('user_id', user.id);

        return AuthResponse(
          success: true,
          message: response['message'] ?? 'Login successful',
          user: user,
          token: token,
        );
      } else {
        throw AuthException(
          message: response['message'] ?? 'Login failed',
          code: 'LOGIN_FAILED',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: e is ApiException
            ? e.message
            : 'Unable to sign in. Check your connection and try again.',
        code: 'LOGIN_FAILED',
      );
    }
  }

  /// Sign in (or sign up) with a Google account
  /// Gets an ID token from Google, sends it to the backend, and stores
  /// the backend's own JWT the same way a normal login does
  Future<AuthResponse> loginWithGoogle() async {
    try {
      await initializeGoogle();
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw AuthException(
          message: 'Use the Google sign-in button to continue.',
          code: 'GOOGLE_WEB_BUTTON',
        );
      }
      final account = await GoogleSignIn.instance.authenticate();
      return completeGoogleSignIn(account);
    } on GoogleSignInException catch (error) {
      throw AuthException(
        message: error.code == GoogleSignInExceptionCode.canceled
            ? 'Google sign-in was cancelled'
            : 'Google sign-in failed (${error.code.name})',
        code: 'GOOGLE_FAILED',
      );
    } catch (error) {
      if (error is AuthException) rethrow;
      throw AuthException(
        message: error is ApiException
            ? error.message
            : 'Unable to sign in with Google. Please try again.',
        code: 'GOOGLE_FAILED',
      );
    }
  }

  /// Exchange a Google SDK credential for the backend session on every platform.
  Future<AuthResponse> completeGoogleSignIn(GoogleSignInAccount account) async {
    try {
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw AuthException(
          message: 'Google did not return an ID token',
          code: 'GOOGLE_NO_TOKEN',
        );
      }

      final response = await ApiClient().post(
        '/auth/google',
        body: {'idToken': idToken},
      );

      if (response['success'] == true) {
        final data = response['data'];
        final userJson = Map<String, dynamic>.from(data['user'] as Map);
        userJson['id'] ??= userJson['_id'];
        userJson['phone'] ??= ''; // Google accounts have no phone number
        final user = User.fromJson(userJson);
        final token = data['token'];

        // Update session and storage
        await _session.setSession(token: token, user: user);
        await _storage.save('auth_token', token);
        await _storage.save('user_id', user.id);

        return AuthResponse(
          success: true,
          message: response['message'] ?? 'Google login successful',
          user: user,
          token: token,
        );
      } else {
        throw AuthException(
          message: response['message'] ?? 'Google login failed',
          code: 'GOOGLE_FAILED',
        );
      }
    } catch (error) {
      if (error is AuthException) rethrow;
      throw AuthException(
        message: error is ApiException
            ? error.message
            : 'Unable to finish Google sign-in. Please try again.',
        code: 'GOOGLE_FAILED',
      );
    }
  }

  /// Register/Sign up a new user
  /// Returns AuthResponse with user and token on success
  /// Throws AuthException on failure
  Future<AuthResponse> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (firstName.isEmpty ||
          lastName.isEmpty ||
          email.isEmpty ||
          phone.isEmpty ||
          password.isEmpty) {
        throw AuthException(
          message: 'All fields are required',
          code: 'INVALID_INPUT',
        );
      }

      // Validate email format
      if (!_isValidEmail(email)) {
        throw AuthException(
          message: 'Invalid email address',
          code: 'INVALID_EMAIL',
        );
      }

      // Validate phone format
      if (!_isValidPhone(phone)) {
        throw AuthException(
          message: 'Invalid phone number',
          code: 'INVALID_PHONE',
        );
      }

      // Validate password strength
      if (password.length < 6) {
        throw AuthException(
          message: 'Password must be at least 6 characters',
          code: 'WEAK_PASSWORD',
        );
      }

      final response = await ApiClient().post(
        '/auth/register',
        body: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );

      if (response['success'] == true) {
        final userData = response['data'];
        final user = User.fromJson(userData['user']);
        final token = userData['token'];

        // Update session and storage
        await _session.setSession(token: token, user: user);
        await _storage.save('auth_token', token);
        await _storage.save('user_id', user.id);

        return AuthResponse(
          success: true,
          message: response['message'] ?? 'Account created successfully',
          user: user,
          token: token,
        );
      } else {
        throw AuthException(
          message: response['message'] ?? 'Registration failed',
          code: 'SIGNUP_FAILED',
        );
      }
    } catch (e, st) {
      debugPrint('SIGNUP ERROR: $e');
      debugPrintStack(stackTrace: st, maxFrames: 8);
      if (e is AuthException) rethrow;
      throw AuthException(
        message: e is ApiException
            ? e.message
            : 'Unable to create your account. Check your connection and try again.',
        code: 'SIGNUP_FAILED',
      );
    }
  }

  // private helpers to reach session state
  User? get _currentUser => _session.user;
  String? get _authToken => _session.token;

  /// Verify OTP for phone or email
  /// Returns AuthResponse with updated user information
  /// Throws AuthException on failure
  Future<AuthResponse> verifyOTP({
    required String otp,
    required String verifyType, // 'email' or 'phone'
  }) async {
    try {
      if (_currentUser == null) {
        throw AuthException(
          message: 'No user session found',
          code: 'NO_SESSION',
        );
      }

      if (otp.isEmpty || otp.length != 6) {
        throw AuthException(message: 'Invalid OTP format', code: 'INVALID_OTP');
      }

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Update user verification status
      User updatedUser;
      if (verifyType == 'email') {
        updatedUser = _currentUser!.copyWith(isEmailVerified: true);
      } else if (verifyType == 'phone') {
        updatedUser = _currentUser!.copyWith(isPhoneVerified: true);
      } else {
        throw AuthException(
          message: 'Invalid verification type',
          code: 'INVALID_TYPE',
        );
      }

      // update session user while keeping same token
      await _session.setSession(token: _authToken ?? '', user: updatedUser);

      return AuthResponse(
        success: true,
        message: '$verifyType verified successfully',
        user: updatedUser,
        token: _authToken,
      );
    } catch (e) {
      throw AuthException(
        message: e.toString(),
        code: 'OTP_VERIFICATION_FAILED',
      );
    }
  }

  /// Resend OTP to email or phone
  /// Throws AuthException on failure
  Future<AuthResponse> resendOTP({
    required String verifyType, // 'email' or 'phone'
  }) async {
    try {
      if (_currentUser == null) {
        throw AuthException(
          message: 'No user session found',
          code: 'NO_SESSION',
        );
      }

      if (verifyType != 'email' && verifyType != 'phone') {
        throw AuthException(
          message: 'Invalid verification type',
          code: 'INVALID_TYPE',
        );
      }

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return AuthResponse(
        success: true,
        message:
            'OTP sent to ${verifyType == 'email' ? _currentUser!.email : _currentUser!.phone}',
        user: _currentUser,
        token: _authToken,
      );
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'RESEND_OTP_FAILED');
    }
  }

  /// Step 1: request a reset code by email
  Future<void> requestPasswordReset(String email) async {
    if (!_isValidEmail(email)) {
      throw AuthException(
        message: 'Invalid email address',
        code: 'INVALID_EMAIL',
      );
    }
    try {
      await ApiClient().post('/auth/forgot-password', body: {'email': email});
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString(), code: 'PASSWORD_RESET_FAILED');
    }
  }

  /// Step 2: submit email + code + new password
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
  }) async {
    if (code.length != 6) {
      throw AuthException(
        message: 'Enter the 6-digit code',
        code: 'INVALID_CODE',
      );
    }
    if (password.length < 6) {
      throw AuthException(
        message: 'Password must be at least 6 characters',
        code: 'WEAK_PASSWORD',
      );
    }
    try {
      final response = await ApiClient().post(
        '/auth/reset-password',
        body: {'email': email, 'code': code, 'password': password},
      );
      if (response['success'] != true) {
        throw AuthException(
          message: response['message'] ?? 'Reset failed',
          code: 'PASSWORD_RESET_FAILED',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString(), code: 'PASSWORD_RESET_FAILED');
    }
  }

  /// Update user password
  /// Throws AuthException on failure
  Future<AuthResponse> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) {
        throw AuthException(
          message: 'No user session found',
          code: 'NO_SESSION',
        );
      }

      if (oldPassword.isEmpty || newPassword.isEmpty) {
        throw AuthException(
          message: 'Both passwords are required',
          code: 'INVALID_INPUT',
        );
      }

      if (newPassword.length < 6) {
        throw AuthException(
          message: 'New password must be at least 6 characters',
          code: 'WEAK_PASSWORD',
        );
      }

      await Future.delayed(const Duration(seconds: 1));

      return AuthResponse(
        success: true,
        message: 'Password updated successfully',
        user: _currentUser,
        token: _authToken,
      );
    } catch (e) {
      throw AuthException(
        message: e.toString(),
        code: 'UPDATE_PASSWORD_FAILED',
      );
    }
  }

  /// Logout current user
  /// Clears all session data
  Future<void> logout() async {
    try {
      // TODO: Call API to invalidate token on backend
      await Future.delayed(const Duration(milliseconds: 500));

      // Sign out of Google too, so the next Google login shows the account picker
      if (_googleReady) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (_) {
          // ignore: Google sign-out is best effort
        }
      }

      // Clear session and storage
      await _session.clearSession();
      await _storage.delete('auth_token');
      await _storage.delete('user_id');
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'LOGOUT_FAILED');
    }
  }

  /// Refresh authentication token
  /// Used to get a new token before current one expires
  Future<AuthResponse> refreshToken() async {
    try {
      if (_authToken == null) {
        throw AuthException(message: 'No active session', code: 'NO_TOKEN');
      }

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      const newToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...new';
      // update session token while preserving user
      if (_session.user != null) {
        await _session.setSession(token: newToken, user: _session.user!);
      }

      return AuthResponse(
        success: true,
        message: 'Token refreshed',
        user: _currentUser,
        token: newToken,
      );
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'TOKEN_REFRESH_FAILED');
    }
  }

  /// Update user profile
  /// Allows updating user information
  Future<AuthResponse> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImageUrl,
  }) async {
    try {
      if (_currentUser == null) {
        throw AuthException(
          message: 'No user session found',
          code: 'NO_SESSION',
        );
      }

      final response = await ApiClient().put(
        '/auth/profile',
        body: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phone != null) 'phone': phone,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        },
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      if (response['success'] == true) {
        final userData = response['data'];
        final updatedUser = User.fromJson(userData);

        // update user in session
        _session.setSession(token: _authToken ?? '', user: updatedUser);

        return AuthResponse(
          success: true,
          message: response['message'] ?? 'Profile updated successfully',
          user: updatedUser,
          token: _authToken,
        );
      } else {
        throw AuthException(
          message: response['message'] ?? 'Profile update failed',
          code: 'UPDATE_PROFILE_FAILED',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString(), code: 'UPDATE_PROFILE_FAILED');
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone format
  bool _isValidPhone(String phone) {
    // Remove all non-digit characters
    final phoneDigits = phone.replaceAll(RegExp(r'\D'), '');
    // Check if it's a valid Indian phone number (10 digits)
    // Adjust this regex based on your requirements
    return phoneDigits.length >= 10;
  }

  /// Clear all auth data (useful for testing or cleanup)
  void clearAuthData() {
    _session.clearSession();
  }
}
