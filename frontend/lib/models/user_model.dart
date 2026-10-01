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
      '_id': id,
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
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isEmailVerified: json['isEmailVerified'] == true,
      isPhoneVerified: json['isPhoneVerified'] == true,
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
    final data = json['data'] as Map<String, dynamic>?;
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      user: data?['user'] != null ? User.fromJson(data!['user']) : null,
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
