import 'package:flutter/material.dart';

class CustomBlobBackground extends StatelessWidget {
  final Widget child;
  final Color blobColor;
  final Color backgroundColor;

  const CustomBlobBackground({
    super.key,
    required this.child,
    required this.blobColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-right decorative blob
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: blobColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(100),
                ),
              ),
            ),
          ),

          // Bottom-left decorative blob
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: blobColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  topRight: Radius.circular(100),
                ),
              ),
            ),
          ),

          // Child content
          child,
        ],
      ),
    );
  }
}