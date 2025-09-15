import 'package:logger/logger.dart';

import 'package:medi_exam/data/network_caller.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/utils/urls.dart';

/// Centralized auth-related API calls.
/// Keeps UI/widgets clean and makes it easy to mock in tests.
class AuthService {
  AuthService._internal()
      : _net = NetworkCaller(logger: Logger());

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  final NetworkCaller _net;

  Future<NetworkResponse> startRegistration({
    required String phoneNumber,
  }) {
    return _net.postRequest(
      Urls.registerStart,
      body: {'phone_number': phoneNumber},
    );
  }

  Future<NetworkResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) {
    return _net.postRequest(
      Urls.registerVerify,
      body: {'phone_number': phoneNumber, 'otp': otp},
    );
  }

  Future<NetworkResponse> completeRegistration({
    required String phoneNumber,
    required String otpToken,
    required String name,
    required String password,
    required String passwordConfirmation,
    String? email,
  }) {
    final body = {
      'phone_number': phoneNumber,
      'otp_token': otpToken,
      'name': name,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (email != null && email.isNotEmpty) 'email': email,
    };

    return _net.postRequest(Urls.registerComplete, body: body);
  }

  Future<NetworkResponse> login({
    required String phoneNumber,
    required String password,
  }) {
    return _net.postRequest(
      Urls.login,
      body: {'phone_number': phoneNumber, 'password': password},
    );
    // On 200 -> { status, message, token, doctor { ... } }
    // On 422 -> { message: "Invalid credentials.", errors: { phone_number: ["Invalid credentials."] } }
  }
}
