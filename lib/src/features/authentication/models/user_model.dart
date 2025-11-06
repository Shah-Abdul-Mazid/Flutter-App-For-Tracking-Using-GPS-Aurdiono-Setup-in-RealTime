class UserModel {
  final String id;

  // Basic Info
  final String? username;  // Now nullable
  final String? password;
  final String? email;     // Nullable, though your query ensures it exists
  final String? role;
  final String? status;

  // Profile Info
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? contact;
  final String? altEmail;

  // Security / Password Reset
  final String? resetToken;
  final String? resetTokenExpiry;
  final String? lastPasswordReset;
  final bool emailVerified;
  final bool contactVerified;
  final String? otpCode;

  UserModel({
    required this.id,
    this.username,
    this.password,
    this.email,
    this.role,
    this.status,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.contact,
    this.altEmail,
    this.resetToken,
    this.resetTokenExpiry,
    this.lastPasswordReset,
    this.emailVerified = false,
    this.contactVerified = false,
    this.otpCode,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      username: json['username'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      contact: json['contact'] as String?,
      altEmail: json['altEmail'] as String?,
      resetToken: json['resetToken'] as String?,
      resetTokenExpiry: json['resetTokenExpiry'] as String?,
      lastPasswordReset: json['lastPasswordReset'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      contactVerified: json['contactVerified'] as bool? ?? false,
      otpCode: json['otpCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (contact != null) 'contact': contact,
      if (altEmail != null) 'altEmail': altEmail,
      if (resetToken != null) 'resetToken': resetToken,
      if (resetTokenExpiry != null) 'resetTokenExpiry': resetTokenExpiry,
      if (lastPasswordReset != null) 'lastPasswordReset': lastPasswordReset,
      'emailVerified': emailVerified,
      'contactVerified': contactVerified,
      if (otpCode != null) 'otpCode': otpCode,
    };
  }

  // Optional: Add getters for safe access with defaults
  String get safeUsername => username ?? '';
  String get safeRole => role ?? 'user';
  String get safeStatus => status ?? 'active';
  String get safeFirstName => firstName ?? '';
  String get safeLastName => lastName ?? '';
  String get safeDateOfBirth => dateOfBirth ?? '';
  String get safeContact => contact ?? '';
}