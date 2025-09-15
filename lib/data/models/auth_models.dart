class RegisterStartResponse {
  final bool status;
  final String message;
  final String phoneNumber;
  final int otpExpiresInMinutes;
  final String next;

  RegisterStartResponse({
    required this.status,
    required this.message,
    required this.phoneNumber,
    required this.otpExpiresInMinutes,
    required this.next,
  });

  factory RegisterStartResponse.fromJson(Map<String, dynamic> json) {
    return RegisterStartResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      otpExpiresInMinutes: json['otp_expires_in_minutes'] ?? 0,
      next: json['next'] ?? '',
    );
  }
}

class VerifyOtpResponse {
  final bool status;
  final String message;
  final String otpToken;
  final String next;

  VerifyOtpResponse({
    required this.status,
    required this.message,
    required this.otpToken,
    required this.next,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      otpToken: json['otp_token'] ?? '',
      next: json['next'] ?? '',
    );
  }
}

class LoginResponse {
  final bool status;
  final String message;
  final String token;
  final Doctor doctor;

  LoginResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.doctor,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      doctor: Doctor.fromJson(json['doctor'] ?? {}),
    );
  }
}

class RegisterCompleteResponse {
  final bool status;
  final String message;
  final String token;
  final Doctor doctor;

  RegisterCompleteResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.doctor,
  });

  factory RegisterCompleteResponse.fromJson(Map<String, dynamic> json) {
    return RegisterCompleteResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      doctor: Doctor.fromJson(json['doctor'] ?? {}),
    );
  }
}

class Doctor {
  final int id;
  final String name;
  final String phoneNumber;
  final String? email;
  final bool status;
  final String? photo;

  Doctor({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.status,
    this.photo,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'],
      status: json['status'] ?? false,
      photo: json['photo'],
    );
  }
}

class ErrorResponse {
  final String message;
  final Map<String, dynamic> errors;

  ErrorResponse({
    required this.message,
    required this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] ?? 'Something went wrong',
      errors: json['errors'] ?? {},
    );
  }
}