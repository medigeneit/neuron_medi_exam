import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final String? url;
  const BannerImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        color: const Color(0xFF23252A),
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, size: 32, color: Colors.white30),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFF23252A),
          alignment: Alignment.center,
          child: const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, _, __) {
        return Container(
          color: const Color(0xFF23252A),
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, size: 32, color: Colors.white30),
        );
      },
    );
  }
}

class InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;

  const InfoPill({
    Key? key,
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF374151);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: fg,
              height: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}