import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final bool isCompact;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  const SearchBarWidget({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.isCompact,
    required this.onClear,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = [AppColor.indigo, AppColor.purple];
    final outerBorderRadius = BorderRadius.circular(14);
    final innerBorderRadius = BorderRadius.circular(12.5); // Slightly smaller than outer

    return Container(
      decoration: BoxDecoration(
        borderRadius: outerBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121416) : Colors.white,
          borderRadius: innerBorderRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmitted,
                style: TextStyle(
                  fontSize: isCompact ? 13.5 : 14.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by title or subtitle',
                  hintStyle: TextStyle(
                    fontSize: isCompact ? 13.0 : 14.0,
                    color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                splashRadius: 18,
                tooltip: 'Clear',
              ),
          ],
        ),
      ),
    );
  }
}

class TinyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const TinyChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22252A) : const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.indigo),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: isDark ? Colors.white : const Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String query;
  final bool isDark;

  const EmptyState({required this.query, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final subtle = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: subtle),
            const SizedBox(height: 10),
            Text(
              'No batches found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'We couldn’t find any results for “$query”.\nTry a different keyword or clear the search.',
              style: TextStyle(
                fontSize: 13.0,
                height: 1.35,
                color: subtle,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            TextButton.icon(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Go back'),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.indigo,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}