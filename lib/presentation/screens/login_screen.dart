import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: Replace with your auth call.
    await Future.delayed(const Duration(milliseconds: 900));

    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged in! (stub)')),
    );
  }

  void _onForgotPassword() {
    // TODO: Navigate to your reset flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Forgot Password tapped')),
    );
  }

  void _onSignUp() {
    Get.offNamed(RouteNames.registration); // Navigate to your sign-up screen
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(.15),
                    cs.secondary.withOpacity(.10),
                    cs.tertiary.withOpacity(.10),
                  ],
                ),
              ),
            ),
            // Subtle blobs
            Positioned(
              top: -80,
              left: -60,
              child: _Blob(color: cs.primary.withOpacity(.20), size: 220),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: _Blob(color: cs.secondary.withOpacity(.18), size: 180),
            ),
      
            // Content
            Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: _GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8),
                              Image.asset(AssetsPath.appLogo),
                              const SizedBox(height: 12),
                              Text(
                                'Welcome back',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.primaryTextColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Log in to continue',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 24),
      
                              // Phone
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber
                                ],
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9+\s-]')),
                                  LengthLimitingTextInputFormatter(18),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Phone number',
                                  prefixText: '+88',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                validator: (v) {
                                  final value =
                                      (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
                                  if (value.isEmpty)
                                    return 'Enter your phone number';
                                  // Basic sanity check: at least 10 digits incl. country code
                                  final digits =
                                      value.replaceAll(RegExp(r'[^0-9+]'), '');
                                  if (digits.replaceAll('+88', '').length != 11) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
      
                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscure,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(_obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    tooltip: _obscure
                                        ? 'Show password'
                                        : 'Hide password',
                                  ),
                                ),
                                validator: (v) {
                                  if ((v ?? '').isEmpty)
                                    return 'Enter your password';
                                  if ((v ?? '').length < 6)
                                    return 'Must be at least 6 characters';
                                  return null;
                                },
                              ),
      
                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _onForgotPassword,
                                  child: const Text('Forgot password?'),
                                ),
                              ),
      
                              const SizedBox(height: 8),
      
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor,
                                    foregroundColor: AppColor.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _onLogin,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Icon(Icons.login),
                                  label: const Text(
                                    'Log in',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
      
                              const SizedBox(height: 16),
      
                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                      child: Divider(color: cs.outlineVariant)),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('or'),
                                  ),
                                  Expanded(
                                      child: Divider(color: cs.outlineVariant)),
                                ],
                              ),
      
                              const SizedBox(height: 12),
      
                              // Sign up
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(color: cs.onSurfaceVariant),
                                  ),
                                  TextButton(
                                    onPressed: _onSignUp,
                                    child: const Text('Sign up'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.35),
            blurRadius: 60,
            spreadRadius: 10,
          )
        ],
      ),
    );
  }
}
