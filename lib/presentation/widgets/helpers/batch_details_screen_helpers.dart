// ---------------- Offer UI (unchanged) ----------------

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medi_exam/presentation/utils/sizes.dart';
import 'package:medi_exam/presentation/widgets/custom_blob_background.dart';

class OfferSection extends StatelessWidget {
  final double? basePrice;
  final num? newDoctorDiscount;
  final num? oldDoctorDiscount;
  final List<Color> gradientColors;

  const OfferSection({
    required this.basePrice,
    required this.newDoctorDiscount,
    required this.oldDoctorDiscount,
    required this.gradientColors,
  });

  double _applyDiscount(double price, num discount) =>
      (price - discount.toDouble()).clamp(0, price);

  @override
  Widget build(BuildContext context) {
    final hasNew = (newDoctorDiscount ?? 0) > 0;
    final hasOld = (oldDoctorDiscount ?? 0) > 0;

    if (!hasNew && !hasOld) return const SizedBox.shrink();

    final cards = <Widget>[];

    if (hasNew) {
      cards.add(OfferCard(
        title: 'New Doctor',
        discount: newDoctorDiscount!.toDouble(),
        oldPrice: basePrice,
        newPrice: (basePrice != null)
            ? _applyDiscount(basePrice!, newDoctorDiscount!)
            : null,
        gradientColors: [
          Colors.indigo,
          Colors.purpleAccent,
        ],
        icon: Icons.local_offer_outlined,
      ));
    }

    if (hasOld) {
      cards.add(OfferCard(
        title: 'Existing Doctor',
        discount: oldDoctorDiscount!.toDouble(),
        oldPrice: basePrice,
        newPrice: (basePrice != null)
            ? _applyDiscount(basePrice!, oldDoctorDiscount!)
            : null,
        gradientColors: [
          Colors.pinkAccent,
          Colors.deepPurple,
        ],
        icon: Icons.workspace_premium_rounded,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Special Offers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80, // Reduced height
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => cards[i],
          ),
        ),
      ],
    );
  }
}

class OfferCard extends StatelessWidget {
  final String title;
  final double discount;
  final double? oldPrice;
  final double? newPrice;
  final List<Color> gradientColors;
  final IconData icon;

  const OfferCard({
    required this.title,
    required this.discount,
    required this.oldPrice,
    required this.newPrice,
    required this.gradientColors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Stack(
        children: [

          Positioned(
            top: -4,
            right: -4,
            child: Icon(Icons.auto_awesome_rounded,
                color: Colors.white.withOpacity(0.2), size: 36),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30, width: 0.5),
                    ),
                    child: const Text('Limited',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${_formatPrice(discount)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 0.9),
                  ),
                  const SizedBox(width: 4),
                  const Text('OFF',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Spacer(),
                  if (oldPrice != null && newPrice != null)
                    Row(
                      children: [
                        Text(
                          '৳${_formatPrice(oldPrice!)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withOpacity(0.25)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '৳${_formatPrice(newPrice!)}',
                            style: TextStyle(
                              color: gradientColors.first,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double v) {

    if (v == v.roundToDouble()) {
      return v.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return v.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

// ---------------- Expandable HTML Section (unchanged) ----------------

class ExpandableHtmlSection extends StatefulWidget {
  final String title;
  final String htmlContent;
  final List<Color> gradientColors;

  const ExpandableHtmlSection({
    required this.title,
    required this.htmlContent,
    required this.gradientColors,
  });

  @override
  State<ExpandableHtmlSection> createState() => ExpandableHtmlSectionState();
}

class ExpandableHtmlSectionState extends State<ExpandableHtmlSection> {
  bool _expanded = false;
  bool _shouldAllowExpand = false;
  static const _fontSize = 15.0;
  static const _lineHeight = 1.5;
  static const _maxLinesCollapsed = 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputeShouldExpand(context);
    });
  }

  void _recomputeShouldExpand(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.constraints.maxWidth ??
        MediaQuery.of(context).size.width - 32;
    if (width <= 0) return;

    final plain = _stripHtml(widget.htmlContent);
    final textSpan = TextSpan(
      text: plain,
      style: const TextStyle(fontSize: _fontSize, height: _lineHeight),
    );
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: _maxLinesCollapsed,
      ellipsis: '…',
    )..layout(maxWidth: width);

    final exceeded = tp.didExceedMaxLines;
    if (mounted && _shouldAllowExpand != exceeded) {
      setState(() => _shouldAllowExpand = exceeded);
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</(p|li|div|h[1-6])>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sectionHeader = Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );

    final collapsedHeight = _fontSize * _lineHeight * _maxLinesCollapsed;

    return CustomBlobBackground(
      backgroundColor: Colors.white,
      blobColor: Colors.blueAccent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionHeader,
            const SizedBox(height: 12),

            if (!_shouldAllowExpand || _expanded)
              Html(
                data: widget.htmlContent,
                style: {
                  'body': Style(
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    fontSize: FontSize(_fontSize),
                    lineHeight: LineHeight(_lineHeight),
                    color: isDark ? Colors.white70 : Colors.grey[800],
                  ),
                  'p': Style(margin: Margins.only(bottom: 8)),
                  'li': Style(margin: Margins.only(bottom: 6)),
                },
              )
            else

              Stack(
                children: [
                  ClipRect(
                    child: SizedBox(
                      height: collapsedHeight,
                      child: Html(
                        data: widget.htmlContent,
                        style: {
                          'body': Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(_fontSize),
                            lineHeight: LineHeight(_lineHeight),
                            color: isDark ? Colors.white70 : Colors.grey[800],
                          ),
                          'p': Style(margin: Margins.only(bottom: 8)),
                          'li': Style(margin: Margins.only(bottom: 6)),
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 32,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              (isDark ? const Color(0xFF1E2125) : Colors.white)
                                  .withOpacity(0),
                              (isDark ? const Color(0xFF1E2125) : Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            if (_shouldAllowExpand) const SizedBox(height: 8),
            if (_shouldAllowExpand)
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _expanded ? 'Show less' : 'Show more',
                      style: TextStyle(
                        color: widget.gradientColors[0],
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: widget.gradientColors[0],
                      size: 20,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Generic info pill (unchanged) ----------------

class BatchInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;

  const BatchInfoPill({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: Sizes.extraSmallIcon(context), color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Sizes.smallText(context),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
