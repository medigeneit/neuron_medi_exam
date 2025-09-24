// lib/presentation/widgets/floating_customer_care.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/assets_path.dart';

class FloatingCustomerCare extends StatefulWidget {
  /// All are optional now. If null/empty → that pill is hidden.

  /// Example: https://m.me/yourPageOrUser OR https://www.messenger.com/t/<id>
  final String? messengerUrl;

  /// WhatsApp phone in international format (no +, no spaces) e.g. "8801XXXXXXXXX"
  final String? whatsappPhone;

  /// Phone number for calling e.g. "+8801XXXXXXXXX"
  final String? phoneNumber;

  /// Optional promo video URL (YouTube etc.)
  final String? promoVideoUrl;

  /// Optional: override promo tap handling (use the HomeScreen logic you pasted)
  final VoidCallback? onPromoTap;

  /// Optional preset message for WhatsApp
  final String? whatsappMessage;

  /// Colors for the main button gradient (kept for styling)
  final List<Color> gradientColors;

  /// Where to place it (distance from edges)
  final EdgeInsets floatingPadding;

  /// Optional: override labels
  final String messengerLabel;
  final String whatsappLabel;
  final String callLabel;
  final String promoLabel;

  const FloatingCustomerCare({
    super.key,
    this.messengerUrl,
    this.whatsappPhone,
    this.phoneNumber,
    this.promoVideoUrl,
    this.onPromoTap,
    this.whatsappMessage,
    this.gradientColors = const [Color(0xFF4F46E5), Color(0xFF9333EA)],
    this.floatingPadding = const EdgeInsets.only(right: 16, bottom: 24),
    this.messengerLabel = 'Messenger',
    this.whatsappLabel = 'WhatsApp',
    this.callLabel = 'Call',
    this.promoLabel = 'Tutorial Video',
  });

  @override
  State<FloatingCustomerCare> createState() => _FloatingCustomerCareState();
}

