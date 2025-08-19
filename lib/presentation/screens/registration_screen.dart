import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';
import 'package:medi_exam/presentation/utils/routes.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bmdcController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _selectedCollege;

  final List<String> _medicalColleges = const [
    'Dhaka Medical College',
    'Sir Salimullah Medical College',
    'Chittagong Medical College',
    'Rajshahi Medical College',
    'Mymensingh Medical College',
    'Sylhet MAG Osmani Medical College',
    'Rangpur Medical College',
    'Shaheed Suhrawardy Medical College',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bmdcController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Replace with your API call to register a user
    await Future.delayed(const Duration(milliseconds: 900));

    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registered! (stub)')),
    );
  }

  void _onSignIn() {
    // If you pushed this screen from Login, popping will go back there.
    Navigator.of(context).maybePop();
    Get.offNamed(RouteNames.login);
    // Or, if you have a LoginScreen widget, push to it:
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
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
          // Blobs
          Positioned(
            top: -90,
            left: -70,
            child: _Blob(color: cs.primary.withOpacity(.20), size: 240),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: _Blob(color: cs.secondary.withOpacity(.18), size: 190),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                              'Create your account',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Join in and get started',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Name
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              autofillHints: const [AutofillHints.name],
                              decoration: const InputDecoration(
                                labelText: 'Full name',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if ((v ?? '').trim().isEmpty) return 'Enter your name';
                                if ((v ?? '').trim().length < 2) return 'Name is too short';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.alternate_email),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return 'Enter your email';
                                final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                                if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Phone
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              autofillHints: const [AutofillHints.telephoneNumber],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                                LengthLimitingTextInputFormatter(18),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Phone number',
                                prefixText: '+88',

                                prefixIcon: Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final value = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
                                if (value.isEmpty) return 'Enter your phone number';
                                final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
                                if (digits.replaceAll('+88', '').length != 11) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // BMDC number
                            TextFormField(
                              controller: _bmdcController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'BMDC number',
                                prefixIcon: Icon(Icons.confirmation_number_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return 'Enter your BMDC number';
                                if (value.length < 6) return 'BMDC number seems too short';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Medical College dropdown
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final screenHeight = MediaQuery.of(context).size.height;

                                return DropdownButtonFormField<String>(
                                  value: _selectedCollege,
                                  isExpanded: true, // takes full width, prevents layout overflow
                                  menuMaxHeight: screenHeight * 0.45, // responsive popup height
                                  items: _medicalColleges
                                      .map(
                                        (c) => DropdownMenuItem<String>(
                                      value: c,
                                      child: Text(
                                        c,
                                        overflow: TextOverflow.ellipsis, // long names truncate nicely
                                        maxLines: 1,
                                      ),
                                    ),
                                  )
                                      .toList(),
                                  // Ensures the selected value in the field also ellipsizes
                                  selectedItemBuilder: (context) => _medicalColleges
                                      .map(
                                        (c) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        c,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedCollege = v),
                                  decoration: const InputDecoration(
                                    labelText: 'Medical college',
                                    prefixIcon: Icon(Icons.school_outlined),
                                    border: OutlineInputBorder(),
                                    // optional: guarantee comfy tap target height
                                    constraints: BoxConstraints(minHeight: 56),
                                  ),
                                  validator: (v) => v == null ? 'Select your medical college' : null,
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePass,
                              autofillHints: const [AutofillHints.newPassword],
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                                  tooltip: _obscurePass ? 'Show password' : 'Hide password',
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) return 'Create a password';
                                if (value.length < 6) return 'Must be at least 6 characters';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Confirm password
                            TextFormField(
                              controller: _confirmController,
                              obscureText: _obscureConfirm,
                              autofillHints: const [AutofillHints.newPassword],
                              decoration: InputDecoration(
                                labelText: 'Confirm password',
                                prefixIcon: const Icon(Icons.lock_reset_outlined),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscureConfirm = !_obscureConfirm),
                                  icon: Icon(
                                      _obscureConfirm ? Icons.visibility_off : Icons.visibility),
                                  tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
                                ),
                              ),
                              validator: (v) {
                                if ((v ?? '').isEmpty) return 'Confirm your password';
                                if (v != _passwordController.text) return 'Passwords do not match';
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Register button
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
                                onPressed: _isLoading ? null : _onRegister,
                                icon: _isLoading
                                    ? const SizedBox(
                                    width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.person_add_alt_1),
                                label: const Text(
                                  'Create account',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Sign in
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                                TextButton(
                                  onPressed: _onSignIn,
                                  child: const Text('Sign in'),
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
    );
  }
}

/// Local copy of the glass card used in your Login screen.
/// If you already have a shared widget, feel free to replace with that.
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
