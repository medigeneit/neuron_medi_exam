import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';

// NEW: import the reusable background
import 'package:medi_exam/presentation/widgets/custom_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

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
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Logged in! (stub)')));
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Forgot Password tapped')));
  }

  void _onSignUp() {
    Get.offNamed(RouteNames.registration);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        body: CustomBackground(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: GlassCard(
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
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            const SizedBox(height: 24),

                            // Phone
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              autofillHints: const [AutofillHints.telephoneNumber],
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
                                if (value.isEmpty) {
                                  return 'Enter your phone number';
                                }
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
                                if ((v ?? '').isEmpty) {
                                  return 'Enter your password';
                                }
                                if ((v ?? '').length < 6) {
                                  return 'Must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

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
                                  style:
                                  TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                    child:
                                    Divider(color: cs.outlineVariant)),
                                const Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('or'),
                                ),
                                Expanded(
                                    child:
                                    Divider(color: cs.outlineVariant)),
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
        ),
      ),
    );
  }
}

// keep your existing _GlassCard

