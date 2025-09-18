import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';

class NotificationBell extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onTap;
  final double size;

  const NotificationBell({
    super.key,
    required this.hasUnread,
    required this.onTap,
    this.size = 44, // overall touch target
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = 22.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            // soft, modern “chip” look
            color: AppColor.primaryColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: AppColor.primaryColor.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // bell icon
              Center(
                child: Icon(
                  Icons.notifications_rounded,
                  size: iconSize,
                  color: AppColor.primaryColor,
                ),
              ),

              // red dot badge (animated)
              if (hasUnread)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: _PulseDot(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.15)
          .chain(CurveTween(curve: Curves.easeInOut))
          .animate(_c),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          boxShadow: const [
            // subtle glow
            BoxShadow(
              color: Colors.redAccent,
              blurRadius: 8,
              spreadRadius: 1.5,
            ),
          ],
          border: Border.all(
            color: Colors.white, // crisp edge against any background
            width: .5,
          ),
        ),
      ),
    );
  }
}
