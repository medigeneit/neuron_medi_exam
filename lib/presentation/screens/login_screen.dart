import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/network_response.dart';
import 'package:medi_exam/data/services/auth_service.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
// Background & glass card you already have
import 'package:medi_exam/presentation/widgets/custom_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/helpers/login_screen_helpers.dart';

enum _AuthStep { enterPhone, login, verifyOtp, completeRegistration }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Services
  final _auth = AuthService();

  // Controllers
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController(); // holds concatenated 6 digits
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  // OTP widget key so we can clear boxes on resend
  final GlobalKey<OtpCodeInputState> _otpFieldKey =
  GlobalKey<OtpCodeInputState>();

  // State
  _AuthStep _step = _AuthStep.enterPhone;
  bool _isLoading = false;
  bool _obscure = true;
  String? _otpToken; // from /register/verify

  // Timer state
  Timer? _otpTimer;
  int _otpRemainingSeconds = 0;

  // --- Cache nav intent so multi-step registration still returns properly ---
  late final bool _popOnSuccess;
  String? _returnRoute;
  dynamic _returnArguments;
  String? _message;

  @override
  void initState() {
    super.initState();
    final args = (Get.arguments as Map?) ?? {};
    _popOnSuccess = args['popOnSuccess'] == true;
    _returnRoute = args['returnRoute'] as String?;
    _returnArguments = args['returnArguments'];
    _message = args['message'];
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ------------------ ACTIONS ------------------

  Future<void> _startOrMoveToLogin() async {
    if (!_validatePhone()) return;

    setState(() => _isLoading = true);
    try {
      final res = await _auth.startRegistration(phoneNumber: _cleanPhone());

      if (res.isSuccess && res.statusCode == 200) {
        // New user -> OTP step
        final data = res.responseData as Map<String, dynamic>;
        _toast(data['message'] ?? 'OTP sent');

        // get minutes from response and start countdown
        final minutes = (data['otp_expires_in_minutes'] is num)
            ? (data['otp_expires_in_minutes'] as num).toInt()
            : 5;
        _startOtpTimer(minutes);

        // switch to OTP UI and clear previous input
        _otpController.clear();
        _otpFieldKey.currentState?.clear();

        setState(() => _step = _AuthStep.verifyOtp);
      } else if (res.statusCode == 409) {
        // Already exists -> go to login
        final msg = _tryParseMessage(res.errorMessage);
        /* _toast(msg ?? 'এই নম্বরটি দিয়ে আগে রেজিস্টার করা হয়েছে। অনুগ্রহ করে লগইন করুন।'); */
        _stopOtpTimer();
        setState(() => _step = _AuthStep.login);
      } else {
        _error(_extractAnyMessage(res) ?? 'Something went wrong');
      }
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (!_validatePhone()) return;
    if (_passwordController.text.trim().length < 6) {
      _error('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _auth.login(
        phoneNumber: _cleanPhone(),
        password: _passwordController.text.trim(),
      );

      if (res.isSuccess && res.statusCode == 200) {
        final data = res.responseData as Map<String, dynamic>;
        await _persistAuthAndNavigate(data);
      } else if (res.statusCode == 422) {
        final msg = _tryParseMessage(res.errorMessage) ?? 'Invalid credentials.';
        _error(msg);
      } else {
        _error(_extractAnyMessage(res) ?? 'Login failed');
      }
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6 || int.tryParse(otp) == null) {
      _error('Enter the 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _auth.verifyOtp(
        phoneNumber: _cleanPhone(),
        otp: otp,
      );

      if (res.isSuccess && res.statusCode == 200) {
        final data = res.responseData as Map<String, dynamic>;
        _otpToken = data['otp_token']?.toString();
        _toast(data['message'] ?? 'OTP verified');
        _stopOtpTimer();
        setState(() => _step = _AuthStep.completeRegistration);
      } else {
        _error(_extractAnyMessage(res) ?? 'OTP verification failed');
      }
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completeRegistration() async {
    if (_nameController.text.trim().isEmpty) {
      _error('Please enter your name');
      return;
    }
    if (_passwordController.text.trim().length < 6) {
      _error('Password must be at least 6 characters');
      return;
    }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      _error('Passwords do not match');
      return;
    }
    if (_otpToken == null || _otpToken!.isEmpty) {
      _error('Missing OTP token. Please verify again.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _auth.completeRegistration(
        phoneNumber: _cleanPhone(),
        otpToken: _otpToken!,
        name: _nameController.text.trim(),
        password: _passwordController.text.trim(),
        passwordConfirmation: _confirmPasswordController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      );

      // ✅ treat any 2xx as success (covers 200, 201, 204...)
      final ok = res.isSuccess && res.statusCode >= 200 && res.statusCode < 300;
      if (ok) {
        final data = res.responseData as Map<String, dynamic>;
        _toast(data['message'] ?? 'Registration complete');
        await _persistAuthAndNavigate(data);
      } else {
        _error(_extractAnyMessage(res) ?? 'Registration failed');
      }
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------ HELPERS ------------------

  void _startOtpTimer(int minutes) {
    _otpTimer?.cancel();
    setState(() => _otpRemainingSeconds = minutes * 60);
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_otpRemainingSeconds <= 1) {
        t.cancel();
        setState(() => _otpRemainingSeconds = 0);
        // Clear boxes when expired
        _otpController.clear();
        _otpFieldKey.currentState?.clear();
        FocusScope.of(context).unfocus();
      } else {
        setState(() => _otpRemainingSeconds -= 1);
      }
    });
  }

  void _stopOtpTimer() {
    _otpTimer?.cancel();
    _otpTimer = null;
    setState(() => _otpRemainingSeconds = 0);
  }

  String _formatMmSs(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _cleanPhone() {
    // Keep digits only, enforce 11-digit BD starting with 01
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits;
  }

  bool _validatePhone() {
    final digits = _cleanPhone();
    if (!RegExp(r'^01\d{9}$').hasMatch(digits)) {
      _error('Enter a valid 11-digit phone number (starts with 01)');
      return false;
    }
    return true;
  }

  Future<void> _persistAuthAndNavigate(Map<String, dynamic> data) async {
    String? token = data['token']?.toString();
    Map<String, dynamic>? doctor = data['doctor'] as Map<String, dynamic>?;

    // 🔁 Some APIs don't return token on registration. Try auto-login once.
    if ((token == null || token.isEmpty) && _step == _AuthStep.completeRegistration) {
      final loginRes = await _auth.login(
        phoneNumber: _cleanPhone(),
        password: _passwordController.text.trim(),
      );
      if (loginRes.isSuccess &&
          loginRes.statusCode == 200 &&
          loginRes.responseData is Map<String, dynamic>) {
        final ld = loginRes.responseData as Map<String, dynamic>;
        token = ld['token']?.toString();
        doctor = ld['doctor'] as Map<String, dynamic>?;
        // merge snapshot for record-keeping
        data = {...data, ...ld};
      }
    }

    if (token == null || token.isEmpty) {
      _error('No token received');
      return;
    }

    // Persist auth
    await LocalStorageService.setString(LocalStorageService.token, token);
    if (doctor != null) {
      await LocalStorageService.setObject(LocalStorageService.userData, doctor);
    }

    // Mark logged in and store snapshot
    await LocalStorageService.setString(LocalStorageService.isLoggedIn, 'true');
    await LocalStorageService.setString(
      LocalStorageService.loggedInAt,
      DateTime.now().toIso8601String(),
    );

    // Keep last whole auth response (message/token/doctor)
    await LocalStorageService.setObject(
      LocalStorageService.lastAuthSnapshot,
      data,
    );

    // Clear OTP artifacts now that we're authenticated
    await LocalStorageService.setString(LocalStorageService.lastOtpCode, '');
    await LocalStorageService.setString(LocalStorageService.otpToken, '');
    await LocalStorageService.setString(LocalStorageService.lastOtpExpiresAt, '');
    await LocalStorageService.setString(LocalStorageService.lastOtpVerifiedAt, '');

// In login_screen.dart, in _persistAuthAndNavigate method
    print('Navigation intent - popOnSuccess: $_popOnSuccess, returnRoute: $_returnRoute');

    if (_popOnSuccess) {
      // ensure any snackbars/dialogs are gone, then pop the route that was awaited
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();
      if (Get.isDialogOpen ?? false) Get.back(); // close dialog/sheet if any
      Get.back(result: true, closeOverlays: true);
      return;
    } else if (_returnRoute != null) {
      print('Going to return route: $_returnRoute');
      Get.offAllNamed(_returnRoute!, arguments: _returnArguments);
    } else {
      print('Going to navBar');
      Get.offAllNamed(RouteNames.navBar, arguments: 0);
    }
  }

  String? _tryParseMessage(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw);
      if (m is Map && m['message'] != null) return m['message'].toString();
    } catch (_) {}
    return null;
  }

  String? _extractAnyMessage(NetworkResponse res) {
    if (res.responseData is Map &&
        (res.responseData as Map)['message'] != null) {
      return (res.responseData as Map)['message'].toString();
    }
    return _tryParseMessage(res.errorMessage);
  }

  void _toast(String msg) {
    Get.snackbar(
      'Success',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _error(String msg) {
    Get.snackbar(
      'Error',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        body: CustomBackground(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  if (_message != null && _message!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 2),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final textStyle = TextStyle(
                                  fontSize: Sizes.smallText(context),
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.primaryColor.withOpacity(0.6),
                                );

                                final textPainter = TextPainter(
                                  text: TextSpan(text: 'Text', style: textStyle),
                                  textDirection: TextDirection.ltr,
                                );
                                textPainter.layout();
                                final textHeight = textPainter.preferredLineHeight;

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: textHeight,
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: Icon(
                                          Icons.info_outline,
                                          color: AppColor.primaryColor.withOpacity(0.6),
                                          size: Sizes.extraSmallIcon(context),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _message!,
                                        textAlign: TextAlign.start,
                                        style: textStyle,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: GlassCard(
                        child: Padding(
                          padding:  EdgeInsets.all(22.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.grey),
                                  onPressed: _handleBack,
                                  tooltip: 'Back',
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 8),
                                    Image.asset(AssetsPath.appLogo),
                                    const SizedBox(height: 12),
                                    ShaderMask(
                                      shaderCallback: (r) => LinearGradient(
                                        colors: [AppColor.indigo, AppColor.purple],
                                      ).createShader(r),
                                      child: Text(
                                        _titleForStep(),
                                        style:  TextStyle(
                                          fontSize: Sizes.bigText(context),
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white, // masked by shader
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _subtitleForStep(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: cs.onSurface.withOpacity(.7)),
                                    ),
                                    const SizedBox(height: 20),

                                    // Phone is visible on all steps
                                    PhoneField(
                                      controller: _phoneController,
                                      enabled: _step == _AuthStep.enterPhone,
                                    ),

                                    const SizedBox(height: 14),

                                    if (_step == _AuthStep.login) ...[
                                      PasswordField(
                                        controller: _passwordController,
                                        obscure: _obscure,
                                        onToggleObscure: () => setState(() => _obscure = !_obscure),
                                      ),
                                      const SizedBox(height: 18),
                                      PrimaryButton(
                                        label: _isLoading ? 'Logging in...' : 'Login',
                                        icon: Icons.login,
                                        loading: _isLoading,
                                        onPressed: _isLoading ? null : _login,
                                      ),
                                    ] else if (_step == _AuthStep.verifyOtp) ...[
                                      if (_otpRemainingSeconds > 0) ...[
                                        // --- OTP code input (6 boxes) ---
                                        OtpCodeInput(
                                          key: _otpFieldKey,
                                          length: 6,
                                          onChanged: (code) => _otpController.text = code,
                                          onCompleted: (code) {
                                            _otpController.text = code;
                                            // optionally auto-submit: _verifyOtp();
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.timer_outlined, size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Resend in ${_formatMmSs(_otpRemainingSeconds)}',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        PrimaryButton(
                                          label: _isLoading ? 'Verifying...' : 'Verify',
                                          icon: Icons.verified_outlined,
                                          loading: _isLoading,
                                          onPressed: _isLoading ? null : _verifyOtp,
                                        ),
                                      ] else ...[
                                        // Timer over → hide OTP input and verify button; show ONLY Resend
                                        TextButton.icon(
                                          onPressed: _isLoading
                                              ? null
                                              : () async {
                                            await _startOrMoveToLogin(); // resend & restart timer
                                          },
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Resend OTP'),
                                        ),
                                      ],
                                    ] else if (_step == _AuthStep.completeRegistration) ...[
                                      NameField(controller: _nameController),
                                      const SizedBox(height: 12),
                                      EmailField(controller: _emailController),
                                      const SizedBox(height: 12),
                                      PasswordField(
                                        controller: _passwordController,
                                        obscure: _obscure,
                                        onToggleObscure: () => setState(() => _obscure = !_obscure),
                                      ),
                                      const SizedBox(height: 12),
                                      ConfirmPasswordField(controller: _confirmPasswordController),
                                      const SizedBox(height: 18),
                                      PrimaryButton(
                                        label: _isLoading ? 'Joining...' : 'Join us',
                                        icon: Icons.check_circle_outline,
                                        loading: _isLoading,
                                        onPressed: _isLoading ? null : _completeRegistration,
                                      ),
                                    ] else ...[
                                      // _AuthStep.enterPhone
                                      PrimaryButton(
                                        label: _isLoading ? 'Please wait...' : 'Join us',
                                        icon: Icons.person_add_alt_1_outlined,
                                        loading: _isLoading,
                                        onPressed: _isLoading ? null : _startOrMoveToLogin,
                                      ),
                                    ],

                                    const SizedBox(height: 16),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_step != _AuthStep.enterPhone)
                                          TextButton.icon(
                                            onPressed: _isLoading
                                                ? null
                                                : () {
                                              _stopOtpTimer();
                                              setState(() {
                                                _step = _AuthStep.enterPhone;
                                                _otpController.clear();
                                                _passwordController.clear();
                                                _confirmPasswordController.clear();
                                                _otpToken = null;
                                              });
                                            },
                                            icon: const Icon(Icons.arrow_back),
                                            label: const Text('Change number'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _titleForStep() {
    switch (_step) {
      case _AuthStep.enterPhone:
        return '${AssetsPath.appName}';
      case _AuthStep.login:
        return 'Welcome back';
      case _AuthStep.verifyOtp:
        return 'Verify your phone';
      case _AuthStep.completeRegistration:
        return 'Complete Registration';
    }
  }

  String _subtitleForStep() {
    switch (_step) {
      case _AuthStep.enterPhone:
        return 'Enter your 11-digit phone number to get started';
      case _AuthStep.login:
        return 'Enter your password to login';
      case _AuthStep.verifyOtp:
        return 'Enter the OTP sent to your phone';
      case _AuthStep.completeRegistration:
        return 'Complete your registration details';
    }
  }

  void _handleBack() {
    // If this screen was pushed (e.g., from Enroll CTA), pop back.
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      // Return an explicit "false" so the caller knows user cancelled
      Get.back(result: false);
    } else {
      // If this screen was opened as a root (no back stack), go to home
      Get.offAllNamed(RouteNames.navBar, arguments: 0);
    }
  }
}
