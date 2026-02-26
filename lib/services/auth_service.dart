import 'package:chocolate_clicks/models/user_model.dart';

/// Service for handling authentication operations
/// This is a complete authentication service that manages login, signup, and user sessions
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Current authenticated user
  User? _currentUser;

  // Authentication token
  String? _authToken;

  // Flag to track if user is authenticated
  bool _isAuthenticated = false;

  /// Get current authenticated user
  User? get currentUser => _currentUser;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Get current auth token
  String? get authToken => _authToken;

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

      // TODO: Replace with actual API call
      // For now, simulating a successful login response
      await Future.delayed(const Duration(seconds: 1));

      // Mock user object - replace with actual API response
      final mockUser = User(
        id: 'user_123',
        firstName: 'John',
        lastName: 'Doe',
        email: emailOrUsername.contains('@')
            ? emailOrUsername
            : 'john@example.com',
        phone: '9876543210',
        createdAt: DateTime.now(),
        isEmailVerified: true,
        isPhoneVerified: true,
      );

      const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

      // Update local state
      _currentUser = mockUser;
      _authToken = mockToken;
      _isAuthenticated = true;

      return AuthResponse(
        success: true,
        message: 'Login successful',
        user: mockUser,
        token: mockToken,
      );
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'LOGIN_FAILED');
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

      // TODO: Replace with actual API call
      // For now, simulating a successful signup response
      await Future.delayed(const Duration(seconds: 2));

      // Mock user object - replace with actual API response
      final newUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        isEmailVerified: false,
        isPhoneVerified: false,
      );

      const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

      // Update local state
      _currentUser = newUser;
      _authToken = mockToken;
      _isAuthenticated = true;

      return AuthResponse(
        success: true,
        message: 'Account created successfully',
        user: newUser,
        token: mockToken,
      );
    } catch (e) {
      throw AuthException(message: e.toString(), code: 'SIGNUP_FAILED');
    }
  }

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

      _currentUser = updatedUser;

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

  /// Reset password with email
  /// Throws AuthException on failure
  Future<AuthResponse> resetPassword({required String email}) async {
    try {
      if (email.isEmpty) {
        throw AuthException(
          message: 'Email is required',
          code: 'INVALID_INPUT',
        );
      }

      if (!_isValidEmail(email)) {
        throw AuthException(
          message: 'Invalid email address',
          code: 'INVALID_EMAIL',
        );
      }

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      return AuthResponse(
        success: true,
        message: 'Password reset link sent to $email',
      );
    } catch (e) {
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

      // TODO: Replace with actual API call
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

      // Clear local state
      _currentUser = null;
      _authToken = null;
      _isAuthenticated = false;
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
      _authToken = newToken;

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

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      final updatedUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

      _currentUser = updatedUser;

      return AuthResponse(
        success: true,
        message: 'Profile updated successfully',
        user: updatedUser,
        token: _authToken,
      );
    } catch (e) {
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
    _currentUser = null;
    _authToken = null;
    _isAuthenticated = false;
  }
}
