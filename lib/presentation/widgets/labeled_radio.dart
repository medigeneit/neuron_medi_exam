// lib/presentation/widgets/labeled_radio.dart
import 'package:flutter/material.dart';
import 'package:medi_exam/presentation/utils/app_colors.dart';

/// A compact circle-like selectable control with the label inside.
class LabeledRadio extends StatelessWidget {
  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;
  final double size; // circle diameter
  final Color? selectedColor; // allow override if needed

  const LabeledRadio({
    super.key,
    required this.label,
    required this.selected,
    required this.disabled,
    this.onTap,
    this.size = 28,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use your brand primary by default
    final Color selBg = selectedColor ?? AppColor.primaryColor;
    final Color selFg = Colors.white;

    final Color baseBorder = theme.colorScheme.outlineVariant;
    final Color baseText = theme.colorScheme.onSurface;

    final Color disabledBg = theme.disabledColor.withOpacity(0.08);
    final Color disabledBorder = theme.disabledColor.withOpacity(0.30);
    final Color disabledText = theme.disabledColor.withOpacity(0.9);

    // IMPORTANT: keep selected styling even when disabled (locked),
    // so users can tell which one was chosen earlier.
    final bool disabledButSelected = disabled && selected;

    final Color borderColor = disabledButSelected
        ? selBg
        : disabled
        ? disabledBorder
        : (selected ? selBg : baseBorder);

    final Color bgColor = disabledButSelected
        ? selBg
        : disabled
        ? disabledBg
        : (selected ? selBg : theme.colorScheme.surface);

    final Color fgColor = disabledButSelected
        ? selFg
        : disabled
        ? disabledText
        : (selected ? selFg : baseText);

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: borderColor, width: 1.6),
          boxShadow: (selected || disabledButSelected)
              ? [
            BoxShadow(
              color: selBg.withOpacity(0.22),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: fgColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            fontSize: size - 12,
          ),
        ),
      ),
    );
  }
}
