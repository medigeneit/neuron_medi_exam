import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_background.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

class ProfileSectionScreen extends StatefulWidget {
  const ProfileSectionScreen({super.key});

  @override
  State<ProfileSectionScreen> createState() => _ProfileSectionScreenState();
}

class _ProfileSectionScreenState extends State<ProfileSectionScreen> {
  final List<ProfileAction> _actions = [
    ProfileAction(
      icon: Icons.edit_rounded,
      title: 'Edit Profile',
      color: AppColor.primaryColor,
      route: '/edit-profile',
    ),
    ProfileAction(
      icon: Icons.lock_rounded,
      title: 'Change Password',
      color: AppColor.purple,
      route: '/change-password',
    ),
    ProfileAction(
      icon: Icons.history_rounded,
      title: 'Transaction History',
      color: AppColor.indigo,
      route: '/transaction-history',
    ),
    ProfileAction(
      icon: Icons.phone_android_rounded,
      title: 'Device Verification',
      color: AppColor.orangeColor,
      route: '/device-verification',
    ),
  ];

  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child:  CustomBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // User Profile Card
                  _buildProfileCard(),
                  const SizedBox(height: 28),

                  // Actions Card
                  _buildActionsCard(),
                  const SizedBox(height: 28),

                  // Logout Button
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColor.primaryGradient, /*const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B5CF6),
            Color(0xFF662483),
            Color(0xFF4A1C6B),
          ],
        ),*/
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColor.whiteColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColor.secondaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile Image with glow effect
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.whiteColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.secondaryColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 50,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // User Name
                Text(
                  'Dr. Sarah Johnson',
                  style: TextStyle(
                    fontSize: Sizes.titleText(context) + 2,
                    fontWeight: FontWeight.w800,
                    color: AppColor.whiteColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // BMDC Number
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      'BMDC: A-12345',
                      style: TextStyle(
                        fontSize: Sizes.normalText(context),
                        fontWeight: FontWeight.w700,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Account Settings',
              style: TextStyle(
                fontSize: Sizes.subTitleText(context),
                fontWeight: FontWeight.w800,
                color: AppColor.primaryTextColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),

            ..._actions.map((action) => _buildActionTile(action)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(ProfileAction action) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleActionTap(action),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    action.color.withOpacity(0.05),
                    action.color.withOpacity(0.02),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Icon with gradient background
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          action.color.withOpacity(0.2),
                          action.color.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      action.icon,
                      color: action.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Title
                  Expanded(
                    child: Text(
                      action.title,
                      style: TextStyle(
                        fontSize: Sizes.bodyText(context),
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryTextColor,
                      ),
                    ),
                  ),

                  // Arrow with gradient
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColor.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_actions.indexOf(action) != _actions.length - 1)
          const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoggingOut ? null : _showLogoutConfirmation,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: BoxDecoration(
              gradient: AppColor.secondaryGradient, /*LinearGradient(
                colors: _isLoggingOut
                    ? [AppColor.orangeColor.withOpacity(0.3), AppColor.orangeColor.withOpacity(0.2)]
                    : [AppColor.orangeColor.withOpacity(0.9), AppColor.orangeColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),*/
              borderRadius: BorderRadius.circular(18),
              boxShadow: _isLoggingOut
                  ? null
                  : [
                BoxShadow(
                  color: AppColor.indigo.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isLoggingOut
                ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.whiteColor),
                ),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 22,
                  color: AppColor.whiteColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: Sizes.bodyText(context),
                    fontWeight: FontWeight.w700,
                    color: AppColor.whiteColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleActionTap(ProfileAction action) {
    // You can add any pre-navigation logic here
    Get.toNamed(action.route);
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColor.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 30,
                  color: AppColor.purple,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: Sizes.subTitleText(Get.context!),
                  fontWeight: FontWeight.w800,
                  color: AppColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: Sizes.bodyText(Get.context!),
                  color: AppColor.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColor.primaryColor),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _performLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.purple,
                        foregroundColor: AppColor.whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    // Simulate logout process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoggingOut = false;
    });

    // Navigate to login screen
    Get.offAllNamed('/login');
  }
}

class ProfileAction {
  final IconData icon;
  final String title;
  final Color color;
  final String route;

  ProfileAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.route,
  });
}