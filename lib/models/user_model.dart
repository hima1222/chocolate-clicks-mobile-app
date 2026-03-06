/// User model for authentication and profile management
class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.createdAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
  });

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
    };
  }

  /// Create user from JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
    );
  }
}

/// Authentication response model
class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;
  final String? refreshToken;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.refreshToken,
  });

  /// Create from JSON response
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}

/// Exception for authentication errors
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() => 'AuthException: $message';
}
