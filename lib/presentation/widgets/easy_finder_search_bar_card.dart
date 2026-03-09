import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_glass_card.dart';

class EasyFinderSearchBarCard extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final void Function(String text) onSearch;

  const EasyFinderSearchBarCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    this.hintText = 'Search...',
  });

  @override
  State<EasyFinderSearchBarCard> createState() => _EasyFinderSearchBarCardState();
}

class _EasyFinderSearchBarCardState extends State<EasyFinderSearchBarCard> {
  String get _text => widget.controller.text.trim();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 18),
            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => widget.onSearch(v.trim()),
                style: TextStyle(
                  fontSize: Sizes.smallText(context),
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontSize: Sizes.verySmallText(context),
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            if (_text.isNotEmpty)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () {
                    widget.controller.clear();
                    widget.focusNode.requestFocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.clear_rounded,
                        size: 18, color: Colors.grey.shade700),
                  ),
                ),
              ),

            const SizedBox(width: 6),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => widget.onSearch(_text),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColor.primaryColor.withOpacity(0.16),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}