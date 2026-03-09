import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medi_exam/data/utils/auth_checker.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/routes.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class EasyFinderCard extends StatefulWidget {
  final String title;

  /// Named navigation (optional)
  final String? routeName;
  final Map<String, dynamic>? arguments;

  /// Custom navigation callback (optional)
  final VoidCallback? onAuthedNavigate;

  /// Require auth gate (default true)
  final bool requireAuth;

  /// Optional: show trailing arrow
  final bool showArrow;

  const EasyFinderCard({
    super.key,
    this.title = 'Easy Finder',
    this.routeName,
    this.arguments,
    this.onAuthedNavigate,
    this.requireAuth = true,
    this.showArrow = true,
  });

  @override
  State<EasyFinderCard> createState() => _EasyFinderCardState();
}

class _EasyFinderCardState extends State<EasyFinderCard>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();

    // ✅ Press feedback (like your banner)
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
    );

    // ✅ Icon pulse (like _FreeBadge)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterAuth() async {
    if (widget.onAuthedNavigate != null) {
      widget.onAuthedNavigate!.call();
      return;
    }

    if (widget.routeName != null && widget.routeName!.trim().isNotEmpty) {
      Get.toNamed(
        widget.routeName!,
        arguments: widget.arguments,
        preventDuplicates: true,
      );
      return;
    }

    Get.toNamed(
      RouteNames.easyFinderScreen,
      preventDuplicates: true,

    );

  }

  Future<void> _handleTap() async {
    // press animation
    await _pressCtrl.forward();
    await _pressCtrl.reverse();

    if (!widget.requireAuth) {
      await _navigateAfterAuth();
      return;
    }

    // auth gate
    final authed = await AuthChecker.to.isAuthenticated();
    if (!authed) {
      Get.snackbar(
        'Login Required',
        'Please log in to use ${widget.title}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      final result = await Get.toNamed(
        RouteNames.login,
        arguments: {
          'popOnSuccess': true,
          'returnRoute': null,
          'returnArguments': null,
          'message': "Log in to use ${widget.title}.",
        },
      );

      if (result == true) {
        await Future.delayed(const Duration(milliseconds: 300));
        final nowAuthed = await AuthChecker.to.isAuthenticated();
        if (!nowAuthed) return;
      } else {
        return;
      }
    }

    await _navigateAfterAuth();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Search-bar size (compact, but premium)
    const double h = 52;
    final borderRadius = BorderRadius.circular(20);

    // Inner background (search bar feel)
    final innerBg = isDark
        ? Colors.grey.shade900.withOpacity(0.60)
        : Colors.white.withOpacity(0.92);

    final hintColor = isDark ? Colors.grey.shade200 : Colors.grey.shade700;

    return SizedBox(
      height: h,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressCtrl, _pulseCtrl]),
        builder: (context, _) {
          // press scale (like your banner)
          final pressScale = 1.0 - (_pressCtrl.value * 0.028);

          // icon pulse (like _FreeBadge)
          final pulse = _pulseCtrl.value; // 0..1
          final iconScale = 1.0 + pulse * 0.10;
          final iconGlowOpacity = 0.18 + pulse * 0.22;

          return Transform.scale(
            scale: pressScale,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: _handleTap,
                  onTapDown: (_) => _pressCtrl.forward(),
                  onTapCancel: () => _pressCtrl.reverse(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      // ✅ gradient border shell (eye-catchy)
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.primaryColor.withOpacity(isDark ? 0.40 : 0.32),
                          AppColor.purple.withOpacity(isDark ? 0.35 : 0.25),
                          AppColor.indigo.withOpacity(isDark ? 0.35 : 0.22),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.4), // gradient border thickness
                      child: ClipRRect(
                        borderRadius: borderRadius,
                        child: Container(
                          decoration: BoxDecoration(
                            color: innerBg,
                            borderRadius: borderRadius,
                          ),
                          child: Stack(
                            children: [
                              // subtle decorative blob/circle (like your banner)
                              Positioned(
                                right: -30,
                                top: -35,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.primaryColor.withOpacity(0.06),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                child: Row(
                                  children: [
                                    // ✅ Icon bubble with pulse scale + glow
                                    Transform.scale(
                                      scale: iconScale,
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColor.primaryColor,
                                              AppColor.purple,
                                              AppColor.indigo,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColor.primaryColor
                                                  .withOpacity(iconGlowOpacity),
                                              blurRadius: 16,
                                              spreadRadius: 1.2,
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.12),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.manage_search_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // ✅ Search-bar hint text style
                                    // ✅ Title + Subtitle
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: Sizes.bodyText(context),
                                              fontWeight: FontWeight.w900,
                                              color: AppColor.primaryColor,
                                              height: 1.0,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            'Find any question instantly',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: Sizes.verySmallText(context),
                                              fontWeight: FontWeight.w600,
                                              color: hintColor.withOpacity(0.72),
                                              height: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (widget.showArrow) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: hintColor.withOpacity(0.65),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ Optional tiny “spark” dot (extra eye-candy, still search-bar-ish)
                Positioned(
                  left: 42,
                  top: 10,
                  child: Opacity(
                    opacity: 0.35 + (_pulseCtrl.value * 0.35),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.30 + _pulseCtrl.value * 0.30),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ✅ Placeholder screen (replace later with your Smart Search screen)
class EasyFinderPlaceholderScreen extends StatelessWidget {
  const EasyFinderPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Easy Finder')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark ? Colors.grey[900] : Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Text(
            'Smart Search screen will be implemented here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}