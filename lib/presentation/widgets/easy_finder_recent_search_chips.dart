import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';

class EasyFinderRecentSearchChips extends StatelessWidget {
  final List<String> items; // already capped at 5 by screen
  final void Function(String query) onTapChip;

  const EasyFinderRecentSearchChips({
    super.key,
    required this.items,
    required this.onTapChip,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded,
                  size: 16, color: AppColor.indigo.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(
                'Recent',
                style: TextStyle(
                  fontSize: Sizes.verySmallText(context),
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((q) => _SearchChip(text: q, onTap: () => onTapChip(q))).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SearchChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppColor.primaryColor.withOpacity(0.08),
            border: Border.all(color: AppColor.primaryColor.withOpacity(0.14)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_rounded,
                  size: 14, color: AppColor.primaryColor.withOpacity(0.9)),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Sizes.verySmallText(context),
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade800,
                    height: 1.0,
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