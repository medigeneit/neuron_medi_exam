import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/utils/local_storage_service.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';
import 'package:medi_exam/presentation/widgets/fancy_card_background.dart';

class ProfileSectionScreen extends StatefulWidget {
  const ProfileSectionScreen({super.key});

  @override
  State<ProfileSectionScreen> createState() => _ProfileSectionScreenState();
}

class _ProfileSectionScreenState extends State<ProfileSectionScreen> {
  // ---- Local values loaded from storage ----
  String? _name;
  String? _phone;
  String? _photoUrl;

  // Use your existing placeholder image URL when user photo is empty
  static const String _kPlaceholderAvatarUrl =
      'https://img.freepik.com/free-vector/doctor-character-background_1270-84.jpg?w=200&t=st=1720102342~exp=1720102942~hmac=2d2b5a7a9b3d8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8b8';

  final List<ProfileAction> _actions = [
    ProfileAction(
      icon: Icons.edit_rounded,
      title: 'Edit Profile',
      color: AppColor.primaryColor,
      route: RouteNames.editProfile,
    ),
    ProfileAction(
      icon: Icons.lock_rounded,
      title: 'Change Password',
      color: AppColor.purple,
      route: RouteNames.passwordChange,
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
  void initState() {
    super.initState();
    _loadProfileFromStorage();
  }

  Future<void> _loadProfileFromStorage() async {
    try {
      final data =
      await LocalStorageService.getObject(LocalStorageService.userData);
      if (data is Map) {
        setState(() {
          _name = (data!['name'] as String?)?.trim();
          _phone = (data!['phone_number'] as String?)?.trim();
          _photoUrl = (data!['photo'] as String?)?.trim();
        });
      }
    } catch (_) {
      // ignore; keep defaults
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              _buildProfileCard(),
              const SizedBox(height: 28),
              _buildActionsCard(),
              const SizedBox(height: 28),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final displayName =
    (_name != null && _name!.isNotEmpty) ? _name! : 'User Name';
    final displayPhone = (_phone != null && _phone!.isNotEmpty) ? _phone! : '—';
    final avatarUrl = (_photoUrl != null && _photoUrl!.isNotEmpty)
        ? _photoUrl!
        : _kPlaceholderAvatarUrl;

    return FancyBackground(
      gradient: AppColor.primaryGradient,
      child: Stack(
        children: [
          Column(
            children: [
              // ---- Avatar ----
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.whiteColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.secondaryColor.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 3,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      AppColor.whiteColor.withOpacity(0.3),
                      AppColor.secondaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipOval(
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColor.primaryColor,
                                AppColor.secondaryColor,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ),
                    // Online status
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColor.whiteColor, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- Name ----
              Text(
                displayName,
                style: TextStyle(
                  fontSize: Sizes.titleText(context),
                  fontWeight: FontWeight.w900,
                  color: AppColor.whiteColor,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // ---- Phone ----
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 42),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColor.whiteColor.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      size: 18,
                      color: AppColor.whiteColor.withOpacity(0.9),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      displayPhone,
                      style: TextStyle(
                        fontSize: Sizes.normalText(context),
                        fontWeight: FontWeight.w600,
                        color: AppColor.whiteColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  const SizedBox(width: 16),
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
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: AppColor.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: AppColor.whiteColor),
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
            padding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: BoxDecoration(
              gradient: AppColor.warningGradient,
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColor.whiteColor),
                ),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded,
                    size: 22, color: AppColor.whiteColor),
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColor.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded,
                    size: 30, color: AppColor.purple),
              ),
              const SizedBox(height: 16),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: Sizes.subTitleText(Get.context!),
                  fontWeight: FontWeight.w800,
                  color: AppColor.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: Sizes.bodyText(Get.context!),
                  color: AppColor.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
    setState(() => _isLoggingOut = true);
    await LocalStorageService.clearAll();
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoggingOut = false);
    Get.offAllNamed(RouteNames.navBar, arguments: 2);
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
