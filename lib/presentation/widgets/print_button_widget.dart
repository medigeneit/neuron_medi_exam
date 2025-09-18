// Modern, adaptive print button (extended pill on wide screens, fab on narrow)
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';

class PrintButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading; // NEW

  const PrintButton({
    required this.onPressed,
    this.isLoading = false, // NEW
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorA = AppColor.indigo;
    final colorB = AppColor.purple;

    // Show extended pill if we have some horizontal room
    final showExtended = MediaQuery.of(context).size.width > 380;

    return Tooltip(
      message: isLoading ? 'Preparing to print…' : 'Print schedule',
      preferBelow: false,
      child: showExtended
          ? _ExtendedPill(
        onPressed: onPressed,
        isDark: isDark,
        colorA: colorA,
        colorB: colorB,
        isLoading: isLoading, // NEW
      )
          : _CircularFab(
        onPressed: onPressed,
        isDark: isDark,
        colorA: colorA,
        colorB: colorB,
        isLoading: isLoading, // NEW
      ),
    );
  }
}

class _ExtendedPill extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;
  final Color colorA, colorB;
  final bool isLoading; // NEW

  const _ExtendedPill({
    required this.onPressed,
    required this.isDark,
    required this.colorA,
    required this.colorB,
    this.isLoading = false, // NEW
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.8 : 1,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [colorA, colorB],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorB.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: isLoading ? null : onPressed, // disable while loading
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isLoading
                    ? Row(
                  key: const ValueKey('loading-pill'),
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Preparing…',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                )
                    : Row(
                  key: const ValueKey('content-pill'),
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.print_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Print',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularFab extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;
  final Color colorA, colorB;
  final bool isLoading; // NEW

  const _CircularFab({
    required this.onPressed,
    required this.isDark,
    required this.colorA,
    required this.colorB,
    this.isLoading = false, // NEW
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLoading ? 0.8 : 1,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [colorA, colorB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorB.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isLoading ? null : onPressed, // disable while loading
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const SizedBox(
                  key: ValueKey('loading-fab'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(
                  Icons.print_rounded,
                  key: ValueKey('content-fab'),
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