class _FloatingCustomerCareState extends State<FloatingCustomerCare>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  bool _expanded = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  Future<void> _launchUrl(String urlString,
      {LaunchMode mode = LaunchMode.externalApplication}) async {
    setState(() => _busy = true);
    try {
      final Uri uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: mode);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open: $urlString')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _extractMessengerId(String url) {
    // supports .../messages/t/168865486570992 or .../t/168865486570992
    final m = RegExp(r'/messages/?t/(\d+)|/t/(\d+)').firstMatch(url);
    if (m != null) {
      return (m.group(1) ?? m.group(2))?.trim();
    }
    return null;
  }

  Future<void> _openMessenger() async {
    final raw = (widget.messengerUrl ?? '').trim();
    if (raw.isEmpty) return;

    final id = _extractMessengerId(raw);
    final appUri = id != null ? Uri.parse('fb-messenger://user-thread/$id') : null;
    final webUri = Uri.parse(raw); // https://m.me/<user> or https://www.messenger.com/t/<id>

    setState(() => _busy = true);
    try {
      if (appUri != null && await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Messenger not available on this device')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openWhatsApp() async {
    final phone = (widget.whatsappPhone ?? '').trim();
    if (phone.isEmpty) return;

    final msg = widget.whatsappMessage ?? '';
    final appUri = Uri.parse(
        'whatsapp://send?phone=$phone&text=${Uri.encodeComponent(msg)}');
    final webUri =
    Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(msg)}');

    setState(() => _busy = true);
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp not available on this device')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _callPhone() async {
    final number = (widget.phoneNumber ?? '').trim();
    if (number.isEmpty) return;

    final tel = Uri(scheme: 'tel', path: number);

    setState(() => _busy = true);
    try {
      if (await canLaunchUrl(tel)) {
        await launchUrl(tel, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot call $number')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPromo() async {
    if (widget.onPromoTap != null) {
      widget.onPromoTap!.call();
      return;
    }
    final link = (widget.promoVideoUrl ?? '').trim();
    if (link.isNotEmpty) {
      await _launchUrl(link);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video link is unavailable')),
      );
    }
  }

  // Light slide generator for variable number of actions.
  Animation<Offset> _slideForIndex(int index) {
    final startDy = 0.15 + (index * 0.07);
    return Tween(begin: Offset(0, startDy), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_ctrl);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build the visible actions in order (top to bottom)
    final actions = <Widget>[];
    if ((widget.promoVideoUrl ?? '').trim().isNotEmpty) {
      actions.add(_GlassActionPill.icon(
        icon: Icons.play_circle_fill_rounded,
        label: widget.promoLabel,
        onTap: _busy ? null : _openPromo,
        isDark: isDark,
        color: Colors.redAccent,
      ));
    }
    if ((widget.messengerUrl ?? '').trim().isNotEmpty) {
      actions.add(_GlassActionPill.svg(
        svgAsset: AssetsPath.fbIcon,
        label: widget.messengerLabel,
        onTap: _busy ? null : _openMessenger,
        isDark: isDark,
        color: Colors.blueAccent,
      ));
    }
    if ((widget.whatsappPhone ?? '').trim().isNotEmpty) {
      actions.add(_GlassActionPill.svg(
        svgAsset: AssetsPath.whatsAppIcon,
        label: widget.whatsappLabel,
        onTap: _busy ? null : _openWhatsApp,
        isDark: isDark,
        color: Colors.green,
      ));
    }
    if ((widget.phoneNumber ?? '').trim().isNotEmpty) {
      actions.add(_GlassActionPill.svg(
        svgAsset: AssetsPath.callIcon,
        label: widget.callLabel,
        onTap: _busy ? null : _callPhone,
        isDark: isDark,
        color: Colors.indigo,
      ));
    }

    // If nothing to show, hide the whole thing
    final nothing = actions.isEmpty;

    return SafeArea(
      child: Padding(
        padding: widget.floatingPadding,
        child: SizedBox.expand(
          child: nothing
              ? const SizedBox.shrink()
              : Stack(
            clipBehavior: Clip.none,
            children: [
              // Actions column
              Positioned(
                right: 0,
                bottom: 66,
                child: AnimatedBuilder(
                  animation: _ctrl,
                  builder: (context, child) {
                    final ignoring =
                        _ctrl.status != AnimationStatus.completed;
                    return IgnorePointer(ignoring: ignoring, child: child);
                  },
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(actions.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: i == actions.length - 1 ? 0 : 10),
                          child: SlideTransition(
                            position: _slideForIndex(i),
                            child: actions[i],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Main FAB
              Positioned(
                right: 0,
                bottom: 0,
                child: _GlassCircleButton(
                  isDark: isDark,
                  gradientColors: widget.gradientColors,
                  onTap: _busy ? null : _toggle,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (c, anim) => RotationTransition(
                      turns: anim,
                      child: ScaleTransition(scale: anim, child: c),
                    ),
                    child: _busy
                        ? const SizedBox(
                      key: ValueKey('busy'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : Icon(
                      _expanded ? Icons.close_rounded : Icons.chat,
                      key: ValueKey(_expanded),
                      color: AppColor.primaryColor,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassActionPill extends StatelessWidget {
  final IconData? icon; // use this for Material icons
  final String? svgAsset; // use this for SVG assets
  final String label;
  final VoidCallback? onTap;
  final bool isDark;
  final Color color;
  final double iconSize;

  const _GlassActionPill.icon({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.color,
    this.iconSize = 18,
    this.svgAsset,
  }) : assert(icon != null && svgAsset == null, 'Use .icon OR .svg, not both.');

  const _GlassActionPill.svg({
    required this.svgAsset,
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.color,
    this.iconSize = 18,
    this.icon,
  }) : assert(svgAsset != null && icon == null, 'Use .icon OR .svg, not both.');

  @override
  Widget build(BuildContext context) {
    final Widget leading = svgAsset != null
        ? SvgPicture.asset(svgAsset!, width: iconSize, height: iconSize)
        : Icon(icon, size: iconSize, color: color);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Material(
          color: Colors.grey.withOpacity(0.05),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  leading,
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final List<Color> gradientColors;
  final bool isDark;
  final Widget child;
  final VoidCallback? onTap;

  const _GlassCircleButton({
    required this.gradientColors,
    required this.isDark,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.25), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Material(
            color: AppColor.whiteColor.withOpacity(0.15),
            child: InkWell(
              onTap: onTap,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
