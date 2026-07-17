class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String email;
  final String role;
  final String firstName;
  final String lastName;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }
}

class UserInfo {
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final bool isLoggedIn;

  const UserInfo({
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.isLoggedIn = true,
  });

  static const guest = UserInfo(
    email: '',
    role: '',
    firstName: '',
    lastName: '',
    isLoggedIn: false,
  );

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == 'ADMIN';
}
